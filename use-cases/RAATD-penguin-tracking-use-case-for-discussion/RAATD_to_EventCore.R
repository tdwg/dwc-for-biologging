### DRAFT

#==============================================================
#
# biodiversity.aq data processing protocol for the RAATD data
#
#==============================================================

# Setting up
#---------------------------------------------
#libraries
library(readxl)
library(stringr)
library(worrms)
library(tidyr)
library(dplyr)
library(mapview)
library(sp)
library(rgeos)

# file directory
loc <- "/Users/msweetlove/Royal Belgian Institute of Natural Sciences/Royal Belgian Institute of Natural Sciences/Anton Van de Putte - data_processing/02_interim/RAATD"
loc_files <- list.files(paste(loc, "02_interim", sep="/"));loc_files

# input file name :
fl <- "RAATD_metadata.csv"
datafl <- setdiff(loc_files, fl)

# read data
coreData <- read.csv(paste(loc, "02_interim", fl, sep="/"));head(coreData)

# Event Core
#---------------------------------------------
head(coreData)
colnames(coreData)

### example just for PANGEA records
coreData<-coreData[1:29,]

eventCore <- data.frame(eventID = paste("capture", coreData$individual_id,sep=":"),
                        parentEventID = "",
                        eventRemarks = "",
                        datasetID = coreData$dataset_identifier,
                        samplingProtocol = paste("capture for bio-logging", 
                                                 paste("device type= ", coreData$device_type, sep=""), 
                                                 paste("device id= ", coreData$device_id, sep=""),
                                                 sep=":"),
                        year = coreData$deployment_year,
                        month = coreData$deployment_month,
                        day = coreData$deployment_day,
                        eventDate = "", 
                        eventTime = coreData$deployment_time,
                        startDayOfYear = "",
                        endDayOfYear = "",
                        locality = coreData$deployment_site,
                        decimalLatitude=coreData$deployment_decimal_latitude,
                        decimalLongitude=coreData$deployment_decimal_longitude,
                        geodeticDatum = rep("WGS84", nrow(coreData)),
                        footprintWKT = "",
                        license = rep("CC BY 4.0", nrow(coreData)),
                        stringsAsFactors = FALSE)


#eventDate  as [YYYY]-[MM]-[DD]T[hh]:[mm]
for(i in 1:nrow(eventCore)){
  if(nchar(eventCore[i,]$year)==4){
    yr <- eventCore[i,]$year
    if(!is.na(eventCore[i,]$month) & eventCore[i,]$month != ""){
      if(nchar(eventCore[i,]$month)==2){
        mnt <- eventCore[i,]$month
      }else if(nchar(eventCore[i,]$month)==1){
        mnt <- paste("0", eventCore[i,]$month, sep="")
      }
      if(!is.na(eventCore[i,]$day) & eventCore[i,]$day != ""){
        if(nchar(eventCore[i,]$day)==2){
          dy <- eventCore[i,]$day
        }else if(nchar(eventCore[i,]$day)==1){
          dy <- paste("0", eventCore[i,]$day, sep="")
        }
        if(!is.na(eventCore[i,]$eventTime) & eventCore[i,]$eventTime != ""){
          eventCore[i,]$eventDate <- paste(yr, "-", mnt, "-", dy,"T", eventCore[i,]$eventTime, sep="")
        }else{
          eventCore[i,]$eventDate <- paste(yr, "-", mnt, "-", dy, sep="")
        }
      }else{
        eventCore[i,]$eventDate <- paste(yr, "-", mnt, sep="")
      }
    }else{
      eventCore[i,]$eventDate <- yr
    }
  }else{
    eventCore[i,]$eventDate <- ""
  }
}



#eventRemarks to store keep_or_not info, comments, data contacts and contact emails
for(i in 1:nrow(coreData)){
  msg <- paste("individual_id= ", coreData[i,]$individual_id, sep="")
  if(tolower(coreData[i,]$keepornot)=="discard"){
    msg <- paste(msg, " |analysis remark= not used in analyses", sep="")
  }
  if(!is.na(coreData[i,]$comments) &&
     tolower(coreData[i,]$comments)!="" &
     coreData[i,]$comments != "NA"){
    msg <- paste(msg, " |comments= ", coreData[i,]$comments, sep="")
  }
  if(!is.na(coreData[i,]$data_contact) &&
     tolower(coreData[i,]$data_contact)!="" &
     coreData[i,]$data_contact != "NA"){
    msg <- paste(msg, " |data_contact= ", coreData[i,]$data_contact, sep="")
  }
  if(!is.na(coreData[i,]$contact_email) &&
     tolower(coreData[i,]$contact_email)!="" &
     coreData[i,]$contact_email != "NA"){
    msg <- paste(msg, " |contact_email= ", coreData[i,]$contact_email, sep="")
  }
  eventCore[i,]$eventRemarks <- msg
}


# occurrence extension
#---------------------------------------------
# prep coredata
coreData$eventID <- eventCore$eventID

# load tracking data into one file
data_files <- paste("RAATD", unique(coreData$abbreviated_name), "standardized.csv", sep="_")
data_x<-data.frame()
for(f in 1:length(data_files)){
  data_f <- read.csv(paste(loc, "02_interim", data_files[f], sep="/"), header=TRUE)
  data_x <- dplyr::bind_rows(data_x, data_f)
}

data_x <- data_x[data_x$individual_id %in% coreData$individual_id,]

occurrenceExtension <- data.frame(occurrenceID = paste(data_x$individual_id, "deployment", 
                                                     stringr::str_pad(1:nrow(data_x), nchar(nrow(data_x)), pad = "0"), 
                                                     sep=":"),
                                 datasetID = unname(unlist(sapply(data_x$individual_id, FUN = function(x){
                                   gsub(x,coreData[coreData$individual_id==x,]$dataset_identifier,x)}))),
                                 type = rep("deployment", nrow(data_x)),
                                 modified = rep(Sys.Date(), nrow(data_x)),
                                 basisOfRecord = rep("MachineObservation", nrow(data_x)),
                                 eventID = unname(unlist(sapply(data_x$individual_id, FUN = function(x){
                                   gsub(x,coreData[coreData$individual_id==x,]$eventID,x)}))),
                                 year = data_x$year,
                                 month = data_x$month,
                                 day = data_x$day,
                                 eventTime = data_x$time,
                                 eventDate = "",
                                 decimalLatitude = data_x$decimal_latitude,
                                 decimalLongitude = data_x$decimal_longitude,
                                 fieldNotes = "",
                                 scientificName = unname(unlist(sapply(data_x$individual_id, FUN = function(x){
                                   gsub(x,coreData[coreData$individual_id==x,]$scientific_name,x)}))),
                                 scientificNameID = "", 
                                 vernacularName = unname(unlist(sapply(data_x$individual_id, FUN = function(x){
                                   gsub(x,coreData[coreData$individual_id==x,]$common_name,x)}))),
                                 lifeStage = unname(unlist(sapply(data_x$individual_id, FUN = function(x){
                                   gsub(x,coreData[coreData$individual_id==x,]$age_class,x)}))),
                                 sex = unname(unlist(sapply(data_x$individual_id, FUN = function(x){
                                   gsub(x,coreData[coreData$individual_id==x,]$sex,x)}))),
                                 stringsAsFactors = FALSE)

#fieldNotes
for(i in 1:nrow(data_x)){
  msg <- ""
  if(!is.na(data_x[i,]$breeding_stage) &&
     tolower(data_x[i,]$breeding_stage)!="" &
     data_x[i,]$breeding_stage != "NA"){
     msg <- paste(msg, "breeding_stage= ", data_x[i,]$breeding_stage, sep="")
  } 
  if(!is.na(data_x[i,]$location_quality) &&
     tolower(data_x[i,]$location_quality)!="" &
     data_x[i,]$location_quality != "NA"){
    msg <- paste(msg, "| location_quality= ", data_x[i,]$location_quality, sep="")
  } 
  msg <- gsub("^\\| ", "", msg)
  occurrenceExtension[i,]$fieldNotes <- msg
}


#scientificNameID
taxid_key <- data.frame(taxname = unique(coreData$scientific_name), scientificNameID=NA)
for(nc in 1:nrow(taxid_key)){
  taxon<-as.character(taxid_key[nc,]$taxname)
  if(!taxon %in% c("", "NA", NA)){
    taxid <- tryCatch({
      tx <- worrms::wm_name2id(taxon)
    }, error = function(e){
      tx <- ""
    }
    ) 
    if(taxid != ""){
      taxid<-paste("urn:lsid:marinespecies.org:taxname:", taxid, sep="")
    }
    taxid_key[nc,]$scientificNameID <- taxid
  }
}

occurrenceExtension$scientificNameID <- unname(unlist(sapply(as.character(occurrenceExtension$scientificName), FUN = function(x){
  gsub(x,taxid_key[taxid_key$taxname==x,]$scientificNameID,x)})))

#eventDate  as [YYYY]-[MM]-[DD]T[hh]:[mm]
for(i in 1:nrow(occurrenceExtension)){
  if(nchar(occurrenceExtension[i,]$year)==4){
    yr <- occurrenceExtension[i,]$year
    if(!is.na(occurrenceExtension[i,]$month) & occurrenceExtension[i,]$month != ""){
      if(nchar(occurrenceExtension[i,]$month)==2){
        mnt <- occurrenceExtension[i,]$month
      }else if(nchar(occurrenceExtension[i,]$month)==1){
        mnt <- paste("0", occurrenceExtension[i,]$month, sep="")
      }
      if(!is.na(occurrenceExtension[i,]$day) & occurrenceExtension[i,]$day != ""){
        if(nchar(occurrenceExtension[i,]$day)==2){
          dy <- occurrenceExtension[i,]$day
        }else if(nchar(occurrenceExtension[i,]$day)==1){
          dy <- paste("0", occurrenceExtension[i,]$day, sep="")
        }
        if(!is.na(occurrenceExtension[i,]$eventTime) & occurrenceExtension[i,]$eventTime != ""){
          occurrenceExtension[i,]$eventDate <- paste(yr, "-", mnt, "-", dy,"T", occurrenceExtension[i,]$eventTime, sep="")
        }else{
          occurrenceExtension[i,]$eventDate <- paste(yr, "-", mnt, "-", dy, sep="")
        }
      }else{
        occurrenceExtension[i,]$eventDate <- paste(yr, "-", mnt, sep="")
      }
    }else{
      occurrenceExtension[i,]$eventDate <- yr
    }
  }else{
    occurrenceExtension[i,]$eventDate <- ""
  }
}

# Back to the eventCore
#---------------------------------------------                                
# footprintWKT in eventCore
# POLYGON of track
for(i in 1:nrow(eventCore)){
print(i)
  coords <- data.frame(x=occurrenceExtension[occurrenceExtension$eventID==eventCore[i,]$eventID,]$decimalLatitude,
                       y=occurrenceExtension[occurrenceExtension$eventID==eventCore[i,]$eventID,]$decimalLongitude,
                       year=occurrenceExtension[occurrenceExtension$eventID==eventCore[i,]$eventID,]$year,
                       month=occurrenceExtension[occurrenceExtension$eventID==eventCore[i,]$eventID,]$month,
                       day=occurrenceExtension[occurrenceExtension$eventID==eventCore[i,]$eventID,]$day)
  coords$date <- paste(coords$year, coords$month, coords$day, sep="-")
  keep<-c()
  pastdates<-c()
  for(cx in 1:nrow(coords)){
    if(!coords[cx,]$date %in% pastdates){
      keep<-c(keep, cx)
      pastdates <- coords[cx,]$date
    }
  }
  coords <- coords[keep,]
  dates <- coords[order(coords[,"year"], coords[,"month"], coords[,"day"]),]
  mindate <- dates[1,]$date
  maxdate <- dates[nrow(dates),]$date
  coords <- as.matrix(coords[,c("x", "y")])
  polygx <- mapview::coords2Polygons(coords, hole=FALSE, ID=eventCore[i,]$eventID)
  eventCore[i,]$footprintWKT <- writeWKT(polygx)
  eventCore[i,]$startDayOfYear <- mindate
  eventCore[i,]$endDayOfYear <- maxdate
}


# finalize
#---------------------------------------------

# manually override the species retrieved for Mirounga leonina as per https://github.com/tdwg/dwc-for-biologging/issues/19
condition<-occurrenceExtension[occurrenceExtension$scientificName=="Mirounga leonina",]
occurrenceExtension[condition,]$scientificNameID<-"urn:lsid:marinespecies.org:taxname:231413"


#save data to processed
write.csv(eventCore, paste(loc, "03_processed","RAATD_eventCore.csv", sep="/"), na="", row.names = FALSE)
write.csv(occurrenceExtension, paste(loc, "03_processed","RAATD_occurrenceExtension.csv", sep="/"), na="", row.names = FALSE)


