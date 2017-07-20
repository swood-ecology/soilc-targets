# read in multiple sources of georeference data and return lat/long coordinates

id.county <- function(value,type){
  # require(ggmap)
  if(type == 'zip'){
    # using ggmap interface with google API
    geo_reply = geocode(value, output='all', messaging=TRUE, override_limit=TRUE)
    #     county <- geo_reply$results[[1]]$address_components[[5]]$long_name
    return(c(geo_reply$results[[1]]$geometry$location$lat, geo_reply$results[[1]]$geometry$location$lng))
    
    # # using zipcode centerpoints
    # # requires downloading dataset
    # require(readr)
    # temp <- tempfile()
    # download.file("http://federalgovernmentzipcodes.us/free-zipcode-database-Primary.csv",temp)
    # data <- read_csv(temp)
    # unlink(temp)
    # return(as.numeric(data[which(data$Zipcode==value),c('Lat','Long')]))
  }
  else if(type == 'address'){
    # inspiration for this approach from: http://www.shanelynn.ie/massive-geocoding-with-r-and-google-maps/
    # could also do directly from census: https://geocoding.geo.census.gov/geocoder/Geocoding_Services_API.html#_Toc379292356
    geo_reply = geocode(value, output='all', messaging=TRUE, override_limit=TRUE)
    #     county <- geo_reply$results[[1]]$address_components[[5]]$long_name
    return(c(geo_reply$results[[1]]$geometry$location$lat, 
             geo_reply$results[[1]]$geometry$location$lng,
             geo_reply$results[[1]]$address_components[[8]]$long_name))
  }
  else if(type == 'latlong'){
    return(value)
    # could use reverse geocoding with google API to get county information from latlong
    # require(httr)
    # return(content(GET(sprintf("http://data.fcc.gov/api/block/find?format=json&latitude=%f&longitude=%f&showall=true",value[1],value[2])))$County)
  }
}