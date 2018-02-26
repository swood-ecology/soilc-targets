# -------------------------------------
# Soil organic matter score Shiny app
# -------------------------------------

## To add
# 1. Shiny Google Maps integration to allow user to draw AOI for location.
#    Specifically, take point integrated, draw a map, and give them option to draw AOI
# 2. In results, generate table of soil series and properties for mukey
#    To do this, split SSURGO_scrub.R into two files: one that pulls series info
#    and another that pulls C data
# 3. Build in way to upload multiple samples for a farm.
# 4. Build in way to upload other data. 
#    Could allow upload of whole Cornell soil health report and use for more specific data
# 5. Build in Jon Sanderman's data as a reference--SoilGrids BD data for <10%OM; otherwise pedo-transfer function
# 6. Build in SoilGrids buffer approach
# 7. In results, plot histogram of data and put line corresponding with farm
# 8. Add line for Sanderman estimate of location

library(shiny)                # For making Shiny app
library(soilDB)               # For querying SSURGO, KSSL and RaCA
library(sp)                   # For defining spatial points
library(ggmap)                # For interfacing with Google API
library(rgeos)                # For creating buffer area around points
source("get.location.R")      # For converting addresses to latlong
source("scoring.functions.R") # Scrub USDA soils based on output from id.county


ui <- navbarPage(
  title = "Soil organic carbon targets",
  
  tabPanel(title = "Introduction",
    tags$h1("Developing local-level soil organic carbon targets"),
    tags$br(),
    tags$h5("THIS PROJECT IS STILL IN BETA PHASE."), 
    tags$h5("PLEASE SEND ALL COMMENTS TO STEPHEN.WOOD [AT] TNC.ORG OR FILE AN ISSUE ON ", tags$a(href = "https://github.com/swood-ecology/soilc-targets", "GITHUB")),
    tags$br(),
    tags$h3("Background"),
    tags$br(),
    tags$p("There is growing interest in the metaphor of soil health as a means to promote the sustainable management 
          of agriculture. Hand-in-hand with this interest in soil health, there is a growing interest in managing 
          agricultural lands to build soil carbon, which is one of the main arbiters of healthy soil."),

    tags$p("Organic matter is central to healthy soil because it is the nexus of the physical, chemical, and biological 
          components of soil. It is connected to the physical because it binds water and creates a porous physical 
          structure in which plants can thrive. It is connected to the biological because it provides an energy source to 
          organisms belowground that cannot photosynthesize and derive energy on their own. And it is connected to the 
          chemical because the breakdown of organic matter releases elements like nitrogen, phosphorus, and micronutrients 
          that plants require for growth."),
    
    tags$p("Because of its links to the biological, physical, and chemical components of soil, organic matter is central to
          many of the human and environmental outcomes associated with agriculture. On the human side, it contributes to crop 
          yield, yield stability, and the nutritional and flavor composition of food items. On the environmental side, building 
          up soil organic matter can: reduce erosion of soil minerals into water systems, reduce leaching of soluble nutrients into 
          water systems; and temporarily remove greenhouse gases from the atmosphere"),

    tags$p("Soil organic matter is also an essential indicator of healthy soils because it is something that we can 
          increase—and decrease—based on how we manage land. The fact that it is both biophysically important and responsive to 
          management makes soil organic matter a crucial soil property for management. There is broad consensus that, for row-crop 
          agriculture, building soil organic matter would benefit soil health."),
           
    tags$p("But just comparing lands based on their soil organic matter contents isn't good enough, because farms differ widely in 
          their natural ability to build up soil organic matter. Because it's unfair to penalize land owners for their natural soil type, 
          we've created a tool that uses public data to estimate a possible maximum soil carbon level for a particular location. This 
          number could then be used to normalize soil organic matter levels for comparison amongst farms."),
    tags$br(),
    tags$br(),
    tags$p("This project is part of a Science for Nature and People Partnership working group on soil carbon: "),
    tags$p(tags$a(href = "https://snappartnership.net/teams/managing-soil-organic-carbon/", "SNAPP Soil C Group")),
    tags$p("You can find all of the code for this project on GitHub: "),
    tags$p(tags$a(href = "https://github.com/swood-ecology/soilc-targets", "Source code"))
  ),
  
  tabPanel(title = "Data entry",
    
    tags$p("Enter the location of your farm. You can choose from 'street address', 'zipcode' and 'latitude longitude'. The latitude longitude coordinates of the specific soil sample is the most useful. The street address function is the most robust and can take any information that Google Maps would understand."),
    
    wellPanel(
      # Get geolocation
      selectInput(inputId = "type",
                  label = "Sample location type",
                  choices = c("Street address or zipcode" = "address",
                              "Latitude and longitude" = "latlong")),
      
      textInput("loc", "Enter sample location")  
    ),
    
    # TO ADD GOOGLE MAP FOR GENERATION AOI: https://blog.rstudio.com/2015/06/24/leaflet-interactive-web-maps-with-r/
    # http://rstudio.github.io/leaflet/
    
    tags$br(),
    tags$p("To calculate your normalized soil carbon score, we need to know your percent soil organic matter. Use the slider below to select the percent soil organic matter associated with your farm."),       
    
    # Get SOM value
    wellPanel(
      sliderInput(inputId = "num", 
                  label = "Choose a soil organic matter % associated with your farm", value = 2, 
                  min = 0, max = 30, step = 0.1)  
    ),
           
    # Calculate normalized soil carbon score
    actionButton(inputId = "go",
                label = "Calculate normalized soil carbon score"),
           
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
  ),
  
  tabPanel(title = "Methods",
    tags$h1("Our approach"),
    tags$br(),
    tags$p("Comparing organic matter levels across farms is misleading because different 
          soils have different innate capacities to store certain types of organic matter. 
          Soils with high amounts specific surface area--such as clayey soils--generally have much higher levels 
          of organic matter than soils that are sandy. This is because clay minerals can bind organic matter on their 
          surfaces and can be assembled into aggregates that protect organic matter. Sand minerals, by contrast, have 
          very little ability to store organic matter. This is part of the reason why extremely sandy soils—like at the 
          coast—are not highly productive farmland."),
    tags$p("Because of these different capacities of different soils to hold carbon, a sandy soil with 2% soil organic matter 
          would be rich in organic matter; by contrast, a clayey soil with the same amount of organic matter could be considered 
          degraded. Thus, only scoring farms based on organic matter concentrations would penalize farms based on their address, which is misleading."),
    tags$h3("Defing the soil organic matter target"),
    tags$p("Determining what a given soil’s organic matter level could be is challenging. This is challenging because the publicly 
           available soils data within the United States—and elsewhere in the world—is too coarse in resolution to determine reliably 
           what a particular farm’s soil type is, without going to that farm and doing intensive sampling. Thus, we have to rely on 
           best guesses of what a particular soil type likely is, based on sampling elsewhere and knowledge about certain features of 
           a location, like topography, climate, and vegetation type. But even if we had perfect knowledge of what soil type was present, 
           we still lack the knowledge necessary of how much organic matter could be achieved for a specific soil type, as discussed above. 
           To tackle this problem, we adopt three separate approaches, described below."),
    tags$h4("SSURGO"),
    tags$p("The United States Department of Agriculture has developed a soil classification system that allows us to name specific soils using 
          terms that range from general to very specific. This is much like the way that biological species are named by Kingdom, Phylum, Class, 
          Order, Famiy, Genus, and Species. Soils are classified based on Order, Sub-order, Great group, Group, and Series."),
    tags$p("In this approach, we use a GPS location for each farm and pass that to the web-based USDA SSURGO data platform. For the GPS location, 
          we pull information on the soil series present. Since we cannot know with certainty the exact soil series, we instead collect the most 
          likely series for that particular location. For each soil series in the list, we collect from the same database the maximum soil carbon 
          level contained at a depth of up to 25 cm for that soil series. Then we estimate soil organic matter from soil carbon based on a scalar 
          conversion, where soil organic matter is 62% carbon. We then calculate a weighted average of the soil organic matter scores based on the 
          likelihood of all of the soil series for that location."),
    tags$p("The advantage of this approach is that it is rooted in a strong, mechanistic hypothesis that soils that are similar—i.e. are of the same 
           series—should have similar organic matter levels. The downside is that there are so many soil series that soil carbon levels are sparse for 
           each series and in many cases there are not enough data to calculate a reliable score."),
    tags$br(),
    tags$h4("SoilGrids"),
    tags$p("STILL IN DEVELOPMENT"),
    tags$br(),
    tags$h4("Sanderman et al (PNAS 2017)"),
    tags$p("STILL IN DEVELOPMENT")
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
