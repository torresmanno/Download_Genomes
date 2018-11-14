library(shiny)

# Define UI for application that draws a histogram
ui <- fluidPage(
     
    # Application title
    
    sidebarLayout(
        sidebarPanel(
            titlePanel("Download Genomes"),
            checkboxGroupInput("assembly.lvl","Assembly Level",choices = c("Complete Genome", "Chromosome","Scaffold","Contig"), selected = c("Complete Genome")),
            selectInput("DataBase", label = "DataBase", choices = c("Choose"="","RefSeq", "GenBank")),
            splitLayout(
                fileInput("inTable", label = "Or upload an Assembly Table"),
                verticalLayout(
                    checkboxInput("skip1", "Skip first line?", TRUE)
                    # actionButton("removefile", "Remove File")
                )
            ),
            # fileInput("inTable.parsed", label = "Or upload final table with wanted strains"),
            selectInput("Genus", "Genus", choices = NULL),
            selectInput("Species", "Species", NULL),
            downloadButton("downTable", "Download Table"),
            selectInput("seq", label = "Sequence", choices = c("Genomic"="genome","Protein"="protein", "CDS"="rna", "Feature" = "feature"),selected = "Genomic"),
            splitLayout(
                textInput("path", "Download_Path",value = 'C:\\Users\\'),
                actionButton("download", "Download")
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

