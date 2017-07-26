
## HARD CODED OPTIONS FOR SUBSETS

contours <-c("Contradiction Contour","Fall","Falling Contradiction","Other","RFR","Verum Focus","Yes/No Rise" )

genders <- c("Female", "Male")

ui <- fluidPage(
  sidebarLayout(sidebarPanel(
    ## SELECTIONS FOR SUBSETS
    checkboxGroupInput("contourGroup",
                       label = h3("Contour"),
                       choices = contours,
                       selected = contours),

    checkboxGroupInput("genderToggle",
                       label = h3("Gender"),
                       choices = genders,
                       selected = genders),
    ## UI ELEMENT FOR AUDIO
    uiOutput("wavfile")

  ),
  mainPanel(
    ## PLOT SPECIFICATION
    plotOutput("pitch_plot", height = 200,
                       # Equivalent to: click = clickOpts(id = "plot_click")
                       click = "plot_click",
                       hover = "plot_hover"),
            plotOutput("naturalness_plot", height = 200,
                       # Equivalent to: click = clickOpts(id = "plot_click")
                       click = "plot3_click",
                       hover = "plot3_hover")
  )
  )
)
