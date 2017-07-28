# read in multiple sources of georeference data and return lat/long coordinates
# address will take zip code only

id.county <- function(value,type){
  # require(ggmap)
  if(type == 'address'){
    # inspiration for this approach from: http://www.shanelynn.ie/massive-geocoding-with-r-and-google-maps/
    # could also do directly from census: https://geocoding.geo.census.gov/geocoder/Geocoding_Services_API.html#_Toc379292356
    geo_reply = geocode(value, output='more', override_limit=TRUE)
    return(c(geo_reply$lat, geo_reply$lon,as.character(geo_reply$country)))
  }
  else if(type == 'latlong'){
    geo_reply = revgeocode(as.numeric(rev(value)), output = 'more',messaging=T, override_limit = T)
    return(c(as.numeric(value),as.character(geo_reply$country)))
  }
}