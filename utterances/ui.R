library(reshape)
library(ggplot2)
library(plyr)
library(car)
library(RColorBrewer)

basepath = ''
if (Sys.getenv('HOSTNAME') == 'u15342564.onlinehome-server.com'){
  basepath = '/home/mmcauliffe/data'
} else if (Sys.getenv('HOSTNAME') == '') {
  basepath = '~/work_git/bestiary'
} else {
  basepath = 'D:/Data'
}

addResourcePath("audio", paste(basepath, "/audio", sep = '/'))

gg_color_hue <- function(n) {
  hues = seq(15, 375, length=n+1)
  hcl(h=hues, l=65, c=100)[1:n]
}

averageAll = read.csv(paste(basepath, "averageAll.txt", sep = '/'),sep = "\t")
averageAll= subset(averageAll, !is.na(smoothedPitch))
perception = read.csv(paste(basepath, "perception.txt", sep = '/'),sep = "\t")
perception = subset(perception,!is.na(Contour))
d=read.csv(paste(basepath, "responses.txt", sep = '/'),sep = "\t")


ui <- fluidPage(
  sidebarLayout(sidebarPanel(
    checkboxGroupInput("contourGroup",
                       label = h3("Contour"),
                       choices = levels(averageAll$Contour),
                       selected = levels(averageAll$Contour)),

    checkboxGroupInput("genderToggle",
                       label = h3("Gender"),
                       choices = levels(averageAll$Gender),
                       selected = levels(averageAll$Gender)),
    uiOutput("wavfile")

  ),
  mainPanel(plotOutput("plot1", height = 200,
                       # Equivalent to: click = clickOpts(id = "plot_click")
                       click = "plot_click",
                       hover = "plot_hover",
                       brush = brushOpts(
                         id = "plot1_brush"
                       )),
            plotOutput("plot3", height = 200,
                       # Equivalent to: click = clickOpts(id = "plot_click")
                       click = "plot3_click",
                       hover = "plot3_hover",
                       brush = brushOpts(
                         id = "plot3_brush"
                       ))
  )
  )
)
