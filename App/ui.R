library(shiny)
library(shinyWidgets)
# Define UI for application that draws a histogram
shinyUI(fluidPage(

  titlePanel("MyWord! N-Gram Text Prediction Demo App"),
  
  sidebarLayout(
    sidebarPanel(

      h3("Compose Message"),
      textInput(inputId = "message", 
                label = "", 
                value = "" # 
      ),
      
      tags$br(actionButton("clear_text", "Clear Message")),
      tags$br(switchInput("quad_power_mode","QuadPower\U2122", offStatus = "danger")),
      switchInput("show_diagnostics","Diagnostics", offStatus = "danger"),
      tags$br(sliderInput("num_suggestions", "Number of suggestions:", 
                  min=1, max=6, value=3)),
    ), 
    
    mainPanel(
      tabsetPanel(
        tabPanel(
          "Prediction",
          HTML("<span style='color:#F00030'>"),
          h3(textOutput("predicted_words"), align="center"),
          HTML("</span>"),
          br(),
          hr(),
          div(tableOutput("prediction_table"),style='font-size:150%')
        ),
        tabPanel("About",
                 includeMarkdown("about.Rmd")
        )
      )
    )
  )
))