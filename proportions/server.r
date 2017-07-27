#### SET UP DATA ####

library(ggplot2)
library(plyr)

DATA_PATH <- file.path(getwd(), "data")

d=read.csv(paste(DATA_PATH, "responses.txt", sep = '/'),sep = "\t")

#### END DATA SETUP ####

shinyServer(function(input, output) {
  #### SERVER
  
  ## SELECTIONS BASED ON UI
  
  selectedContours <- eventReactive(input$contourGroup,{input$contourGroup})
  selectedGenders <- eventReactive(input$genderToggle,{input$genderToggle})
  
  ## DATA FOR PLOTS
  
  categorization_data <- reactive({
    subs=subset(d, Gender %in% selectedGenders())
    subs=ddply(subs,.(Context),transform,ContextCount=length(Context))
   
    ptabl= ddply(subs,.(Context,Contour),summarise,Count=length(ContextCount),Percentage=round((length(Context)/mean(ContextCount)*100),1))
    ptabl$Contour=factor(ptabl$Contour,levels=c("Fall","Contradiction Contour","Falling Contradiction","Verum Focus","RFR","Yes/No Rise","Incredulity Contour","Other"))
  
    ptabl=ptabl[order(ptabl$Contour),]
    ptabl$Contour = factor(ptabl$Contour,levels(ptabl$Contour)[c(8:1)])
    props=subset(ptabl,!is.na(ptabl$Contour))
    props})
  
  ## PLOTS
  
  output$categorization_plot <- renderPlot({
    ggplot(categorization_data(), aes(x=Contour, y=Percentage,colour=Contour)) + geom_point(stat="identity", size=2,show.legend=F) + coord_flip() + theme_bw(base_size=8) + scale_y_continuous(breaks=seq(0, 100, 20), limits = c(-75,140)) + facet_grid (. ~ Context) + xlab("") + ylab("") + geom_text(aes(label=paste(Percentage,"% ","(",Count,")",sep="")),  position=position_dodge(width=0.9),hjust=1.2,show.legend=F) + ggtitle("Categorization of intonational tune (based on one out of several annotations)") 
  })
})