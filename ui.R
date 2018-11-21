library(shiny)

# Define UI for application that draws a histogram
ui <- fluidPage(
     
    # Application title
    
    sidebarLayout(
        sidebarPanel(
            titlePanel("Download Genomes"),
            checkboxGroupInput("assembly.lvl","Assembly Level",choices = c("Complete Genome", "Chromosome","Scaffold","Contig"), selected = c("Complete Genome")),
            selectInput("DataBase", label = "DataBase", choices = c("Choose"="","RefSeq", "GenBank")),
                fileInput("inTable", label = "Or upload an Assembly Table"),
                div(style = "margin-top:-2em; margin-bottom:2em",
                checkboxInput("skip1", "Skip first line?", TRUE)
                ),
            # fileInput("inTable.parsed", label = "Or upload final table with wanted strains"),
            selectInput("Genus", "Genus", choices = NULL),
            selectInput("Species", "Species", NULL),
            downloadButton("downTable", "Download Table"),
            selectInput("seq", label = "Sequence", choices = c("Genomic"="genome","Protein"="protein", "CDS"="rna", "Feature" = "feature"),selected = "Genomic"),
            
            fluidRow(
                column(width =7,
                  textInput("path", "Download_Path",value = 'C:\\Users\\')
                ),
                column(width = 2,
                  br(),
                  actionButton("download", "Download")
                  
                )
            ),
            # fileInput("strains.file", "Or upload the strain list file"),
            # textInput("strain", "Or search by strain name"),
            uiOutput("Table"),
            uiOutput("strain.list")
        ),
        mainPanel(
            dataTableOutput(outputId = "plot.Table")
        )
    )
)

# Run the application 
# shinyApp(ui = ui, server = server)

