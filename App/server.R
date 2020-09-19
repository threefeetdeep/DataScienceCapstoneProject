# server.R -- Create back end for word prediction app

source("my_model.R")

# define server
shinyServer(function(input, output, session) {
  
  
  # define reactive variable to hold user input
  user_data <- reactive({
    data.frame(num_suggestions = input$num_suggestions,
               phrase = input$message,
               mode = input$quad_power_mode,
               show = input$show_prob_table)
  })
  
  # define reactive variable to hold prediction
  predict_words <- reactive({
    settings <- user_data()
    predictions <- prob_penalty_model(s = settings$phrase,
                       num_preds=settings$num_suggestions,
                       quad = settings$mode)
    return (list(pred_table = predictions,data = settings))
  })
  
  # create output for prediction as text
  output$predicted_words <- renderText({
    p <- predict_words()
    pred_table <- p$pred_table
    paste(pred_table$ng_next, collapse=" ")
  })
  
  observeEvent(input$clear_text, {
    updateTextInput(session, "message", value = "")
  })
  

  
})