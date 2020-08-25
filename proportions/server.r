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


#### END DATA SETUP ####

shinyServer(function(input, output) {
  #### SERVER
  
  ## SELECTIONS BASED ON UI
  
#  selectedContours <- eventReactive(input$contourGroup,{input$contourGroup})
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
      dplyr::mutate(Contour= factor(Contour,levels =contourLevels)) %>%
      group_by(Context,Contour) %>%
      dplyr::summarise (n = n()) %>%
      dplyr::mutate(Count = n) %>%
      dplyr::mutate(Proportion = round(n / sum(n),2)) %>%
      dplyr::mutate(Percentage = 100*Proportion) %>%
      as.data.frame
})
  



## PLOTS
  
output$categorization_plot <- renderPlot({
    
# DotPlot of consolidated annotation
ggplot(categorization_data(), aes(x=Contour, y=Percentage,fill=Contour)) + theme_bw(base_size=12) + scale_y_continuous(breaks=seq(0, 100, 25),limits = c(-10,100)) +  geom_point(stat="identity",size=3,shape=21) + geom_text(aes(label=paste(Percentage,"%","(",Count,")",sep="")), size=3,  position=position_dodge(width=0.9), hjust=-0.15,vjust=-0.25)  + facet_grid (.~ Context) + xlab("") + ylab("") + ggtitle("Annotation of the intonational tune of the utterances") + scale_fill_manual(values = myColors) + theme(axis.text.x = element_text(angle = 45, hjust = 1))
     })
    
 
  ## Interact with the plot by clicking

  curves_clicked <- eventReactive(input$plot_click, {
    res <- nearPoints(categorization_data(), input$plot_click, addDist = TRUE, maxpoints = 1, threshold = 500)
    res
  })
  
  # chosen_data <- reactive({
  #   d %>%
  #     filter(Gender %in% selectedGenders() & 
  #              item %in% selectedItems() & 
  #              participant %in% selectedParticipants() &
  #              !is.na(Contour)) %>%
  #     dplyr::mutate(Contour= factor(Contour,levels =contourLevels))
  # })
  
  chosen_data <- reactive({
    d %>%
      filter(Gender %in% selectedGenders() & 
               item %in% selectedItems() & 
               participant %in% selectedParticipants() &
               !is.na(Contour)) %>%
      dplyr::mutate(Contour= factor(Contour,levels =contourLevels))
  })
  
  
  ## PLAYING SOUND FILES
  output$wavfile <- renderUI({
    contexts=curves_clicked()[1,'Context']
    contours=curves_clicked()[1,'Contour']
    chosen=chosen_data() %>%  
           filter(Context %in% contexts & Contour %in% contours)
    randomExample=dplyr::sample_n(chosen,1)
    audioname1 <- paste0("audio/",as.character(randomExample$contextFile))
    audioname2 <- paste0("audio/",as.character(randomExample$recordedFile))
    tagList(
    #tags$audio(src = audioname1, type = "audio/mpeg", controls=NA,autoplay=NA),
    tags$audio(src = audioname2, type = "audio/mpeg", controls=NA,autoplay=NA)
    )
  })
  
  
  output$wavfilename <- renderUI({
    contexts=curves_clicked()[1,'Context']
    contours=curves_clicked()[1,'Contour']
    chosen= chosen_data() %>%  
      filter(Context %in% contexts & Contour %in% contours)
    randomExample=dplyr::sample_n(chosen,1)
    tags$div(paste0("audio/",as.character(randomExample$recordedFile)))
  })
  
  
  ###
  ### HOVER INFO
  ## Showing file name when hovering
  # https://gitlab.com/snippets/16220
  #
  output$hover_info <- renderUI({
    hover <- input$plot_hover
    point <- nearPoints(
        categorization_data(),
        input$plot_hover,
        threshold = 500,
        maxpoints = 1,
        addDist = TRUE
      )
    if (nrow(point) == 0)
      return(NULL)
    
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
      hover$range$top + top_pct * (hover$range$bottom - hover$range$top) + 
      80 #adjust placement of hover here

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
                  "<b> Context: </b>",
                  point$Context,
                  "<br><b> Contour: </b>",
                  point$Contour,
                  #paste0("audio/",as.character(point$recordedFile)),
                  "<br>",
                  "<br><em>Click to play random example","</em></br>"
                )
              )))
  })
  
  
})
  
