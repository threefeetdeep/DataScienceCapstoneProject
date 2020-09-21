# server.R -- Create back end for word prediction app

# Load the prediction model
source("my_model.R")

# define server
shinyServer(function(input, output, session) {
  
  # user input as reactive variable
  user_data <- reactive({
    data.frame(num_suggestions = input$num_suggestions,
               phrase = input$message,
               mode = input$quad_power_mode,
               show = input$show_diagnostics)
  })
  
  # predicted word table as reactive variable
  predict_words <- reactive({
    settings <- user_data()
    predictions <- prob_penalty_model(s = settings$phrase,
                       num_preds=settings$num_suggestions,
                       penalty = 0.2,
                       quad = settings$mode)
    
    return (list(pred_table = predictions,
                 settings = settings))
  })
  
  # render the predicted output
  output$predicted_words <- renderText({
    p <- predict_words()
    pred_table <- p$pred_table
    paste(pred_table$ng_next, collapse=" ")
  })
  
  observeEvent(input$clear_text, {
    updateTextInput(session, "message", value = "")
  })
    

   output$prediction_table <-renderTable(
     digits=3, 
     {
     p <- predict_words()
     settings <- p$settings
     
     # only show table if "Show" mode is selected
     if (settings$show==TRUE) {
       p$pred_table %>%
         select(ng_head, ng_next, n, prob) %>%
         mutate(prob = exp(-prob/4000)) -> table_to_show
    
       # rename columns to human-friendly names
       colnames(table_to_show) <- c("Ngram Head","Predicted","Frequency", "Probability")
       
       # convert Frequency col to character to prevent decimal place being added
       table_to_show$Frequency <- as.character(table_to_show$Frequency)
       
       # show table
       table_to_show
     }
  })

})
  

  
