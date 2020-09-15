library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # tags$head(
  #   tags$link(rel = "stylesheet", type = "text/css", href = "bootstrap.css")
  # ),
  
  # Application title
  titlePanel("Mobile Messenger App With Next Word Prediction"),
  
  # Sidebar with a slider input for the number of bins
  sidebarLayout(
    
    sidebarPanel(

      h3("Compose Message"),
      textInput(inputId = "message", 
                label = "", 
                value = "" # 
      ),
      
      
      sliderInput("num_suggestions", "Number of suggestions:", 
                  min=1, max=6, value=3)

    ), 
    
    mainPanel(
      tabsetPanel(
        tabPanel(
          "Prediction",
          HTML("<span style='color:#203040'>"),
          h3(textOutput("predicted_words"), align="center"),
          HTML("</span>"),
          br(),
          h4(textOutput("kText")),
          hr(),
          div(dataTableOutput("prediction_table"), style='font-size:150%')        
        ),
        tabPanel("About",
                 #includeMarkdown("about.Rmd")
        )
      )
    )
  )
))