# --------------------------------------------------------
# Pull county soil C data from SSURGO based on GPS point
# --------------------------------------------------------

som.score <- function(loc,type.enter,som=1){
  # # Now packages required in Shiny app file
  # require(soilDB)         # For querying SSURGO and RaCA
  # require(sp)             # For defining spatial points
  # require(rgdal)          # For determing if point is in United States

  location = id.county(value=loc, type=type.enter)
  
  # Different data for outside of the United States
  if(location[3] != 'United States'){
    return("Can't calculate other countries yet")
  }
  
  if(location[3] == 'United States'){
    # determine farm location
    p <- SpatialPoints(cbind(as.numeric(location[2]),as.numeric(location[1])), proj4string = CRS('+proj=longlat +datum=WGS84'))
    remove(location)
    
    # get mukey info for point
    mu.info <- SDA_make_spatial_query(p)
    
    # query SDA for mukey and get soil series info
    query <- paste("SELECT *
                   FROM component
                   WHERE mukey IN (",paste(unique(mu.info$mukey),collapse=","),")")
    SDA.sub <- SDA_query(query)
    
    ## print soil types
    # print("Your soil is represented by the following series:")
    # for(i in 1:length(SDA.sub$compname)){
    #   print(paste0(SDA.sub$compname[i]," (",SDA.sub$comppct_r[i],"%)"))
    # }
    
    # drop mukey components that aren't series
    SDA.sub <- SDA.sub[which(SDA.sub$compkind=='Series'),]
    
    # use soil series info to pull RaCA and KSSL data
    # raca.results <- vector("list", length(SDA.sub$compname))
    kssl.results <- vector("list", length(SDA.sub$compname))
    
    # raca.soc.means <- data.frame(matrix(NA, nrow=length(raca.results), ncol=2))
    # names(raca.soc.means) <- c('SOC','Series')
    # 
    # for (i in 1:length(SDA.sub$compname)){
    #   temp = try(fetchRaCA(series=SDA.sub$compname[i]),silent=T)
    #   if(temp[1]!="Error : query returned no data\n"){
    #     raca.results[[i]] <- temp
    #     
    #     # extract soc for RaCA
    #     # only include samples < 40 cm depth; calculate mean of all samples; attach series name
    #     for (i in 1:length(raca.results)){
    #       if(!is.null(raca.results[[i]])){
    #         raca.soc.means[i,1] <- mean(raca.results[[i]]$sample[which(raca.results[[i]]$sample$sample_bottom < 25),]$soc,na.rm=T)
    #         raca.soc.means[i,2] <- raca.results[[i]]$pedons$taxonname[1]
    #       }
    #     }
    #   }
    # }
    # remove(temp)
    
    for(i in 1:length(SDA.sub$compname)){
      temp = try(fetchKSSL(series=SDA.sub$compname[i]),silent=T)
      if(!is.null(temp)){
        kssl.results[[i]] <- temp
      }
    }
    remove(temp)
    
    # extract soc for KSSL
    kssl.soc.max <- data.frame(matrix(NA, nrow=length(kssl.results), ncol=2))
    names(kssl.soc.max) <- c('SOM','Series')
    for (i in 1:length(kssl.results)){
      if(!is.null(kssl.results[[i]])){
        kssl.soc.max[i,1] <- max(kssl.results[[i]][which(kssl.results[[i]]$hzn_bot < 25),]$estimated_om,na.rm=T)
        kssl.soc.max[i,2] <- kssl.results[[i]]$taxonname[1]
      }
    }
    
    # # convert RaCA soc to % som
    # raca.soc.means$SOM <- raca.soc.means$SOC * 1.62
    
    # take weighted averages based on mukey representation and print
    weight <- SDA.sub$comppct_r
    # print(paste0("RaCA SOM%: ", weighted.mean(x=raca.soc.means$SOM,w=weight,na.rm=T)))
    # print(paste0("KSSL SOM%: ", weighted.mean(x=kssl.soc.means$SOM,w=weight,na.rm=T)))
    
    # create data frame of all information
    final_data <- data.frame(kssl.soc.max,SDA.sub$comppct_r)
    
    return(signif((som/weighted.mean(x=kssl.soc.max$SOM,w=weight,na.rm=T))*100,4))
  }
}
