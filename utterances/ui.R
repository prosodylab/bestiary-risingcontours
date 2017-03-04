

contours <-c("Contradiction Contour","Fall","Falling Contradiction","Other","RFR","Verum Focus","Yes/No Rise" )

genders <- c("Female", "Male")

ui <- fluidPage(
  sidebarLayout(sidebarPanel(
    checkboxGroupInput("contourGroup",
                       label = h3("Contour"),
                       choices = contours,
                       selected = contours),

    checkboxGroupInput("genderToggle",
                       label = h3("Gender"),
                       choices = genders,
                       selected = genders),
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
