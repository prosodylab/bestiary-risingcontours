
genders <- c("Female", "Male")

ui <- fluidPage(
  sidebarLayout(sidebarPanel(
    checkboxGroupInput("genderToggle",
                       label = h3("Gender"),
                       choices = genders,
                       selected = genders),
    uiOutput("wavfile")

  ),
  mainPanel(plotOutput("plot2", height = 200,
                       # Equivalent to: click = clickOpts(id = "plot_click")
                       click = "plot2_click",
                       hover = "plot2_hover",
                       brush = brushOpts(
                         id = "plot2_brush"
                       ))
  )
  )
)
