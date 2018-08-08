# Define server logic required to draw a histogram
server <- function(input, output, session) {
    
    Assemblie.df <- reactive({
      req(input$DataBase)
        if(input$DataBase == "RefSeq"){
            # Assemblies <- read.delim(
            #         file = rs.link, sep = "\t", skip = 1, header = T,
            #         comment.char = "", stringsAsFactors = F)
            Assemblies <- read.delim(
                file = "2018_08_07_Assemblies_refseq.txt", sep = "\t", skip = 1, header = T,
                comment.char = "", stringsAsFactors = F)
        }else if (input$DataBase == "GenBank"){
            Assemblies <- read.delim(
                    file = gb.link, sep = "\t", skip = 1, header = T,
                    comment.char = "", stringsAsFactors = F )
        }
            Assemblies <- Get_phylo(Assemblies)
            Assemblies <- get_strain_name(Assemblies)
            Assemblies$strain <- remove_sym(Assemblies$strain)
            remove.dup(Assemblies)
    })
    
    
    
    observeEvent(input$DataBase, {
        updateSelectInput(session, "Genus","Genus", c("Choose"="",Get.length(Assemblie.df()$Genera)))
        
        # GenusInput <- eventReactive(input$Genus,{
        #     input$Genus
        # })
        Assemblie.sub <- reactive({
            Assemblie.df()[Assemblie.df()$Genera == gsub("\\s*\\([^\\)]+\\)","",input$Genus),]
        })
        
        c.species <- reactive({
          Get.length(Assemblie.sub()$Species)
        })
        observeEvent(input$Genus,{
          
          updateSelectInput(session, "Species","Species", c("Choose"="",c.species()))
        })
        # output$Species <- renderUI({
        #     c.species <- Get.length(Assemblie.sub()$Species)
        #     selectInput("Specie",
        #                 label = "Specie",
        #                 choices = c("ALL", c.species))
        # })
        Assemblie.sub.sp <- reactive({
          Assemblie.sub()[Assemblie.sub()$Species == gsub("\\s*\\([^\\)]+\\)","",input$Species),]
        })
        observeEvent(input$Get_Table,{
            output$plot.Table <- renderDataTable(Assemblie.sub.sp()[,c(1, 5, 8,11, 12,14,15,16,21,24,23,25)])
        })
    })

}
