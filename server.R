#-------------------------------#
#### Load data and functions ####
#-------------------------------#

server <- function(input, output, session) {
  
  vals <- reactiveValues()
  # Navbar ------------------------------------------------------------------
  shinyjs::addClass(id = "navBar", class = "navbar-right")
  
  # Intro JS ----------------------------------------------------------------
  observeEvent(input$help,
               introjs(session, options = list("nextLabel"="Next",
                                               "prevLabel"="Back",
                                               "skipLabel"="Exit"))
  )
  
  # Upload file --------------------------------------------------------
  
  dataSource <- reactive({
   # req(input$file1)
    
    inFile <- input$file1
    
    if (!is.null(inFile)){
      df <- read_excel(inFile$datapath, col_names = TRUE)
    }
    else {
      df <- read_excel(exampleData("exampleGosling.xlsx"))
    }
    
  updateCheckboxGroupInput(session, inputId = "Indicator", label = "Indicator", unique(df$indicator),
                           selected = unique(df$indicator[1]))
  
  df <- df[order(df$indicator, df$landUse), ]
  
  return(df)
  })

output$contents <- renderTable({
  dataSource()
})

# Model --------------------------------------------------------------
dataSourceSelect <- reactive({
  dataSource() %>% 
    filter(indicator %in% input$Indicator)
})


ownResultData <- reactive({
  ownResult <- setNames(data.frame(matrix(ncol = length(unique(dataSource()$landUse)) + 1, nrow = 0)), c("u", unique(dataSource()$landUse)))
  
  for (u in seq(from = 0, to = ifelse(input$maxuvalue > 10, 10, input$maxuvalue) , by = 0.5)) {
    uValue <- u
    
    init <- initScenario(dataSourceSelect(), uValue = uValue, optimisticRule = "expectation", 
                         fixDistance = ifelse(input$fixDistance == TRUE, ifelse(input$fixDistanceNum > 10, 10, input$fixDistanceNum) , uValue))
    result <- solveScenario(x = init, digitsPrecision = 6)
    ownResult <- rbind(ownResult, data.frame(u = u, result$landUse))
  }
  
  names_landUse <- unique(dataSource()$landUse)
  names(ownResult) <- c("u", names_landUse)
  
  ownResult <- round(ownResult, 3) %>% 
    gather(key = "land-use option", value = "land-use share", -u)
  
  
  
})


output$plot1 <- renderPlot({
  
  gg <- ownResultData() %>%
    mutate(landUseShare = `land-use share` * 100) %>% 
    ggplot(aes(y = landUseShare, x = u, fill = `land-use option`)) +
    geom_area(alpha = .8, color = "white") +
    labs(x = "Uncertainty level", y = "Allocated share (%)") + 
    guides(fill=guide_legend(title="")) + 
    scale_y_continuous(breaks = seq(0, 100, 10), 
                       limits = c(0, 101)) +
    scale_x_continuous(breaks = seq(0, ifelse(input$maxuvalue > 10, 10, input$maxuvalue) , 0.5),
                       limits = c(0, ifelse(input$maxuvalue > 10, 10, input$maxuvalue))) + 
    scale_fill_startrek() +
    theme_classic()+
    theme(text = element_text(size = 18),
          legend.position = "bottom")
  
  vals$gg <- gg
  
  print(gg)
  
})



output$ownResult <- renderTable(ownResultData() %>% 
                                  spread(key = "land-use option", value = "land-use share"))


output$downloadExample <- downloadHandler(
  filename = function(){"exampleGosling.xlsx"}, 
  content = function(file){
    write.xlsx(read_excel(exampleData("exampleGosling.xlsx")), file)
  }
)

output$downloadPlot <- downloadHandler(
  filename = function(){paste(input$Indicator, '.pdf', sep = '')},
  
  content = function(file){
    pdf(file, width = 8, height = 5)
    print(vals$gg)
    dev.off()
  })

output$downloadData <- downloadHandler(
  filename = function(){"C12_Portfolio.csv"}, 
  content = function(fname){
    write.csv2(ownResultData() %>% 
                 spread(key = "land-use option", value = "land-use share"), fname)
  }
)

}