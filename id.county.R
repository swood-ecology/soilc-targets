id.county <- function(value,type){
  if(type == 'zip'){
    require(noncensus)
    data(zip_codes)
    data(counties)
    
    counties$fips <- interaction(counties$state_fips, counties$county_fips)    
    zip_codes$fips =  as.numeric(as.character(zip_codes$fips))
    
    temp = subset(zip_codes, as.numeric(zip) == value)    
    subset(counties, fips == temp$fips)
  }
  else if(type == 'latlong'){
    require(httr)
    return(content(GET(sprintf("http://data.fcc.gov/api/block/find?format=json&latitude=%f&longitude=%f&showall=true",value[1],value[2])))$County)
  }
}