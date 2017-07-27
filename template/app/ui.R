
## HARD CODED OPTIONS FOR SUBSETS

sounds <- c("a", "b", "c")

ui <- fluidPage(
  sidebarLayout(sidebarPanel(
    ## SELECTIONS FOR SUBSETS
    checkboxGroupInput("soundToggle",
                       label = h3("Sound"),
                       choices = sounds,
                       selected = sounds)
    
  ),
  mainPanel(
    ## PLOT SPECIFICATION
    plotOutput("plot1", height = 200,
               # Equivalent to: click = clickOpts(id = "plot_click")
               click = "plot1_click",
               hover = "plot1_hover")
  )
  )
)