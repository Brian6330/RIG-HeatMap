# Netatmo Preprocessing

# This script loads and formats the temperature measurements from the bicycle campaign (bicycle) in August 2018 and the corresponding data
# from the Netatmo citizen weather stations (cws_be_2019) and the loggers of Moritz Gublers PhD Project (log).

#  A quick quality check for bicycle data is also included


# SET WORKING DIRECTORY
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# install libraries
library("measurements") #for converting lat/lon in degrees,min,sec to decimal degrees
library("tidyverse") # for data manipulation
library("dplyr")
library("raster") # for distance calculations
library("data.table") # for data table manipulations
library("Metrics") # for statistical calculations
library("lubridate")

# Read data ---------------------------------------------------------------

### READ THE BICYCLE DATA (bicycle) ###

bicycle <- read.csv(file = "./Raw Data/Transekt_Juni_2019/1.csv",
                    stringsAsFactors = FALSE,
                    skipNul=TRUE)

### generate timestamp CEST

# add new column
bicycle$dateAndTime <- paste(bicycle$DATE,bicycle$TIME)
bicycle$TIMESTAMP_CEST <-  strptime(bicycle$dateAndTime, tz = "GMT"
                                    , format = "%y%m%d %H%M%S")
# to POSIXct format
bicycle$TIMESTAMP_CEST <- as.POSIXct(bicycle$TIMESTAMP_CEST, tz = "GMT")

# force to tz Europe/Berlin (=CEST) which changes times by +2h
bicycle$TIMESTAMP_CEST <- with_tz(bicycle$TIMESTAMP_CEST, "Europe/Berlin")


# 
# # define the transects (Z being the stops (at the GIUB or elsewhere), and A,B, C being the actual transects)
# 
# Z0 <- c(1:30); A1 <- c(31:385); Z1 <- c(386:463); B1 <- c(464:717); Z2 <- c(718:739); C1 <- c(740:1204)
# Z3 <- c(1205:1283); A2 <- c(1284:1700); Z4 <- c(1701:1713); B2 <- c(1714:2122); Z5 <- c(2123:2140); C2 <- c(2141:2745)
# A3 <- c(2746:3104); Z6 <- c(3105:3122); B3 <- c(3123:3574); Z7 <- c(3575:3584); C3 <- c(3585:4026)
# Z8 <- c(4027:4048); A4 <- c(4049:4509); Z9 <- c(4510:4542); B4 <- c(4543:5032); Z10 <- c(5033:5042); C4 <- c(5043:5490)
# Z11 <- c(5491:5546); B5 <- c(5547:5993); C5 <- c(5994:6435); Z12 <- c(6436:6776)


# add column ROUTE and fill it with values as defined above
# 
# Route <- c(rep("Z0", length(Z0)),rep("A1", length(A1)),rep("Z1", length(Z1)),rep("B1", length(B1)),
#            rep("Z2", length(Z2)) ,rep("C1", length(C1)),rep("Z3", length(Z3)),
#            rep("A2",length(A2)),rep("Z4", length(Z4)),
#            rep("B2", length(B2)),rep("Z5", length(Z5)),rep("C2", length(C2)),
#            rep("A3", length(A3)),rep("Z6", length(Z6)),rep("B3", length(B3)),
#            rep("Z7", length(Z7)),rep("C3", length(C3)),rep("Z8", length(Z8)),rep("A4", length(A4)),
#            rep("Z9", length(Z9)),rep("B4", length(B4)),rep("Z10", length(Z10)),rep("C4", length(C4)),
#            rep("Z11", length(Z11)),rep("B5", length(B5)),rep("C5", length(C5)),rep("Z12", length(Z12)))
# bicycle$Route <- Route
# rm(Z0,Z1,Z2, Z3, Z4, Z5, Z6, Z7, Z8, Z9, Z10, Z11, Z12);
# rm(A1,A2, A3, A4, B1,B2,B3,B4,B5,C1,C2,C3,C4,C5); rm(Route,i)



### READ THE NETATMO CWS DATA (cws) FROM July (07) 2019 ###

#read temperature time series of individual stations
cws_be_2019 <- read.csv(file = "Raw Data/Netatmo_Data/cws_bern_ta_level_o1_2019_JJA_UTM.csv",
                        sep = ",",
                        na.strings = "NAN")


### generate timestamps

# convert time_orig to seperate vector and convert to proper character format
time_orig_temp <- as.data.frame(cws_be_2019$time_orig)

# keep NA as NA, convert the rest
time_orig_temp <- as.data.frame(apply(time_orig_temp, 2,
                                      function(x) {ifelse(is.na(x), NA, as.character(paste(substr(x,1,10), substr(x,12,19),sep = " ")))}))


# add temporary time vector back to the cws_be_2019 data frame and delete it
time_orig_temp <- as.vector(time_orig_temp$`cws_be_2019$time_orig`)
cws_be_2019$time_orig <- (time_orig_temp); rm(time_orig_temp)

# change format of (hourly) time column
cws_be_2019$time <- as.character(cws_be_2019$time)


## convert cws time to POSIXct and set timezone to gmt plus 2 (= utc plus 2, = cest)
# time_orig
cws_be_2019$time_orig <- as.POSIXct(cws_be_2019$time_orig, tz = "UTC") # convert to POSIXct
attributes(cws_be_2019$time_orig)$tzone <- "Europe/Berlin"

# The following line is for checking the output
attributes(cws_be_2019$time_orig)$tzone; cws_be_2019$time_orig[1:20] # time zone is CEST = Europe/Berlin (time should have shifted to 2h later)

# time (hourly)
cws_be_2019$time <- as.POSIXct(cws_be_2019$time, tz = "UTC") # convert to POSIXct
attributes(cws_be_2019$time)$tzone <- "Europe/Berlin"

# The following line is for checking the output
attributes(cws_be_2019$time)$tzone; cws_be_2019$time[1:20] # time zone is CEST = Europe/Berlin


# only keep cws files from the time period of the bicycle transect time
# this changes the format of the "time" column. Should be ok, but be aware
cws_be_2019 <- cws_be_2019[cws_be_2019$time < "2019-06-27 16:00:00" 
                           & cws_be_2019$time >= "2019-06-26 20:00:00",]

#### READ THE LOGGER DATA FROM MORITZ GUBLERS PHD PROJECT (log) ###
#read logger measurements
log <- read.csv(file = "Raw Data/Loggerdaten_2019_JJA/Data_2019_compiled.csv",
                stringsAsFactors = FALSE)

# read logger metadata
log_meta <- read.csv2(file = "Raw Data/Loggerdaten_2019_JJA/Standorte_2019_DEF.csv",
                      header = TRUE, sep = ",", stringsAsFactors = F)

#change all temperature values to numeric
for(i in 2: length(log[1,])){
  log[,i] <- as.numeric(as.character(log[,i]))
}


### create timestamps for log

#rename the col (is this just a difference in name or is this a wrong timestamp?)
names(log)[endsWith(names(log), "..time")] <- "date_time_gmt_plus_2"

# convert the two different time formats to the same one (differentiate them by string length using "nchar")
for (i in 1:length(log$date_time_gmt_plus_2)){
  if (nchar(log$date_time_gmt_plus_2[i]) == 17){
    log$date_time_gmt_plus_2[i] <-as.character(paste("20",(substr(log$date_time_gmt_plus_2[i],7,8)),"-",substr(log$date_time_gmt_plus_2[i],4,5),"-"
                                                     ,substr(log$date_time_gmt_plus_2[i],1,2)," ",substr(log$date_time_gmt_plus_2[i],10,11),":"
                                                     ,substr(log$date_time_gmt_plus_2[i],13,14),":"
                                                     ,"00"," ",substr(log$date_time_gmt_plus_2[i],16,17), sep = ""))}
  else {log$date_time_gmt_plus_2[i] <- as.character(paste("20",(substr(log$date_time_gmt_plus_2[i],7,8)),"-",substr(log$date_time_gmt_plus_2[i],1,2),"-"
                                                          ,substr(log$date_time_gmt_plus_2[i],4,5)," ",substr(log$date_time_gmt_plus_2[i],10,11),":"
                                                          ,substr(log$date_time_gmt_plus_2[i],13,14),":"
                                                          ,"00"," ",substr(log$date_time_gmt_plus_2[i],19,20), sep = ""))}
}

# Change vo/na to am/pm
for (i in 1:length(log$date_time_gmt_plus_2)){
  if (endsWith(log$date_time_gmt_plus_2[i], "vo")) {
    log$date_time_gmt_plus_2[i] <- sub('vo$', 'am', log$date_time_gmt_plus_2[i])
  } else if (endsWith(log$date_time_gmt_plus_2[i], "na")) {
    log$date_time_gmt_plus_2[i] <- sub('na$', 'pm', log$date_time_gmt_plus_2[i])
  }
}

# Change am/pm to 24 hour format
for (i in 1:length(log$date_time_gmt_plus_2)) {
  if (endsWith(log$date_time_gmt_plus_2[i], "am")) {
    log$date_time_gmt_plus_2_24[i] <- sub(' am$', '', log$date_time_gmt_plus_2[i])
  } else if (endsWith(log$date_time_gmt_plus_2[i], "pm")) {
    trimmed <- sub(' pm$', '', log$date_time_gmt_plus_2[i])
    substr(trimmed, 12, 13) <- toString(as.numeric(substr(trimmed, 11, 13)) + 12)
    log$date_time_gmt_plus_2_24[i] <- trimmed
  }
}

#Problem: See: https://www.rdocumentation.org/packages/base/versions/3.6.2/topics/strptime
# Doc f�r %p:
# %p
#AM/PM indicator in the locale. Used in conjunction with %I and not with %H. 
#An empty string in some locales (for example on some OSes, non-English European locales including Russia).
#The behaviour is undefined if used for input in such a locale.

#--> how to convert in a german locale?
# TODO Fix these NAs, it probably has something to with the data not being as expected. Try with 24h format?
for (i in 1:length(log$date_time_gmt_plus_2)){
  log$date_time_gmt_plus_2test[i] <- strptime(as.POSIXlt(log$date_time_gmt_plus_2[i]), "%Y-%m-%d %I:%M:%S %p",tz = "Europe/Zurich") # convert to POSIXlt
}


# only keep log data from the time of the bicycle transect
log <- log[log$date_time_gmt_plus_2 <= "2018-08-08 23:50:00" & log$date_time_gmt_plus_2 >= "2018-08-07 00:00:00",]

# remove measurements from Log_100 (erronous measurements) and Log_5, Log_7, Log_64, Log_85 (rooftop stations)
# and Log_999, Log_98 (additional measurements from Zollikofen Meteoschweiz Location)
log$Log_5 <- NULL; log$Log_7 <- NULL; log$Log_64 <- NULL; log$Log_85 <- NULL; log$Log_100_AFU_REF_2.45m <- NULL
log$Log_999_REF_ZOLL_HAUS <- NULL; log$Log_98_REF_ZOLL_2m <- NULL


#change colnames to match "objectID" column in log_meta
colnames(log)[78] <- "Log_99"; colnames(log)[75] <- "Log_83"

# # combine columns of log dataframe into one column (this makes it possible to join with log_meta df)
# temp_vector <- as.numeric(unlist(log[,2:length(log[1,])]))
# time_vector <- as.data.frame(rep(log$date_time_gmt_plus_2, length(log[1,])-1))
# log_number <- rep(NA, length(temp_vector))
# 
# log_colnames <- c(colnames(log)[-1]) # exclude the first colname, which is the date
# 
# for (i in 1:length(log_colnames)){
#   for (j in 1:length(log[,1])){
#     log_number[j+(288*(i-1))] <- log_colnames[i]
#   }
# } # this adds the logger number to every measurement
# 
# log <- cbind(time_vector, temp_vector, log_number)
# colnames(log) <- c("date_time_gmt_plus_2", "temperature", "log_number")
# rm(time_vector); rm(temp_vector); rm(log_number); rm(log_colnames)


# read logger metadata
log_meta <- read.csv2(file = "data/Data_Loggers_2018/Data_Standorte_Meta_DEF.csv",
                      header = TRUE)

#changes selected values to numeric or integer
for(i in (4:6)){
  log_meta[,i] <- as.numeric(as.character(log_meta[,i]))
}
log_meta$UMFANG_PFOSTEN <- as.integer(as.character(log_meta$UMFANG_PFOSTEN))

names(log_meta)[names(log_meta) == "H?.HE_SENSOR"] <- "HOEHE_SENSOR" # remove umlaut in colname

# remove data from Log_64 and Log_85 (rooftop stations)
log_meta <- log_meta[-c(60,76),]

#convert the logger names to characters
log_meta$objectID <- as.character(log_meta$objectID)
# log$log_number <- as.character(log$log_number)

# append log_meta to log based on common column with logger number
# log_join <- inner_join(log, log_meta, by = c("log_number" = "objectID"))



# Bicycle QC -------------------------------

bicycle[is.na(bicycle)]<-0 # set NA values to 0, which makes working with them easier


#add Flag vectors to bicycle data.frame
bicycle$Equal_Temp_Flag = c(rep(NA,length(bicycle$RecNo)))
bicycle$NbrofSats_Flag = c(rep(NA,length(bicycle$RecNo)))
bicycle$Implausible_Flag = c(rep(NA,length(bicycle$RecNo)))
bicycle$Route_Flag <- c(rep(NA,length(bicycle$RecNo)))


# check for 8 or more equal temperature Values in a row (temp_Flag)

for(i in 1:(length(bicycle$Temp.C)-7)){
  if (bicycle$Temp.C[i]==bicycle$Temp.C[i+1] & bicycle$Temp.C[i]==bicycle$Temp.C[i+2] 
      & bicycle$Temp.C[i]==bicycle$Temp.C[i+3] & bicycle$Temp.C[i]==bicycle$Temp.C[i+4]
      & bicycle$Temp.C[i]==bicycle$Temp.C[i+5] & bicycle$Temp.C[i]==bicycle$Temp.C[i+6] 
      & bicycle$Temp.C[i]==bicycle$Temp.C[i+7]){
    bicycle$Equal_Temp_Flag[i:(i+7)]<-TRUE}
  else {bicycle$Equal_Temp_Flag[i:(i+7)]<-FALSE
  }
}


# Flag when Nbr of Sats <4?

for (i in 1:length(bicycle$Nbr.of.Sats)){
  if(bicycle$Nbr.of.Sats[i]<=4){
    bicycle$NbrofSats_Flag[i]<-TRUE}
  else {bicycle$NbrofSats_Flag[i]<-FALSE
  }
}


# Flag physically impossible and implausible values for whole measurement period (Implausible_Flag)
# remove temperature values that deviate more than 3.5 standard deviation from mean

for(i in 1:length(bicycle$Temp.C)){
  if(bicycle$Temp.C[i]>mean(bicycle$Temp.C)+3.5*sd(bicycle$Temp.C)){
    bicycle$Implausible_Flag[i] <- TRUE
  }
  else if(bicycle$Temp.C[i]<mean(bicycle$Temp.C)-3.5*sd(bicycle$Temp.C)){
    bicycle$Implausible_Flag[i] <- TRUE
  }
  else {bicycle$Implausible_Flag[i] <- FALSE}
}


# Flag measurements made during the stops at the GIUB (column "Route" has values Z0,Z1,Z2, ... ,  Z12)

for (i in 1:length(bicycle$Route_Flag)){
  if(grepl("Z", bicycle$Route[i]) == TRUE) {
    bicycle$Route_Flag[i]<-TRUE}
  else {bicycle$Route_Flag[i]<-FALSE
  }
}

#replace 0 with NA again
bicycle[bicycle == 0] <- NA
rm(i)


# Preparing data for spatial&temporal comparison -----------------------------------

# remove cws data which is outside the AOI
# boundaries of bicycle data
north_bounds_bicycle <- max(bicycle$Latitude.N., na.rm = T); south_bounds_bicycle <- min(bicycle$Latitude.N., na.rm = T)
east_bounds_bicycle <- max(bicycle$Longitude.E., na.rm = T); west_bounds_bicycle <- min(bicycle$Longitude.E., na.rm = T)
bounds_bicycle <- cbind(c(north_bounds_bicycle,south_bounds_bicycle),c(east_bounds_bicycle, west_bounds_bicycle))

# boundaries of log data
north_bounds_log <- max(log_meta$NORD_CHTOPO, na.rm = T); south_bounds_log <- min(log_meta$NORD_CHTOPO, na.rm = T)
east_bounds_log <- max(log_meta$OST_CHTOPO, na.rm = T); west_bounds_log <- min(log_meta$OST_CHTOPO, na.rm = T)
bounds_log <- cbind(c(north_bounds_log,south_bounds_log),c(east_bounds_log, west_bounds_log))

# maximum boundaries of bicycle and log combined
bounds <- cbind(bounds_bicycle, bounds_log); rownames(bounds) <- c("max", "min")
bounds <- as.data.frame(cbind(
  c(max(bounds[2,]), min(bounds[2,])),
  c(max(bounds[1,]), min(bounds[1,])))) # maximum boundaries
colnames(bounds) <- c("min", "max"); rownames(bounds) <- c("lat", "lon")

bounds[1,1] <- bounds[1,1]-0.035; bounds[1,2] <- bounds[1,2]+0.035 # expand the buffer by 0.035 degrees
bounds[2,1] <- bounds[2,1]-0.035; bounds[2,2] <- bounds[2,2]+0.035 # expand the buffer by 0.035 degrees

# remove the values not within the bounds
cws_be_08 <- subset(cws_be_08, lon <= bounds$max[2] & cws_be_08$lon >= bounds$min[2] 
                    & cws_be_08$lat <= bounds$max[1] & cws_be_08$lat >= bounds$min[1])


cws_be_08_meta <- subset(cws_be_08_meta, lon <= bounds$max[2] & cws_be_08_meta$lon >= bounds$min[2] 
                         & cws_be_08_meta$lat <= bounds$max[1] & cws_be_08_meta$lat >= bounds$min[1])

rm(north_bounds_bicycle, south_bounds_bicycle, east_bounds_bicycle,west_bounds_bicycle
   ,north_bounds_log, south_bounds_log, east_bounds_log, west_bounds_log, bounds_bicycle, bounds_log)

rm(bounds)



# split cws data by p_id to have every measurement in a seperate column
cws_be_08 <- as.data.frame(split(cws_be_08, cws_be_08$p_id)) # split by cws_be_08
cws_be_08_time <- as.data.frame(cws_be_08[,1]) # save time vectors seperately
toMatch <- c("ta_int", "_orig") # define which columns to keep
cws_be_08 <- cws_be_08[,c(grep(paste(toMatch,collapse="|"), names(cws_be_08)))] # only keep columns with "ta_int" in their name (-c would remove a column)
cws_be_08_names <- names(cws_be_08)
cws_be_08_names <- substring(cws_be_08_names,2)
cws_be_08 <- cbind(cws_be_08_time, cws_be_08)
names(cws_be_08) <- c("time", cws_be_08_names)
rm(cws_be_08_names, cws_be_08_time, toMatch)



# Remove flagged values from bicycle---------------------------------------------------

bicycle_complete <- bicycle
bicycle<-bicycle[is.na(bicycle$Equal_Temp_Flag)
                 & is.na(bicycle$NbrofSats_Flag) &
                   is.na(bicycle$Implausible_Flag) &
                   is.na(bicycle$Route_Flag)
                 ,]


# New temporal comparison of CWS -------------------------------------------------


### DONT REDO THIS EVERY TIME -> LOAD THE delta t table DIRECTLY INSTEAD:
### output_orig/1_processing_orig/distance/","cws_df_time_orig_dt.csv

# create df with only time_orig
df_time_orig <- cws_be_08[,c(grep(paste("_orig"), names(cws_be_08)))]
df_ta_int_orig <- cws_be_08[,c(grep(paste("ta_int"), names(cws_be_08)))]
rownames(df_time_orig) <- cws_be_08$time;rownames(df_ta_int_orig) <- cws_be_08$time

# 
# # for every bicycle measurement go through every timestep (48) of every
# CWS (columns in df_time_orig) and find the minimum difference

# initiate emtpy df
cws_be_08_bicycle_time_orig_dt <- data.frame()
cws_be_08_bicycle_time_orig <- data.frame()
cws_be_08_bicycle_ta_int_orig <- data.frame()

# Calculate cws temporal distance
# loop through every CWS'
# for (j in 1:ncol(df_time_orig)){
#   print(paste("CWS",j))
#   # loop through every bicycle measurement
#   for (i in 1:nrow(bicycle)){
#     # find min temporal distance (=closest measurement) between every bicylce measurement
#     # and the 48 CWS measurements and write to new df
#     min_dist <- which(abs(as.numeric(c(df_time_orig[,j]) - bicycle$Date.Time[i],
#                                      unit = "secs")) <= min(abs(as.numeric(c(df_time_orig[,j]) - bicycle$Date.Time[i],
#                                                                            unit = "secs")), na.rm =T))[1]
#     # the time difference in seconds between cws and bicycle
#     dist_time <- (as.numeric(c(df_time_orig[min_dist,j]) - bicycle$Date.Time[i],
#                         unit = "secs"))
#     
#     # write the minimum distance time to new df
#     cws_be_08_bicycle_time_orig[i,j] <- df_time_orig[min_dist,j]
#     cws_be_08_bicycle_ta_int_orig[i,j] <- df_ta_int_orig[min_dist,j]
#     
#     # write difference in seconds to new df
#     cws_be_08_bicycle_time_orig_dt[i,j] <- dist_time
#   }; rm(i)
# };rm(j)


# load the delta t tables (if values already calculated)
cws_be_08_bicycle_time_orig_dt <- read.csv(file = "output_reworked/0_pre_processing_orig/distance/cws_be_08_bicycle_time_orig_dt.csv")
cws_be_08_bicycle_time_orig <- read.csv(file = "output_reworked/0_pre_processing_orig/cws_be_08/cws_be_08_bicycle_time_orig.csv",
                                        header = T)
cws_be_08_bicycle_ta_int_orig <- read.csv(file = "output_reworked/0_pre_processing_orig/cws_be_08/cws_be_08_bicycle_ta_int_orig.csv",
                                          header = T)

# convert the time_orig values to POSIX (incase they were loaded in and not calculated freshly)
for (i in 1:length(length(cws_be_08_bicycle_time_orig))){
  cws_be_08_bicycle_time_orig[,i] <- as.POSIXct(cws_be_08_bicycle_time_orig[,i], 
                                                tz = "Europe/Berlin")
}

### name columns and rows

# cws_be_08_bicycle_time_orig_dt
rownames(cws_be_08_bicycle_time_orig_dt) <- bicycle$Date.Time
colnames(cws_be_08_bicycle_time_orig_dt) <- colnames(df_time_orig)

# time_orig
rownames(cws_be_08_bicycle_time_orig) <- bicycle$Date.Time
colnames(cws_be_08_bicycle_time_orig) <- colnames(df_time_orig)

# ta_int orig
rownames(cws_be_08_bicycle_ta_int_orig) <- bicycle$Date.Time
colnames(cws_be_08_bicycle_ta_int_orig) <- colnames(df_ta_int_orig)

# combine the bicycle - cws time orig and bicycle - cws ta_int dataframes
cws_colnames <- colnames(cws_be_08)[-1]
cws_be_08_bicycle <- cbind(cws_be_08_bicycle_ta_int_orig, cws_be_08_bicycle_time_orig)
cws_be_08_bicycle <- cws_be_08_bicycle[,cws_colnames]
cws_be_08_bicycle <- cbind(bicycle,cws_be_08_bicycle)




# Temporal comparison of LOG -----------------------------------------------------

#convert to POSIXct
str(bicycle$Date.Time); str(log$date_time_gmt_plus_2); str(cws_be_08$time_orig) # check time formats
log$date_time_gmt_plus_2 <- as.POSIXct(log$date_time_gmt_plus_2)
bicycle$Date.Time <- as.POSIXct(bicycle$Date.Time)

# add another copy of log/cws time log/cws df so it doesnt get lost in the combination process
log <- cbind(as.data.frame(log$date_time_gmt_plus_2), log)

# convert from data frame to data table to enable the joins by roll
bicycle <- data.table(bicycle)
log <- data.table(log)

# sort by time as indicated by the columns
setkey( bicycle, Date.Time )
setkey( log, date_time_gmt_plus_2 )

# combine the bicycle with the log data
log_bicycle <- log[ bicycle, roll="nearest"] # combine by nearest time
log_bicycle$date_time_gmt_plus_2 <- NULL
log_bicycle <- subset(log_bicycle, select = c(1:which(colnames(log_bicycle)=="Log_101")))
log_bicycle <- as.data.frame(cbind(bicycle,log_bicycle)) # this is the time combined log and bicycle measurements


# # combine the bicycle with the cws data
# cws_be_08_bicycle_full_hour <- cws_be_08 [ bicycle, roll = "nearest"]
# name <- (colnames(cws_be_08_bicycle_full_hour)[-1])
# cws_be_08_bicycle_full_hour$time <- NULL
# colnames(cws_be_08_bicycle_full_hour) <- name
# cws_be_08_bicycle_full_hour <- subset(cws_be_08_bicycle_full_hour,
#                             select = c(1:which(colnames(cws_be_08_bicycle_full_hour)=="RecNo")-1)) # only select time and temperatures
# cws_be_08_bicycle_full_hour <- as.data.frame(cbind(bicycle, cws_be_08_bicycle_full_hour)) # this is the time combined log and bicycle measurements
# 


# Temporal Distance Log Matrix ------------------------------------------------

# log time dist full hour
log_bicycle_time_diff_secs <- (c(rep(NA, nrow(log_bicycle))))

# Calculate log temporal distance
for (i in 1:nrow(log_bicycle)){
  log_bicycle_time_diff_secs[i] <-
    as.numeric(log_bicycle$`log$date_time_gmt_plus_2`[i]
               - bicycle$Date.Time[i], unit = "secs")
}; rm(i)



# combine the two time differences from log and cws (hourly)

log_bicycle_dt <- as.data.frame(log_bicycle_time_diff_secs)
rm(log_bicycle_time_diff_secs, cws_be_08_bicycle_time_diff_secs)

# Spatial Distance Matrices -------------------------------------------------------

dist_log_bicycle <- as.data.frame(pointDistance(bicycle[,c("Longitude.E.","Latitude.N.")],
                                                log_meta[,c("OST_CHTOPO","NORD_CHTOPO")], lonlat = TRUE))

names(dist_log_bicycle) <- names(log[1:length(log[1,])])[-(1:2)]


dist_cws_be_08_bicycle <- as.data.frame(pointDistance(bicycle[,c("Longitude.E.","Latitude.N.")],
                                                      cws_be_08_meta[,c("lon","lat")], lonlat = TRUE))
names(dist_cws_be_08_bicycle) <- c(cws_be_08_meta$p_id) # add column names


# Save data ---------------------------------------------------------------

# create save directory
dir.create("output_reworked")
dir.create("output_reworked/0_pre_processing_orig")
dir.create("output_reworked/0_pre_processing_orig/bicycle")
dir.create("output_reworked/0_pre_processing_orig/cws_be_08")
dir.create("output_reworked/0_pre_processing_orig/log")
dir.create("output_reworked/0_pre_processing_orig/distance")


### save bicycle data
write.csv(bicycle,row.names = F,
          file = paste0("output_reworked/0_pre_processing_orig/bicycle/","bicycle.csv"))
write.csv(bicycle_complete,row.names = F,
          file = paste0("output_reworked/0_pre_processing_orig/bicycle/","bicycle_complete.csv"))


# 
# ### save log data
write.csv(log,row.names = F,
          file = paste0("output_reworked/0_pre_processing_orig/log/","log.csv"))
write.csv(log_meta,row.names = F,
          file = paste0("output_reworked/0_pre_processing_orig/log/","log_meta.csv"))
write.csv(log_bicycle,row.names = F,
          file = paste0("output_reworked/0_pre_processing_orig/log/","log_bicycle.csv"))

# 
# ### save cws data
write.csv(cws_be_08,row.names = F,
          file = paste0("output_reworked/0_pre_processing_orig/cws_be_08/","cws_be_08.csv"))
write.csv(cws_be_08_meta,row.names = F,
          file = paste0("output_reworked/0_pre_processing_orig/cws_be_08/","cws_be_08_meta.csv"))
#

# # time_orig
write.csv(cws_be_08_bicycle_time_orig, row.names = F,
          file=paste0("output_reworked/0_pre_processing_orig/cws_be_08/","cws_be_08_bicycle_time_orig.csv"))
# ta_int
write.csv(cws_be_08_bicycle_ta_int_orig, row.names = F,
          file=paste0("output_reworked/0_pre_processing_orig/cws_be_08/","cws_be_08_bicycle_ta_int_orig.csv"))

# # cws-biycle
write.csv(cws_be_08_bicycle, row.names = F,
          file=paste0("output_reworked/0_pre_processing_orig/cws_be_08/","cws_be_08_bicycle.csv"))

# 
# 
# ### spatial distance and time dist
write.csv(dist_cws_be_08_bicycle, row.names = F,
          file=paste0("output_reworked/0_pre_processing_orig/distance/","dist_cws_be_08_bicycle.csv"))
write.csv(dist_log_bicycle, row.names = F,
          file=paste0("output_reworked/0_pre_processing_orig/distance/","dist_log_bicycle.csv"))

# # delta t
write.csv(cws_be_08_bicycle_time_orig_dt, row.names = F,
          file=paste0("output_reworked/0_pre_processing_orig/distance/","cws_be_08_bicycle_time_orig_dt.csv"))

write.csv(log_bicycle_dt, row.names = F,
          file=paste0("output_reworked/0_pre_processing_orig/distance/","log_bicycle_dt.csv"))
