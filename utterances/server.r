#### SET UP DATA ####

library(ggplot2)

DATA_PATH <- file.path(getwd(), "data")

addResourcePath("audio", paste(DATA_PATH, "audio", sep = '/'))

gg_color_hue <- function(n) {
  hues = seq(15, 375, length=n+1)
  hcl(h=hues, l=65, c=100)[1:n]
}

averageAll = read.csv(paste(DATA_PATH, "averageAll.txt", sep = '/'),sep = "\t")
averageAll= subset(averageAll, !is.na(smoothedPitch))
perception = read.csv(paste(DATA_PATH, "perception.txt", sep = '/'),sep = "\t")
perception = subset(perception,!is.na(Contour))

#### END DATA SETUP ####

shinyServer(function(input, output) {
  #### SERVER
  
  ## SELECTIONS BASED ON UI
  
  selectedContours <- eventReactive(input$contourGroup,{input$contourGroup})
  selectedGenders <- eventReactive(input$genderToggle,{input$genderToggle})
  
  ## DATA FOR PLOTS
  
  pitch_data <- reactive({subset(averageAll, (Contour %in% selectedContours()) & (Gender %in%  selectedGenders()))})
  
  naturalness_data <- reactive({subset(perception, Contour %in% selectedContours() & Gender %in%  selectedGenders())})
  
  ## PLOTS
  
  output$pitch_plot <- renderPlot({
    ggplot(pitch_data(), aes(x=sliceTimeAv, y=smoothedPitch, group=recordedFile, colour=Contour)) + theme_bw(base_size = 8) + geom_line(show.legend=F) + geom_smooth(aes(x=sliceTimeAv, y=smoothedPitch,group=1), colour="black",size=0.7,method='gam') + xlab("") + ylab("Pitch (Hz)") + facet_grid(.~Context) + scale_colour_manual(values=rev(gg_color_hue(8))) + ggtitle("Smoothed pitch track of utterances by context in which they were recorded")
    
    # Michael M. changed method for average curve to 'gam', but smooth seems more desirable?:
    # + geom_smooth(aes(x=sliceTimeAv, y=smoothedPitch,group=1), colour="black",size=0.7, data = averageAll,method='gam')
  })
  
  output$naturalness_plot <- renderPlot({
    ggplot(naturalness_data(), aes(x=Context, y=response,colour=Context))  + geom_boxplot(width=0.6, notch=T)  + xlab('Context in which utterance is played') + ylab('Naturalness Rating (1-8)') + theme_bw(base_size=8) + ggtitle("Perceptual Norming")})
  
  ## Interact with the plot by clicking
  curves_clicked <- eventReactive(input$plot_click, {
    res <- nearPoints(pitch_data(), input$plot_click, addDist = TRUE, maxpoints = 1, threshold = 500)
    res
  })
  
  
  ## PLAYING SOUND FILES
  output$wavfile <- renderUI({
    audioname <- paste0("audio/",as.character(curves_clicked()[1,'recordedFile']))
    tags$audio(src = audioname, type = "audio/mpeg", controls=NA,autoplay=NA)
  })
  output$wavfilename <- renderUI({
    tags$div(paste0("audio/",as.character(curves_clicked()[1,'recordedFile'])))
  })
  
  
  
})