# -------------------------------------
# Soil organic matter score Shiny app
# -------------------------------------

setwd("~/Box Sync/Work/GitHub/soilc-targets")

library(shiny)
library(soilDB)         # For querying SSURGO and RaCA
library(sp)             # For defining spatial points
library(ggmap)          # For interfacing with Google API
source("id.county.R")
source("SSURGO_scrub.R")

ui <- fluidPage(
  titlePanel("Chef's Soil Health Guide Soil Health Score"),
  
  sidebarLayout(
    
    # *Input() functions
    sidebarPanel(
      
      # Get geolocation
      selectInput(inputId = "type",
                  label = "Sample location type",
                  choices = c("Street address" = "address",
                              "Latitude and longitude" = "latlong",
                              "Zip code" = "zip")),
      textInput("loc", "Enter sample location", "ex. 370 Prospect St New Haven, CT 06511"),
      
      # Get SOM value
      sliderInput(inputId = "num", 
                  label = "Choose a soil organic matter % associated with your farm", 
                  value = 2, min = 0, max = 30, step = 0.1),
      
      # Calculate soil health score
      actionButton(inputId = "go",
                   label = "Calculate soil health score")
      
      # # Store data
      # actionButton(inputId = "store",
      #              label = "Save data to Chef's Guide Database"),
    ),
  
    # *Output() functions
    mainPanel(
      # Report soil health score
      textOutput("score")
    
      # # Make plot of comparison with other soil types
      # plotOutput("hist")  
    )
  )
)

server <- function(input,output) {

  # Calculate and print score
  data <- eventReactive(input$go, 
                        { som.score(loc=input$loc,type.enter=input$type,som=input$num) })
  
  output$score <- renderText( {paste("Your soil health score is: ", data())} )
  
  #output$score <- eventReactive(input$go, { multiprintFun() } )
  
  # multiprintFun <- renderText({
  #   "Your soil health score is: ";
  #   print(data())
  # })
  
  # output$hist <- renderPlot({ hist(data()) }) # code for generating histogram
}

shinyApp(ui = ui, server = server)