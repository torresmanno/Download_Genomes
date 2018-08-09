# Define server logic required to draw a histogram
server <- function(input, output, session) {
    
    Assemblie.df <- reactive({
      
      req(input$DataBase)
        incProgress(1/7, detail = "downloading")
        if(input$DataBase == "RefSeq"){
          # Assemblies <- read.delim(
          #         file = rs.link, sep = "\t", skip = 1, header = T,
          #         comment.char = "", stringsAsFactors = F)
          Assemblies <- read.delim(
            file = "2018_08_07_Assemblies_refseq_red.txt", sep = "\t", skip = 1, header = T,
            comment.char = "", stringsAsFactors = F)
        }else if (input$DataBase == "GenBank"){
          Assemblies <- read.delim(
            file = gb.link, sep = "\t", skip = 1, header = T,
            comment.char = "", stringsAsFactors = F )
        }
      
        incProgress(1/7, detail = "getting species data")
        Assemblies <- Get_phylo(Assemblies)
        incProgress(1/7, detail = "getting strain names")
        Assemblies <- get_strain_name(Assemblies)
        incProgress(1/7, detail = "getting strain names")
        Assemblies$strain <- remove_sym(Assemblies$strain)
        incProgress(1/7,detail = "removing duplicated")
        return(remove.dup(Assemblies))
    })
    
    
    
    observeEvent(input$DataBase, {
      withProgress(message = "Getting Assemblie Data", value = 0, {
        # incProgress(1/7,detail = "getting species count")
        updateSelectInput(session, "Genus", "Genus", c("Choose" = "", Get.length(Assemblie.df()$Genera)))
        incProgress(1/7,detail = "DONE")
      })
    })
    
    Assemblie.sub <- reactive({
        Assemblie.df()[Assemblie.df()$Genera == gsub("\\s*\\([^\\)]+\\)","",input$Genus),]
    })
    
    c.species <- reactive({
      Get.length(Assemblie.sub()$Species)
    })
    
    observeEvent(input$Genus,{
      updateSelectInput(session, "Species","Species", c("Choose"="","ALL", c.species()))
    })
    
    Assemblie.sub.sp <- reactive({
      if(input$Genus != "ALL"){
      Assemblie.sub()[Assemblie.sub()$Species == gsub("\\s*\\([^\\)]+\\)","",input$Species),]
      }
      Assemblie.sub()
    })
    
    observeEvent(input$Get_Table,{
        output$plot.Table <- renderDataTable(Assemblie.sub.sp()[,c(1, 5, 8,11, 12,14,15,16,21,24,23,25)])
    })

}
