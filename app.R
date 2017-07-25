# -------------------------------------
# Soil organic matter score Shiny app
# -------------------------------------

#setwd("~/Box Sync/Work/GitHub/soilc-targets")

library(shiny)
library(soilDB)           # For querying SSURGO and RaCA
library(sp)               # For defining spatial points
library(ggmap)            # For interfacing with Google API
source("id.county.R")     # For converting addresses to latlong
source("SSURGO_scrub.R")  # Scrub USDA soils based on output from id.county


ui <- navbarPage(
  title = "Chef's Guide Soil Health Score Calculator",
  
  tabPanel(title = "Introduction",
    tags$h1("A Chef's Guide To Healthy Soil"),
    tags$p(tags$h2("Soil Health Score Calculator")),
    tags$br(),
    tags$p("Welcome to the Chef's Guide to Healthy Soil soil health score calculator."),
    tags$p("This Healthy Soil Guide aims to encourage chefs and consumers to reward farmers for using sustainable practices. 
          Soil organic matter has long been known to be a crucial component of a healthy soil.
          But just comparing farms based on their soil organic matter contents isn't good enough, because farms differ widely in their natural ability to build up soil organic matter.
          Because it's unfair to penalize farmers for their natural soil type, we've created a tool that compares a farm's soil organic matter with an esimate of the maximum amount of organic matter that soil could hold.
          This score is our Soil Health Score."),
    tags$p("If you'd like to learn more about the science behind our approach you can go to: "),
    
    tags$p(tags$a(href = "http://snappartnership.net/groups/managing-soil-carbon/", "SNAPP Soil C Group")),
    tags$p(tags$a(href = "https://github.com/swood-ecology/soilc-targets", "Source code found on GitHub"))
  ),
  
  tabPanel(title = "Data entry",
    
    tags$p("Enter the location of your farm. You can choose from 'street address', 'zipcode' and 'latitude longitude'. The latitude longitude coordinates of the specific soil sample is the most useful. The street address function is the most robust and can take any information that Google Maps would understand."),
    
    wellPanel(
      # Get geolocation
      selectInput(inputId = "type",
                  label = "Sample location type",
                  choices = c("Street address" = "address","Latitude and longitude" = "latlong",
                              "Zip code" = "zip")),
      
      textInput("loc", "Enter sample location")  
    ),
    
    tags$br(),
    tags$p("To calculate your soil health score, we need to know your percent soil organic matter. Use the slider below to select the percent soil organic matter associated with your farm."),       
    
    # Get SOM value
    wellPanel(
      sliderInput(inputId = "num", 
                  label = "Choose a soil organic matter % associated with your farm", value = 2, 
                  min = 0, max = 30, step = 0.1)  
    ),
           
    # Calculate soil health score
    actionButton(inputId = "go",
                label = "Calculate soil health score"),
           
    tags$br(),
    tags$br(),
    
    # Report soil health score
    wellPanel(textOutput("score")),
    
    tags$p("If you would like to add your data to our database, please click the button below"),       
    
    # Store data
    actionButton(inputId = "store",
                label = "Save data to Chef's Guide Database")
  ),
  
  tabPanel(title = "Results"
           
    # # Make plot of comparison with other soil types
    # plotOutput("hist")  
  )
  
)

server <- function(input,output) {

  # Calculate and print score
  data <- eventReactive(input$go, 
                        { 
                          som.score(loc=input$loc,type.enter=input$type,som=input$num) 
                          })
  output$score <- renderText( { paste("Your soil health score is: ", data()) } )
  
  # output$hist <- renderPlot({ hist(data()) }) # code for generating histogram
}

shinyApp(ui = ui, server = server)
