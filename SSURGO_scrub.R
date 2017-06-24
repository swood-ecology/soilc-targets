# --------------------------------------------------------
# Pull county soil C data from SSURGO based on GPS point
# --------------------------------------------------------

#install.packages("soilDB")   # For querying SSURGO
#install.packages("rgdal")    # For spatial transformations
#install.packages("sp")       # For defining points

# load packages
library(soilDB)
library(sp)
library(rgdal)
library(rgeos)
library(httr)
library(jsonlite)

library(sp)
library(maps)
library(maptools)


# create mock farm location
p <- SpatialPoints(cbind(-122.315833333,37.128055556), proj4string = CRS('+proj=longlat +datum=WGS84'))

# get mukey info for point
mu.info <- SDA_make_spatial_query(p)

# query SDA for mukey
query <- paste("SELECT *
               FROM component
               WHERE mukey IN (",paste(unique(mu.info$mukey),collapse=","),")")
SDA.sub <- SDA_query(query)

