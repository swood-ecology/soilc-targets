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
  
  # query SDA for mukey and get soil series info
  query <- paste("SELECT *
                 FROM component
                 WHERE mukey IN (",paste(unique(mu.info$mukey),collapse=","),")")
  SDA.sub <- SDA_query(query)
  
  # drop mukey components that aren't series
  SDA.sub <- SDA.sub[which(SDA.sub$compkind=='Series'),]
  
  # use soil series info to pull RaCA and KSSL data
  raca.results <- vector("list", length(SDA.sub$compname))
  kssl.results <- vector("list", length(SDA.sub$compname))
  
  for (i in 1:length(SDA.sub$compname)){
    if(try(fetchRaCA(series=SDA.sub$compname[i]),silent=T)[1]!="Error : query returned no data\n"){
      raca.results[[i]] <- try(fetchRaCA(series=SDA.sub$compname[i]),silent=T)
      
      # extract soc for RaCA
      # only include samples < 40 cm depth; calculate mean of all samples; attach series name
      raca.soc.means <- data.frame(matrix(NA, nrow=length(raca.results), ncol=2))
      names(raca.soc.means) <- c('SOC','Series')
      for (i in 1:length(raca.results)){
        if(!is.null(raca.results[[i]])){
          raca.soc.means[i,1] <- mean(raca.results[[i]]$sample[which(raca.results[[i]]$sample$sample_bottom < 25),]$soc,na.rm=T)
          raca.soc.means[i,2] <- raca.results[[i]]$pedons$taxonname[1]
        }
      }
    }
    else{
      print(paste0("No data for the ", SDA.sub$compname[i], " series exists in RaCA"))
    }  
  }
  
  for(i in 1:length(SDA.sub$compname)){
    kssl.results[[i]] <- try(fetchKSSL(series=SDA.sub$compname[i]),silent=T)  
  }
  
  # extract soc for KSSL
  kssl.soc.means <- data.frame(matrix(NA, nrow=length(kssl.results), ncol=2))
  names(kssl.soc.means) <- c('SOM','Series')
  for (i in 1:length(kssl.results)){
    kssl.soc.means[i,1] <- mean(kssl.results[[i]][which(kssl.results[[i]]$hzn_bot < 25),]$estimated_om,na.rm=T)
    kssl.soc.means[i,2] <- kssl.results[[i]]$taxonname[1]
  }
  
  # convert RaCA soc to % som
  raca.soc.means$SOM <- raca.soc.means$SOC * 1.62
  
  # compare RaCA and KSSL estimate
  
  # take weighted averages based on mukey representation and print
  weight <- SDA.sub$comppct_r
  print(paste0("RaCA SOM%: ", weighted.mean(x=raca.soc.means$SOM,w=weight,na.rm=T)))
  print(paste0("KSSL SOM%: ", weighted.mean(x=kssl.soc.means$SOM,w=weight,na.rm=T)))
  
  #return(input/target*100)
}
