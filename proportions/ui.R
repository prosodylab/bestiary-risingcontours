
## HARD CODED OPTIONS FOR SUBSETS

genders <- c("Female", "Male")

ui <- fluidPage(
  sidebarLayout(sidebarPanel(
    ## SELECTIONS FOR SUBSETS
    checkboxGroupInput("genderToggle",
                       label = h3("Gender"),
                       choices = genders,
                       selected = genders)

  ),
  mainPanel(
    ## PLOT SPECIFICATION
    plotOutput("categorization_plot", height = 200,
                       # Equivalent to: click = clickOpts(id = "plot_click")
                       click = "plot2_click",
                       hover = "plot2_hover")
  )
  )
)
