
basepath = ''
if (Sys.getenv('HOSTNAME') == 'u15342564.onlinehome-server.com'){
  basepath = '/home/mmcauliffe/data'
} else {
  basepath = 'D:/Data'
}

averageAll = read.csv(paste(basepath, "bestiary/averageAll.txt", sep = '/'),sep = "\t")
averageAll= subset(averageAll, !is.na(smoothedPitch))
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
            plotOutput("plot2", height = 200,
                       # Equivalent to: click = clickOpts(id = "plot_click")
                       click = "plot2_click",
                       hover = "plot2_hover",
                       brush = brushOpts(
                         id = "plot2_brush"
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