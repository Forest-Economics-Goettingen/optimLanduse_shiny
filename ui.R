
library(shiny)
library(shinydashboard)
library(dashboardthemes)
library(readxl)
library(tidyr)
library(dplyr)
library(ggplot2)
library(optimLanduse)
library(ggsci)
#library(DT)

ui <- dashboardPage(
  dashboardHeader(title = 
                    shinyDashboardLogo(
                      theme = "blue_gradient",
                      boldText = "optimLanduse",
                      mainText = "",
                      badgeText = "v1.0"
                    ),
                  tags$li(class = "dropdown",
                          tags$a(href="https://www.uni-goettingen.de/de/586895.html", target="_blank", 
                                 tags$img(src="Logo_Felap_Goe_transparant.png", height = "45px", width = "250px"))),
                  tags$li(class = "dropdown",
                          tags$a(href="", target="_blank", 
                                 tags$img(src="2015_Logo_TUM_RGB_transparant.png", height = "45px", width = "80px")))
  ),
  
  dashboardSidebar(
    tags$head(tags$style(HTML('.content-wrapper { height: 3000px !important;}'))),
    sidebarMenu(
      menuItem("Home", tabName = "home"),
      menuItem("Data", tabName = "data"),
      menuItem("Model", tabName = "model"),
      menuItem("About", tabName = "about")
      
    )
  ),
  dashboardBody(
    shinyDashboardThemes(
      theme = "blue_gradient"
    ),
    tabItems(
      tabItem("home",
              box(
                shiny::HTML("<br><br><center> <h1>How to get started</h1> </center><br>"),
                shiny::HTML("<h5> You can:<br><br><ul>
                            
                            <li>try out the package using the provided example data in the <em>Data</em>-Tab taken from Gosling et al. (2020). <br> It is a 
                            study that took place in a forest frontier region in Eastern Panama and used data from interviews with local farmers. 
                            The farmers ranked the performance of different conventional land-cover types and two agroforestry land-cover types 
                            against various socio-economic and ecological indicators. The data table contains the necessary expectations and uncertainties.
                            </li><br>
                            <li>upload your own dataset with which  <strong>strictly </strong> follows the format specifications of the example data:
                            <ul><li> Indicators for different land cover types </li></ul>
                            <ul><li> with their average expectations and uncertainties </li></ul>
                            <ul><li> and a further column with the direction for each indicator to indicate whether more or less of the indicator is desirable </li></ul> 
                            </li><br>
                            <li>go to Tab <em>Data</em> to upload the example data or your own data </li>
                            <li>go to Tab <em>Model</em> to perform the optimization and evaluate the results.</li></ul></h5>
                            <br>
                            <h4> Example of needed xlsx-file structure:</h4>"),
                tags$img(src="Example_Data.png"),
                width = 6),
              box(
                shiny::HTML("<br><br><center> <h1>Package Info</h1> </center><br>"),
                shiny::HTML("<h5>
                            This is  a graphical shiny application for the package optimLanduse to get a quick idea of the functionalities of the package. 
                            optimLanduse (version 1.0.0) has been released on CRAN and can be accessed via the  
                            <a href='https://github.com/Forest-Economics-Goettingen/optimLanduse'>project page</a>."),
                shiny::HTML("<br><br><center> <h3>Short summary</h3> </center><br>"),
                shiny::HTML("<h5><right><li> 
                            How to simultaneously combat biodiversity loss and maintain ecosystem functioning while 
                            increasing human welfare remains an open question. Multiobjective optimization approaches have proven helpful 
                            in revealing the trade-offs between multiple functions and goals provided by land-cover configurations. The R 
                            package optimLanduse provides tools for easy and systematic applications of the robust multiobjective land-cover 
                            composition optimization approach of Knoke et al. (2016).
                            </li><br>
                            <li>
                            The package includes tools to determine the land-cover composition that best balances the multiple functions a landscape 
                            can provide, and tools for understanding and visualizing how these compromises are reasoned. A tutorial on the basis of a 
                            published data set guides users through the application and highlights possible use-cases.
                            </li><br>
                            <li>
                            Illustrating the consequences of alternative ecosystem functions on the 
                            theoretically optimal landscape composition provides easily interpretable information for landscape modeling and decision 
                            making.
                            </li><br>
                            <li>
                            The package opens the approach of Knoke et al. (2016) to the community of landscape and planners and
                            provides opportunities for straightforward systematic or batch applications.  
                            </li><br></right></h5>"),
                
                shiny::HTML("<center> <h3>References </h3> </center>"),
                shiny::HTML("<h5> Knoke, T., Paul, C., Hildebrandt, P. et al. Compositional diversity of rehabilitated tropical lands supports 
                            multiple ecosystem services and buffers uncertainties. Nat Commun 7, 11877 (2016). 
                            <a href='https://doi.org/10.1038/ncomms11877'>https://doi.org/10.1038/ncomms11877</a></h5>"), 
                shiny::HTML("<h5> Gosling, E., Reith, E., Knoke, T. et al. Exploring farmer perceptions of agroforestry via multi-objective 
                optimisation: a test application in Eastern Panama. Agroforest Syst 94, 2003-2020 (2020).  
                            <a href='https://doi.org/10.1007/s10457-020-00519-0'>https://doi.org/10.1007/s10457-020-00519-0</a></h5>"), 
                
                width = 6)
              
      ),
      tabItem("data",
              box(
                fileInput("file1", "Choose xlsx file", accept = ".xlsx"),
                h5("The file used for upload must be of type xlsx. This file must also correspond to a certain structure 
                                 for further processing. You can find an example data named database.xlsx by clicking the following link:"),
                tags$a(h5("Example Data Gosling et al. (2020)"), href = "https://github.com/gross47/optimLanduse_shiny"), width = 3
              ),
              box(
                tableOutput("contents"), width = 9
              )
      ),
      tabItem("model",
              fluidRow(
                box(
                  checkboxGroupInput(inputId = "Indicator", "Indicator", "",
                                     selected = "", width = "100%"),
                  h5("Info: Please use the following Options only if you are sure what they do. Values are limited to <= 10!"),
                  checkboxInput("fixDistance", label = "Enable fixDistance function", value = TRUE),
                  numericInput("fixDistanceNum", label = "fix Distance Value", value = 3, max = 10),
                  numericInput("maxuvalue", label = "Maximum uncertainty level", value = 3, max = 10), width = 4, 
                ),
                box(plotOutput("plot1", height = 560), width = 6),
                box(tableOutput("ownResult"), width = 4),
                box(                            
                  downloadButton('downloadPlot','Download Plot'),
                  downloadButton('downloadData','Download Data'), width = 4)
              )
      ),
      tabItem("about",
              box(
                shiny::HTML("<br><br> <h3>Authors</h3> "),
                shiny::HTML("<h5><u>Package:</h5></u>"),
                shiny::HTML("<h5> 
                            Kai Husmann<sup>[1]</sup>,  
                            Volker von Gross<sup>[1]</sup>, 
                            Kai Boedeker<sup>[2]</sup>, 
                            Jasper M. Fuchs<sup>[1]</sup>, 
                            Carola Paul<sup>[1]</sup>, 
                            Thomas Knoke<sup>[2]</sup></h5>"),
                shiny::HTML("<h5><u>Dashboard:</h5></u>"),
                shiny::HTML("<h5>Volker von Gross<sup>[1]</sup>"),
                shiny::HTML("<br><br>
                            <sup>[1]</sup>Department of Forest Economics and Sustainable Land-use Planning, Georg-August University Goettingen <br>
                            <sup>[2]</sup>Institute of Forest Management, TUM School of Life Sciences Weihenstephan, Department of Life Science Systems, Technical University of Munich"),
                shiny::HTML("<br><br> <h3>Contact</h3>"),
                shiny::HTML("<h5>Mail: volker.vongross@uni-goettingen.de <br><br>
                            GitHub: <a href='https://github.com/gross47'>https://github.com/gross47</a> </h5>"),
                shiny::HTML("<br><br> <h3>Acknowledgments</h3> <br>"),
                shiny::HTML("<h5>V. v. G. was funded by the Deutsche Forschungsgemeinschaft (DFG, German Research Foundation) <br>
                            Project number 192626868 – SFB 990 in the framework of the collaborative German – Indonesian research project CRC 990.</h5>"),
                tags$li(class = "dropdown",
                        tags$a(href="https://www.uni-goettingen.de/en/310995.html", target="_blank", 
                               tags$img(src="Logos_1.png", height = "70px", width = "500px"))),
                shiny::HTML("<br><br> <h3>Data and Code</h3> <br>"),
                shiny::HTML(" <h5>optimLanduse (version 1.1.0) has been released on CRAN
                            and can be accessed via the project page 
                            <a href='https://github.com/Forest-Economics-Goettingen/optimLanduse'>
                            https://github.com/Forest-Economics-Goettingen/optimLanduse</a></h5>"), width  = 12
              )
      )
    )
  )
)

