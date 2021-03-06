# Netatmo Preprocessing 1b transect means

# This script loads and formats the temperature measurements from the bicycle campaign (bicycle) in August 2019 and the corresponding data
# from the Netatmo citizen weather stations (cws_be_2019) and the loggers of Moritz Gublers PhD Project (log).
# Further it calculates the spatial and temporal distances between bicycle and cws_be_2019/log.

# SET WORKING DIRECTORY
# setw/d("C:/Users/Lukas/Desktop/HiWI/Paper_Netatmo_Lukas") # personal laptop
# setwd("/scratch3/lukas/HiWi/Paper_Netatmo_Lukas/") # GIUB computer

# install libraries
library("measurements") #for converting lat/lon in degrees,min,sec to decimal degrees
library("tidyverse") # for data manipulation
library("dplyr")
library("raster") # for distance calculations
library("data.table") # for data table manipulations
library("Metrics") # for statistical calculations

# Read data ---------------------------------------------------------------


bicycle <- read.csv(file = "output_reworked/0_pre_processing_orig/bicycle/bicycle.csv")[,c(1:11)]

cws_be_2019_bicycle_ta_int <- read.csv(file = "output_reworked/0_pre_processing_orig/cws_be_2019/cws_be_2019_bicycle_ta_int_orig.csv")
cws_be_2019_bicycle_time_orig <- read.csv(file = "output_reworked/0_pre_processing_orig/cws_be_2019/cws_be_2019_bicycle_time_orig.csv")

cws_be_2019_meta <- read.csv(file = "output_reworked/0_pre_processing_orig/cws_be_2019/cws_be_2019_meta.csv")

log_bicycle <- read.csv(file = "output_reworked/0_pre_processing_orig/log/log_bicycle.csv")

log_meta <- read.csv(file="output_reworked/0_pre_processing_orig/log/log_meta.csv")

all <- cbind(bicycle, cws_be_2019_bicycle_ta_int, log_bicycle)
all$Date.Time <- as.POSIXct(all$dateAndTime, tz = "Europe/Berlin") # convert to POSIXct

# Transect Means (partially used)-----------------------------------------------


#rename Temperature Column
# names(bicycle)[names(bicycle) == "Temp.?..C."] <- paste("Temp.C")
# names(bicycle)[5] <- paste("Temp.C") # last resort solution

cws_transect_means <- aggregate(all[, 12:677], list(all$Route), mean)
log_transect_means <- aggregate(all[, 701:774], list(all$Route), mean)

route_order <- c("A1", "B1", "C1", "A2", "B2", "C2", "A3"
               , "B3", "C3", "A4", "B4", "C4", "B5", "C5")
route_names <- as.character(log_transect_means$Group.1)

# rename columns
row.names(log_transect_means) <- c(route_names)
row.names(cws_transect_means) <- c(route_names)

# reorder columns
log_transect_means <- log_transect_means[route_order,]
cws_transect_means <- cws_transect_means[route_order,]

# remove first column
log_transect_means$Group.1 <- NULL; cws_transect_means$Group.1 <- NULL

# transpose data frame
log_transect_means <- t(log_transect_means)
cws_transect_means <- t(cws_transect_means)

# save column names for later
NUMMER <- as.numeric(log_meta$Nummer_2019)
NUMMER <- NUMMER[NUMMER != 5]
NUMMER <- NUMMER[NUMMER != 7]
NUMMER <- NUMMER[NUMMER != 64]
NUMMER <- NUMMER[NUMMER != 85]
NUMMER <- NUMMER[NUMMER != 102]
p_id <- substr(rownames(cws_transect_means),2,5)
p_id <- as.numeric(p_id)

# hourly means ------------------------------------------------------------
times <- c("2019-06-26 20:00:00", "2019-06-26 21:00:00", "2019-06-26 22:00:00", "2019-06-26 23:00:00",
           "2019-06-27 00:00:00", "2019-06-27 01:00:00", "2019-06-27 02:00:00", "2019-06-27 03:00:00",
           "2019-06-27 04:00:00", "2019-06-27 05:00:00", "2019-06-27 06:00:00", "2019-06-27 07:00:00",
           "2019-06-27 08:00:00", "2019-06-27 09:00:00", "2019-06-27 10:00:00", "2019-06-27 11:00:00",
           "2019-06-27 12:00:00", "2019-06-27 13:00:00", "2019-06-27 14:00:00")

# for 1h periods
hourly_log_means_list <- list()
hourly_cws_means_list <- list()
for (i in 1:(length(times)-1)){
  # create subsets of time periods
  temp1 <- subset(all, Date.Time >= times[i] & Date.Time <= times[i+1])
  # calculate column means of subsets
  log_means <- as.data.frame(colMeans(temp1[701:774], na.rm = T))
  cws_means <- as.data.frame(colMeans(temp1[12:677], na.rm = T))
  colnames(log_means) <- paste0("time_",substr(times[i], 12,13),"_",substr(times[i+1], 12,13))
  colnames(cws_means) <- paste0("time_",substr(times[i], 12,13),"_",substr(times[i+1], 12,13))
  # append log means to hourly means to the transect means
  hourly_log_means_list[[i]] <- log_means
  hourly_cws_means_list[[i]] <- cws_means
}; rm(temp1)
hourly_log_means <- do.call(cbind, hourly_log_means_list)
hourly_cws_means <- do.call(cbind, hourly_cws_means_list)
rm(hourly_cws_means_list, hourly_log_means_list)

# for 2h periods
twohourly_log_means_list <- list()
twohourly_cws_means_list <- list()
for (i in 1:(length(times)-2)){
  # create subsets of time periods
  temp1 <- subset(all, Date.Time >= times[i] & Date.Time <= times[i+2])
  # calculate column means of subsets
  log_means <- as.data.frame(colMeans(temp1[701:774], na.rm = T))
  cws_means <- as.data.frame(colMeans(temp1[12:677], na.rm = T))
  colnames(log_means) <- paste0("time_",substr(times[i], 12,13),"_",substr(times[i+2], 12,13))
  colnames(cws_means) <- paste0("time_",substr(times[i], 12,13),"_",substr(times[i+2], 12,13))
  # append log means to hourly means to the transect means
  twohourly_log_means_list[[i]] <- log_means
  twohourly_cws_means_list[[i]] <- cws_means
}; rm(temp1)
twohourly_log_means <- do.call(cbind, twohourly_log_means_list)
twohourly_cws_means <- do.call(cbind, twohourly_cws_means_list)
rm(twohourly_cws_means_list, twohourly_log_means_list)

# for 3h periods
threehourly_log_means_list <- list()
threehourly_cws_means_list <- list()
for (i in 1:(length(times)-3)){
  # create subsets of time periods
  temp1 <- subset(all, Date.Time >= times[i] & Date.Time <= times[i+3])
  # calculate column means of subsets
  log_means <- as.data.frame(colMeans(temp1[701:774], na.rm = T))
  cws_means <- as.data.frame(colMeans(temp1[12:677], na.rm = T))
  colnames(log_means) <- paste0("time_",substr(times[i], 12,13),"_",substr(times[i+3], 12,13))
  colnames(cws_means) <- paste0("time_",substr(times[i], 12,13),"_",substr(times[i+3], 12,13))
  # append log means to hourly means to the transect means
  threehourly_log_means_list[[i]] <- log_means
  threehourly_cws_means_list[[i]] <- cws_means
}; rm(temp1)
threehourly_log_means <- do.call(cbind, threehourly_log_means_list)
threehourly_cws_means <- do.call(cbind, threehourly_cws_means_list)
rm(threehourly_cws_means_list, threehourly_log_means_list)

# for 4h periods
fourhourly_log_means_list <- list()
fourhourly_cws_means_list <- list()
for (i in 1:(length(times)-4)){
  # create subsets of time periods
  temp1 <- subset(all, Date.Time >= times[i] & Date.Time <= times[i+4])
  # calculate column means of subsets
  log_means <- as.data.frame(colMeans(temp1[701:774], na.rm = T))
  cws_means <- as.data.frame(colMeans(temp1[12:677], na.rm = T))
  colnames(log_means) <- paste0("time_",substr(times[i], 12,13),"_",substr(times[i+4], 12,13))
  colnames(cws_means) <- paste0("time_",substr(times[i], 12,13),"_",substr(times[i+4], 12,13))
  # append log means to hourly means to the transect means
  fourhourly_log_means_list[[i]] <- log_means
  fourhourly_cws_means_list[[i]] <- cws_means
}; rm(temp1)
fourhourly_log_means <- do.call(cbind, fourhourly_log_means_list)
fourhourly_cws_means <- do.call(cbind, fourhourly_cws_means_list)
rm(fourhourly_cws_means_list, fourhourly_log_means_list)

# for whole night
temp1 <- subset(all, Date.Time >= "2019-06-26 22:00:00" & Date.Time <= "2019-06-27 06:00:00")
# calculate column means of subsets
night_22_06_log_means <- as.data.frame(colMeans(temp1[701:774], na.rm = T))
night_22_06_cws_means <- as.data.frame(colMeans(temp1[12:677], na.rm = T))
colnames(night_22_06_log_means) <- "night_22_06"
colnames(night_22_06_cws_means) <- "night_22_06"
rm(temp1)


# Combine all the mean dataframes and save to csv -------------------------
log_temp <- cbind(hourly_log_means, twohourly_log_means,
                   threehourly_log_means, fourhourly_log_means, night_22_06_log_means)
cws_temp <- cbind(hourly_cws_means, twohourly_cws_means,
                   threehourly_cws_means, fourhourly_cws_means, night_22_06_cws_means)
log_temp <- round(log_temp, digits = 3)
cws_temp <- round(cws_temp, digits = 3)

NUMMER <- na.omit(NUMMER)
log_means <- cbind(NUMMER,log_temp)
cws_means <- cbind(p_id, cws_temp)

dir.create("output_reworked/1b_processing_transect_means")
write.csv(log_means, row.names = F,
          file=paste0("output_reworked/1b_processing_transect_means/log_means.csv"))
write.csv(cws_means, row.names = F,
          file=paste0("output_reworked/1b_processing_transect_means/cws_means.csv"))
