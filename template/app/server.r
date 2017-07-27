#### SET UP DATA ####

library(ggplot2)

DATA_PATH <- file.path(getwd(), "data")

d = read.csv(paste(DATA_PATH, "dummy.txt", sep = '/'))


#### END DATA SETUP ####

shinyServer(function(input, output) {
  #### SERVER
  
  ## SELECTIONS BASED ON UI
  
  selectedSounds <- eventReactive(input$soundToggle,{input$soundToggle})
  
  ## DATA FOR PLOTS
  
  subsetted_data <- reactive({subset(d, sound %in% selectedSounds())})
  
  ## PLOTS
  
  output$plot1 <- renderPlot({
    ggplot(subsetted_data(), aes(x=timepoint, y = pitch, colour = sound)) + geom_path()
  })
  
  
  ## ANY OTHER UI INTERACTIONS
  
  
  
})