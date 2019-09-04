### Plots for utterances

#### SET UP DATA ####

library(ggplot2)
library(shinyWidgets)
library(dplyr)

DATA_PATH <- file.path(getwd(), "data")

addResourcePath("audio", paste(DATA_PATH, "audio", sep = '/'))

contourLevels=c("Fall", "Upstepped Fall","Other Fall","Polarity Focus","Presumption Contour","Contradiction Contour","RFR", "Yes/No Rise","Incredulity Contour")

gg_color_hue <- function(n) {
  hues = seq(15, 375, length=n+1)
  hcl(h=hues, l=65, c=100)[1:n]
}
myColors=gg_color_hue(length(contourLevels))

names(myColors)=contourLevels

# annotations
d=read.csv(paste(DATA_PATH, "responses.txt", sep = '/'),sep = "\t")

# pitch measures:
averageAll = read.csv(paste(DATA_PATH, "averageAll.txt", sep = '/'),sep = "\t")
averageAll= subset(averageAll,!is.na(pitch))
averageAll$Contour=factor(averageAll$Contour,levels=contourLevels)

perception = read.csv(paste(DATA_PATH, "perception.txt", sep = '/'),sep = "\t")
perception = subset(perception,!is.na(Contour))

#### END DATA SETUP ####

shinyServer(function(input, output) {
  #### SERVER
  
  ## SELECTIONS BASED ON UI
  
  selectedContours <- eventReactive(input$contourGroup,{input$contourGroup})
  selectedGenders <- eventReactive(input$genderToggle,{input$genderToggle})
  selectedItems <- eventReactive(input$itemToggle,{input$itemToggle})
  selectedParticipants <- eventReactive(input$participantToggle,{input$participantToggle})
  
  ## DATA FOR PLOTS
  
  categorization_data <- reactive({
    
d %>%
    filter(Gender %in% selectedGenders() & 
           item %in% selectedItems() & 
           participant %in% selectedParticipants() &
          !is.na(Contour)) %>%
      dplyr::mutate(Contour=factor(Contour,levels=contourLevels)) %>%
      group_by(Context,Contour) %>%
      dplyr::summarise (n = n()) %>%
      dplyr::mutate(Count = n) %>%
      dplyr::mutate(Proportion = round(n / sum(n),2)) %>%
      dplyr::mutate(Percentage = 100*Proportion) %>%
      as.data.frame
})

  pitch_data <- reactive({
    averageAll %>%
      filter((Contour %in% selectedContours()) &
               (Gender %in%  selectedGenders()) &
               (item %in% selectedItems()) &
               (participant %in% selectedParticipants())
      ) %>%
      mutate(Contour, factor(Contour, levels = contourLevels))
  })
  
  naturalness_data <- reactive({
    perception %>%
      filter((Contour %in% selectedContours()) &
               (Gender %in%  selectedGenders()) &
               item.Prod %in% selectedItems() &
               participant.Prod %in% selectedParticipants()
      )
  })
  
  
  
## PLOTS
  
output$categorization_plot <- renderPlot({
    
# DotPlot of consolidated annotation
ggplot(categorization_data(), aes(x=Contour, y=Percentage,fill=Contour)) + theme_bw(base_size=12) + scale_y_continuous(breaks=seq(0, 100, 25),limits = c(-10,100)) +  geom_point(stat="identity",size=3,shape=21) + geom_text(aes(label=paste(Percentage,"%","(",Count,")",sep="")), size=3,  position=position_dodge(width=0.9), hjust=-0.15,vjust=-0.25)  + facet_grid (.~ Context) + xlab("") + ylab("") + ggtitle("Annotation of the intonational tune of the utterances") + scale_fill_manual(values = myColors) + theme(axis.text.x = element_text(angle = 45, hjust = 1))
     })
    
  #   ggplot(categorization_data(), aes(x=Contour, y=Percentage,fill=Contour)) + geom_point(stat="identity", size=2,show.legend=F,shape=21) + coord_flip() + theme_bw(base_size=12) + scale_y_continuous(breaks=seq(0, 100, 20), limits = c(-75,140)) + facet_grid (. ~ Context) + xlab("") + ylab("") + geom_text(size=3,aes(label=paste(Percentage,"% ","(",Count,")",sep="")),  position=position_dodge(width=0.9),hjust=1.2,show.legend=F) + ggtitle("Annotation of the intonational tune of the utterances for each of the three contexts") + scale_fill_manual(values = myColors)

  
  output$pitch_plot <- renderPlot({
    ggplot(pitch_data(), aes(x=sliceTimeAv, y=pitch, group=recordedFile, colour=Contour)) + theme_bw(base_size = 10) + geom_line(show.legend=F) + geom_smooth(aes(x=sliceTimeAv, y=pitch,group=1), colour="black",size=0.7) + xlab("") + ylab("Pitch (Hz)") + facet_grid(.~Context) + scale_colour_manual(values = myColors)  + ggtitle("Smoothed pitch track of utterances by context in which they were recorded")
  })
  
  output$naturalness_plot <- renderPlot({
    ggplot(naturalness_data(), aes(x=PerContextShort, y=response))  + geom_boxplot(width=0.6, notch=T)  + ylab('Naturalness Rating (1-8)') + theme_bw(base_size=12) + xlab('') + facet_grid(~ContextOriginal) + theme(axis.text.x = element_text(angle = 45, hjust = 1)) 
  })
  
  
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
  
  
  ###
  ### HOVER INFO
  ## Showing file name when hovering
  # https://gitlab.com/snippets/16220
  #
  output$hover_info <- renderUI({
    hover <- input$plot_hover
    point <- nearPoints(
        pitch_data(),
        input$plot_hover,
        threshold = 100,
        maxpoints = 1,
        addDist = TRUE
      )
    if (nrow(point) == 0)
      return(NULL)
    
    #point$recordedFile
  
    # calculate point position INSIDE the image as percent of total dimensions
    # from left (horizontal) and from top (vertical)
    left_pct <-
      (hover$x - hover$domain$left) / (hover$domain$right - hover$domain$left)
    top_pct <-
      (hover$domain$top - hover$y) / (hover$domain$top - hover$domain$bottom)

    # calculate distance from left and bottom side of the picture in pixels
    left_px <-
      hover$range$left + left_pct * (hover$range$right - hover$range$left)
    top_px <-
      hover$range$top + top_pct * (hover$range$bottom - hover$range$top) + 350

    # create style property fot tooltip
    # background color is set so tooltip is a bit transparent
    # z-index is set so we are sure are tooltip will be on top
    style <-
      paste0(
        "position:absolute; z-index:100; background-color: rgba(245, 245, 245, 0.85); ",
        "left:",
        left_px + 2,
        "px; top:",
        top_px + 2,
        "px;"
      )
    # 
    # actual tooltip created as wellPanel
    wellPanel(style = style,
              p(HTML(
                paste0(
                  "<b>   File: </b>",
                  point$recordedFile,"<br>",
                  "<b>   Contour: </b>",
                  point$Contour
                )
              )))
  })
  
  
 })
  
