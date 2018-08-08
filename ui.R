library(shiny)

# Define UI for application that draws a histogram
ui <- fluidPage(
    
    # Application title
    titlePanel("Download Genomes"),
    selectInput("DataBase", label = "DataBase", choices = c("Choose"="","RefSeq", "GenBank")),
    selectInput("Genus", "Genus", choices = NULL),
    selectInput("Species", "Species", NULL), 
    actionButton("Get_Table", "Get Table"),
    uiOutput("Table"),
    dataTableOutput(outputId = "plot.Table")                
)

# Run the application 
# shinyApp(ui = ui, server = server)

