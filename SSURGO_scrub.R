# --------------------------------------------------------
# Pull county soil C data from SSURGO based on GPS point
# --------------------------------------------------------

#install.packages("soilDB")   # For querying SSURGO
#install.packages("rgdal")    # For spatial transformations
#install.packages("sp")       # For defining points

# load packages

som.score <- function(loc,type.enter,som=1){
  require(soilDB)         # For querying SSURGO and RaCA
  require(sp)             # For defining spatial points

  # determine farm location
  p <- SpatialPoints(cbind(id.county(value=loc,type=type.enter)[2],id.county(value=loc,type=type.enter)[1]), proj4string = CRS('+proj=longlat +datum=WGS84'))
  
  # get mukey info for point
  mu.info <- SDA_make_spatial_query(p)
  
  # query SDA for mukey and soil series info
  query <- paste("SELECT *
                 FROM component
                 WHERE mukey IN (",paste(unique(mu.info$mukey),collapse=","),")")
  SDA.sub <- SDA_query(query)
  
  # use soil series info to pull RaCA data
  results <- list()
  
  for (i in 1:length(SDA.sub$compname)){
    results[[i]] <- try(fetchRaCA(series=SDA.sub$compname[i]),silent=T)
  }
  return(results[[1]]$stock)
}