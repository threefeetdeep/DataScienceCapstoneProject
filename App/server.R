# server.R -- Create back end for word prediction app

source("my_model.R")

# define server
shinyServer(function(input, output) {
  
  # define reactive variable to hold user input
  user_data <- reactive({
    data.frame(num_suggestions = input$num_suggestions,
               phrase = input$message)
  })
  
  # define reactive variable to hold prediction
  predict_words <- reactive({
    new_data <- user_data()
    predictions <- c("the","dog","ate","my","homework","sir")
    prob_penalty_model(s = new_data$phrase,
                       num_preds=new_data$num_suggestions)
  })
  
  # create output for prediction as text
  output$predicted_words <- renderText({
    p <- predict_words()
   
    # string <- NULL
    # for (i in 1:length(words)) {
    #   string <- c(string, words[[i]], sep = "&nbsp;&nbsp;&nbsp;")
    # }
    # HTML(string)
    paste(p[1:3], collapse=" ")
  })
  

  
})