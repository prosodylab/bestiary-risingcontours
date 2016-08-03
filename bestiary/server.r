library(reshape)
library(ggplot2)
library(plyr)
library(car)
library(RColorBrewer)

basepath = ''
if (Sys.getenv('HOSTNAME') == 'u15342564.onlinehome-server.com'){
  basepath = '/home/mmcauliffe/data'
} else {
  basepath = 'D:/Data'
}
basepath = '/home/mmcauliffe/data'
addResourcePath("audio", paste(basepath, "bestiary/audio", sep = '/'))

gg_color_hue <- function(n) {
  hues = seq(15, 375, length=n+1)
  hcl(h=hues, l=65, c=100)[1:n]
}

averageAll = read.csv(paste(basepath, "bestiary/averageAll.txt", sep = '/'),sep = "\t")
averageAll= subset(averageAll, !is.na(smoothedPitch))
perception = read.csv(paste(basepath, "bestiary/perception.txt", sep = '/'),sep = "\t")
perception = subset(perception,!is.na(Contour))
d=read.csv(paste(basepath, "bestiary/responses.txt", sep = '/'),sep = "\t")

server <- function(input, output) {
  
  selectedContours <- eventReactive(input$contourGroup,{input$contourGroup})
  selectedGenders <- eventReactive(input$genderToggle,{input$genderToggle})
  
  output$plot1 <- renderPlot({
    ggplot(subset(averageAll, (Contour %in% selectedContours()) & (Gender %in%  selectedGenders())), aes(x=sliceTimeAv, y=smoothedPitch, group=recordedFile, colour=Contour)) + theme_bw(base_size = 8) + geom_line(show_guide=F) + geom_smooth(aes(x=sliceTimeAv, y=smoothedPitch,group=1), colour="black",size=0.7, data = averageAll) + xlab("") + ylab("Pitch (Hz)") + facet_grid(.~Context) + scale_colour_manual(values=rev(gg_color_hue(8))) + ggtitle("Smoothed pitch track of utterances by context in which they were recorded")
    
    # Michael M. changed method for average curve to 'gam', but smooth seems more desirable?:
    # + geom_smooth(aes(x=sliceTimeAv, y=smoothedPitch,group=1), colour="black",size=0.7, data = averageAll,method='gam')
  })
  output$plot2 <- renderPlot({
    subs=subset(d, Gender %in% selectedGenders())
    subs=ddply(subs,.(Context),transform,ContextCount=length(Context))
    # 
    ptabl= ddply(subs,.(Context,Contour),summarise,Count=length(ContextCount),Percentage=round((length(Context)/mean(ContextCount)*100),1))
    #
    ptabl$Contour=factor(ptabl$Contour,levels=c("Fall","Contradiction Contour","Falling Contradiction","Verum Focus","RFR","Yes/No Rise","Incredulity Contour","Other"))
    #
    ptabl=ptabl[order(ptabl$Contour),]
    ptabl$Contour = factor(ptabl$Contour,levels(ptabl$Contour)[c(8:1)])
    #
    props=subset(ptabl,!is.na(ptabl$Contour))  
    #
    ggplot(props, aes(x=Contour, y=Percentage,colour=Contour)) + geom_point(stat="identity", size=2,show_guide=F) + coord_flip() + theme_bw(base_size=8) + scale_y_continuous(breaks=seq(0, 100, 20), limits = c(-75,140)) + facet_grid (. ~ Context) + xlab("") + ylab("") + geom_text(aes(label=paste(Percentage,"% ","(",Count,")",sep="")),  position=position_dodge(width=0.9),hjust=1.2,show_guide=F) + ggtitle("Categorization of intonational tune (based on one out of several annotations)") 
  })
  
  output$plot3 <- renderPlot({
    ggplot(subset(perception, Contour %in% selectedContours()), aes(x=Context, y=response,colour=Context))  + geom_boxplot(width=0.6, notch=T)  + xlab('Context in which utterance is played') + ylab('Naturalness Rating (1-8)') + theme_bw(base_size=8) + ggtitle("Perceptual Norming")})
  
  df <- eventReactive(input$plot_click, {
    res <- nearPoints(averageAll, input$plot_click, addDist = TRUE, maxpoints = 1, threshold = 500)
    res
  })
  
  
  output$click_info <- renderTable({
    # Because it's a ggplot2, we don't need to supply xvar or yvar; if this
    # were a base graphics plot, we'd need those.
    df()
  })
  
  output$wavfile <- renderUI({
    audioname <- paste0("audio/",as.character(df()[1,'recordedFile']))
    tags$audio(src = audioname, type = "audio/mpeg", controls=NA,autoplay=NA)
  })
  output$wavfilename <- renderUI({
    tags$div(paste0("audio/",as.character(df()[1,'recordedFile'])))
  })
  
  
  
}