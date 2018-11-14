# Define server logic required to draw a histogram
server <- function(input, output, session) {
    
    Assemblie <- reactive({
      req((input$DataBase != "" | !is.null(input$inTable)))
      withProgress(expr = {
        if(input$DataBase == "RefSeq" & is.null(input$inTable)){
          return(read.delim(
            file = rs.link, sep = "\t", skip = 1, header = T,
            comment.char = "", stringsAsFactors = F))
        }else if (input$DataBase == "GenBank" & is.null(input$inTable)){
          read.delim(
            file = gb.link, sep = "\t", skip = 1, header = T,
            comment.char = "", stringsAsFactors = F )
        }else if (!is.null(input$inTable)){
          read.delim(
            file = input$inTable$datapath, sep = "\t", skip = ifelse(input$skip1, 1, 0), header = T,
            comment.char = "", stringsAsFactors = F )
          
        }
      }, message = "Getting Table")
    })
    

    Assemblie.df <- reactive({
      withProgress({
        Assemblie <- Assemblie()[Assemblie()$assembly_level %in% input$assembly.lvl,]
        Assemblie <- Get_phylo(Assemblie)
        Assemblie <- get_strain_name(Assemblie)
        remove.dup(Assemblie)
      }, message = "Parsing")
    })
     
    # Assemblie.df <- reactive({
    #   req(input$inTable.parsed)
    #   return(read.delim(
    #     file = input$inTable.parsed$datapath, sep = "\t", header = T,
    #     comment.char = "", stringsAsFactors = F ))
    # })
    
    # strains <- reactive({
    #   req(input$strains.file)
    #   s.list  <- readLines(input$strains.file$datapath)
    #   remove_sym(s.list)
    # })
    
    observe({
      updateSelectInput(session, "Genus", "Genus", c("Choose" = "", Get.length(Assemblie.df()$Genera)))
    }) 
    
    observeEvent(input$Genus,{
      c.species <- Get.length(Assemblie.sub()$Species)
      updateSelectInput(session, "Species","Species", c("Choose"="","ALL", c.species))
    })
    
    Assemblie.sub <- reactive({
      req(input$Genus)
        Assemblie <- Assemblie.df()[Assemblie.df()$Genera == gsub("\\s*\\([^\\)]+\\)","",input$Genus),]
        return(Assemblie)
    })
    
    Assemblie.sub.sp <- reactive({
        if(!input$Species == ""){
          if(input$Species != "ALL"){
             return(Assemblie.sub()[Assemblie.sub()$Species == gsub("\\s*\\([^\\)]+\\)","",input$Species),])
          }else{
            return(Assemblie.sub())
          }
        }
    })
    
    output$downTable <- downloadHandler(
      filename = function(){
        paste0("Assemblie_table.txt")
      },
      content = function(file){
        write.table(Assemblie.sub.sp(), file, row.names = F, quote = F, sep = "\t")
      }
    )
    
  
    
    observeEvent(input$Species,{
          Assemblie.table <- Assemblie.sub.sp()[,columns]
          output$plot.Table <- renderDataTable(Assemblie.table)
    })
    
    # observeEvent(input$strains.file,{
    #       req(input$strains.file)
    #       Assemblie.table <- Assemblie.df()[Assemblie.df()$strain %in% strains(),columns]
    #       not.found <- strains()[!strains() %in% Assemblie.table$strain]
    #       print(not.found)
    #       output$plot.Table <- renderDataTable(Assemblie.table)
    # })
    # observeEvent(input$strain,{
    #     req(input$strain)
    #     strain.search <- paste0("^", input$strain)
    #     Assemblie.table <- Assemblie.df()[grep(strain.search, Assemblie.df()$strain, ignore.case = T), columns]
    #     if(nrow(Assemblie.table)>1){
    #       choices.strains <- paste(Assemblie.table$Genera, Assemblie.table$Specie, Assemblie.table$strain)
    #       output$strain.list <- renderUI(
    #         selectInput("strain.list", "Select the strain", choices = c("Choose"="",choices.strains))
    #       ) 
    #       selec.choice <- reactive({
    #         req(input$strain.list)
    #         choice.split <- strsplit(input$strain.list, split = " ")
    #         selec.genera <- choice.split[[1]][1]
    #         selec.specie <- choice.split[[1]][2]
    #         selec.strain <- paste0(choice.split[[1]][3:length(choice.split[[1]])],collapse = " ")
    #         # selec.specie <- word(input$strain.list, 2,2)
    #         # selec.strain <- gsub(paste0(selec.genera," ", selec.specie, " "),replacement = "", input$strain.list)
    #         return(Assemblie.df()[Assemblie.df()$Genera == selec.genera & Assemblie.df()$Specie == selec.specie & Assemblie.df()$strain == selec.strain,1])
    #       })
    #       observe({
    #         Assemblie.table <- Assemblie.df()[Assemblie.df()[,1]==selec.choice(),columns]
    #         output$plot.Table <- renderDataTable(Assemblie.table)
    #       })
    #     }else {
    #       output$plot.Table <- renderDataTable(Assemblie.table)
    #     }
    #   
    # })
    observeEvent(input$download,{
      download_genomes(Assemblie.sub.sp(), type = input$seq, outpath = input$path)
    })
}
