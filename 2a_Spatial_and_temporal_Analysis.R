# Netatmo Spatial Analysis

# this file does the spatial analysis of the log and cws data.
# It compares the (inverse distance weighted) 
# mean temperatures of the log/cws within multiple
# radii around every bicycle measurement.

# SET WORKING DIRECTORY
setwd("C:/Users/Lukas/Desktop/HiWI/Paper_Netatmo_Lukas") # personal laptop
# setwd("/scratch3/lukas/HiWi/Paper_Netatmo_Lukas/") # GIUB computer

# install libraries
library("measurements") #for converting lat/lon in degrees,min,sec to decimal degrees
library("tidyverse") # for data manipulation
library("dplyr")
library("raster") # for distance calculations
library("data.table") # for data table manipulations
library("Metrics") # for statistical calculations

dir.create("output_reworked/2_spatial_and_temporal_analysis_reworked/")
dir.create("output_reworked/2_spatial_and_temporal_analysis_reworked/cws_analysis/")
dir.create("output_reworked/2_spatial_and_temporal_analysis_reworked/log_analysis/")


# load functions
source("r_scripts/functions/complete_cases_function.R")
source("r_scripts/functions/convert_df_cols_to_POSIX_tz_Bern_function.r")


# Read Files (from processing output) -------------------------------------

# bicycle
files <- list.files(path="output_reworked/0_pre_processing_orig/bicycle/")
for (f in files){
  print(f)
  name <- substr(f,1,nchar(f)-4)
  assign(name,read.csv(file=paste0("output_reworked/0_pre_processing_orig/bicycle/",f),
                       header = T, sep = ","))
  rm(name)
}; rm(f, files)
rm(bicycle_complete)

# log
files <- list.files(path="output_reworked/0_pre_processing_orig/log/")
for (f in files){
  print(f)
  name <- substr(f,1,nchar(f)-4)
  assign(name,read.csv(file=paste0("output_reworked/0_pre_processing_orig/log/",f),
                       header = T, sep = ","))
  rm(name)
}; rm(f, files)

# cws
files <- list.files(path="output_reworked/0_pre_processing_orig/cws_be_08/")
for (f in files){
  print(f)
  name <- substr(f,1,nchar(f)-4)
  assign(name,read.csv(file=paste0("output_reworked/0_pre_processing_orig/cws_be_08/",f),
                       header = T, sep = ","))
  rm(name)
}; rm(f, files)

# distance matrices
files <- list.files(path="output_reworked/0_pre_processing_orig/distance/")
for (f in files){
  print(f)
  name <- substr(f,1,nchar(f)-4)
  assign(name,read.csv(file=paste0("output_reworked/0_pre_processing_orig/distance/",f),
                       header = T, sep = ","))
  rm(name)
}; rm(f, files)


# Convert times to POSIX --------------------------------------------------

for (i in 1:length(cws_be_08_bicycle_time_orig)){
  cws_be_08_bicycle_time_orig[,i] <- as.POSIXct(as.character(cws_be_08_bicycle_time_orig[,i]), 
                                                tz = "Europe/Berlin")
}

            

# Mean CWS Analysis ----------------------------------------------------------------


#define variables and vectors
rad <- c(100,150,200,250,300,400,500,600,
         700,800,900,1000,1500,2000,3000) # search radius in meters

delta_t = c(60*60, 30*60, 15*60, 10*60, 5*60) # temporal distance in seconds

p <- 1 # power parameter for the inverse distance function

## parameters for testing the loop 
# i = 2451 # here there NA values within rad and dt and therefore the script writes give NaN or Inf as temperature...
# i = 2450 # here everything is fine
# r <- rad
# dt <- delta_t

### CWS for loop ###

    
###
for (r in rad){
  for (dt in delta_t){
    # create empty vectors to save data in
    cws_be_08_dist <- (c(rep(NA, nrow(cws_be_08_bicycle)))) # distances of closest cws measurement
    cws_be_08_dist_mean <- (c(rep(NA, nrow(cws_be_08_bicycle)))) # mean of those distances
    cws_be_08_dist_name <- (c(rep(NA, nrow(cws_be_08_bicycle)))) # name of the cws within the radius (=column name)
    cws_be_08_dt <- (c(rep(NA, nrow(cws_be_08_bicycle))))
    cws_be_08_dt_mean <- (c(rep(NA, nrow(cws_be_08_bicycle))))
    cws_be_08_temp <- (c(rep(NA, nrow(cws_be_08_bicycle)))) # temperature values of those cws
    cws_be_08_temp_weighted_mean <- (c(rep(NA, nrow(cws_be_08_bicycle)))) # weighted mean of those values
    cws_be_08_temp_min_T_filter <- (c(rep(NA, nrow(cws_be_08_bicycle)))) # minimum T of cws within that radius
    cws_be_08_number_of_cws <- (c(rep(NA, nrow(cws_be_08_bicycle)))) # the ammount of cws within the radius
    cws_be_08_temp_difference_weighted_mean <- (c(rep(NA, nrow(cws_be_08_bicycle))))
    cws_be_08_temp_difference_min_T_filter <- (c(rep(NA, nrow(cws_be_08_bicycle))))
    
    for (i in 1:nrow(cws_be_08_bicycle)){
      print(paste("CWS:","Calulating row",i,"for radius",r,"meters","and time difference",dt/60,"minutes"))
      if (is.na(min(dist_cws_be_08_bicycle[i,]) == TRUE)){
        # if NA then remove
        cws_be_08_dist[i] <- NA
        cws_be_08_dist_mean[i] <- NA
        cws_be_08_dist_name[i] <- NA
        cws_be_08_dt[i] <- NA
        cws_be_08_dt_mean[i] <- NA
        cws_be_08_temp[i] <- NA
        cws_be_08_temp_weighted_mean[i] <- NA
        cws_be_08_temp_min_T_filter[i] <- NA
        cws_be_08_number_of_cws[i] <- NA
        cws_be_08_temp_difference_weighted_mean[i] <- NA
        cws_be_08_temp_difference_min_T_filter[i] <- NA
      }
      
      # else if ((length(which((dist_cws_be_08_bicycle[i,] <= r) == TRUE)) == 0L)==TRUE){
      #   # if no distance is within the radius
      #   cws_be_08_dist[i] <- NA
      #   cws_be_08_dist_mean[i] <- NA
      #   cws_be_08_dist_name[i] <- NA
      #   cws_be_08_dt[i] <- NA
      #   cws_be_08_dt_mean[i] <- NA
      #   cws_be_08_temp[i] <- NA
      #   cws_be_08_temp_weighted_mean[i] <- NA
      #   cws_be_08_temp_min_T_filter[i] <- NA
      #   cws_be_08_number_of_cws[i] <- NA
      #   cws_be_08_temp_difference_weighted_mean[i] <- NA
      #   cws_be_08_temp_difference_min_T_filter[i] <- NA
      # }
      # else if ((length(which((abs(as.numeric(cws_be_08_bicycle_time_orig_dt[i,])) <= dt) == TRUE)) == 0L)==TRUE){
      #   # if no temporal distance is within delta t (then the length of the which() expression will be larger thatn 0)
      #   cws_be_08_dist[i] <- NA
      #   cws_be_08_dist_mean[i] <- NA
      #   cws_be_08_dist_name[i] <- NA
      #   cws_be_08_dt[i] <- NA
      #   cws_be_08_dt_mean[i] <- NA
      #   cws_be_08_temp[i] <- NA
      #   cws_be_08_temp_weighted_mean[i] <- NA
      #   cws_be_08_temp_min_T_filter[i] <- NA
      #   cws_be_08_number_of_cws[i] <- NA
      #   cws_be_08_temp_difference_weighted_mean[i] <- NA
      #   cws_be_08_temp_difference_min_T_filter[i] <- NA
      # }
      

      # # check whether any CWS is within BOTH dt AND rad
      # temp_within_delta_t <- which(abs(as.numeric(cws_be_08_bicycle_time_orig_dt[i,])) <= dt)
      # temp_within_rad <- which(dist_cws_be_08_bicycle[i,] <= r)
      # temp_within_rad_within_delta_t <- temp_within_rad[temp_within_rad %in% temp_within_delta_t]
      # a <- which(dist_cws_be_08_bicycle[i,] <= r)[which(dist_cws_be_08_bicycle[i,] <= r) %in% which(abs(as.numeric(cws_be_08_bicycle_time_orig_dt[i,])) <= dt)]
      
      else if ((length(which(dist_cws_be_08_bicycle[i,] <= r)[which(dist_cws_be_08_bicycle[i,] <= r) %in% which(abs(as.numeric(cws_be_08_bicycle_time_orig_dt[i,])) <= dt)]) == 0)){
        # If no value within rad and within dt, then write NA
        cws_be_08_dist[i] <- NA
        cws_be_08_dist_mean[i] <- NA
        cws_be_08_dist_name[i] <- NA
        cws_be_08_dt[i] <- NA
        cws_be_08_dt_mean[i] <- NA
        cws_be_08_temp[i] <- NA
        cws_be_08_temp_weighted_mean[i] <- NA
        cws_be_08_temp_min_T_filter[i] <- NA
        cws_be_08_number_of_cws[i] <- NA
        cws_be_08_temp_difference_weighted_mean[i] <- NA
        cws_be_08_temp_difference_min_T_filter[i] <- NA
      }
      
      else {
        ## write to temporary variables
        
        # spatial distance
        temp_within_rad <- t(as.data.frame(which((dist_cws_be_08_bicycle[i,] <= r) == TRUE))) # indices of distance values within radius
        temp_dist <- as.data.frame(dist_cws_be_08_bicycle[i,temp_within_rad]) # distances of those indices (temporarily stored)
        
        # temporal distance
        temp_within_delta_t <- t(as.data.frame(which((abs(as.numeric(cws_be_08_bicycle_time_orig_dt[i,])) <= dt) == TRUE))) # indices of distance values within radius
        temp_delta_t <- as.data.frame(cws_be_08_bicycle_time_orig_dt[i,temp_within_delta_t]) # delta t of those indices (temporarily stored)
        
        # cws within both dt and r
        temp_within_rad_within_delta_t <- temp_within_rad[temp_within_rad %in% temp_within_delta_t]
        
        

        # distance of only those cws
        temp_dist_within_rad_within_delta_t <- as.data.frame(dist_cws_be_08_bicycle[i,temp_within_rad_within_delta_t]) # distances of those indices (temporarily stored)
        # delta t of only those cws
        temp_delta_t_within_rad_within_delta_t <- as.data.frame(cws_be_08_bicycle_time_orig_dt[i,temp_within_rad_within_delta_t]) # delta t of those indices (temporarily stored)
        
        # T within dt and r
        temp_temp <- data.table(cws_be_08_bicycle_ta_int_orig[i, temp_within_rad_within_delta_t]) # temperature of cws within radius
        temp_temp <- as.data.frame(temp_temp) #convert back to df
        # extract names of the cws
        ifelse(names(temp_temp) == "V1", # V1 would be the name if only 1 CWS is within rad and dt. thats what I catch here
               temp_name <- colnames(cws_be_08_bicycle_ta_int_orig[temp_within_rad_within_delta_t]),
               temp_name <- names(temp_temp))
        
        
        ## write to actual vectors
        # spatial distance
        cws_be_08_dist_mean[i] <- mean(as.numeric(temp_dist_within_rad_within_delta_t[])) # mean of those distances
        # temporal distance
        cws_be_08_dt_mean[i] <- mean(as.numeric((temp_delta_t_within_rad_within_delta_t[])))
        # names of cws within dt and r
        cws_be_08_dist_name[i] <- paste(temp_name[],
                                        collapse = ",") # collaps the names into one cell
        # weighted mean should now be according to dt
        cws_be_08_temp_weighted_mean[i] <- weighted.mean(temp_temp, (1/((temp_dist_within_rad_within_delta_t))^p), na.rm = TRUE) # mean of these temps
        
        # convert to NA if value is NaN
        # ifelse(cws_be_08_temp_weighted_mean[i]== "NaN",
        #        cws_be_08_temp_weighted_mean[i] <- NA,
        #        cws_be_08_temp_weighted_mean[i] <- cws_be_08_temp_weighted_mean[i])
        
        # also document the CWS temperature which has the lowest absolute T (so minimum filter)
        cws_be_08_temp_min_T_filter[i] <- min(temp_temp, na.rm=T)
        
        # convert to NA if value is Inf
        # ifelse(cws_be_08_temp_min_T_filter[i] == "Inf",
        #        cws_be_08_temp_min_T_filter[i] <- NA,
        #        cws_be_08_temp_min_T_filter[i] <- cws_be_08_temp_min_T_filter[i])
        # 
        
        cws_be_08_number_of_cws[i] <- length(temp_within_rad_within_delta_t)
        cws_be_08_dt[i] <- apply(temp_delta_t_within_rad_within_delta_t, 1,
                                   function(x) paste(x[!is.na(x)],collapse = ", ")) # collaps distances into one cell
        cws_be_08_dist[i] <- apply(temp_dist_within_rad_within_delta_t, 1,
                                   function(x) paste(x[!is.na(x)],collapse = ", ")) 
        cws_be_08_temp[i] <- paste(temp_temp[1:ncol(temp_temp)],collapse = ", ") # collaps temperatures into 1 cell
        cws_be_08_temp_difference_weighted_mean[i] <- cws_be_08_temp_weighted_mean[i]- bicycle$Temp.C[i]
        cws_be_08_temp_difference_min_T_filter[i] <- cws_be_08_temp_min_T_filter[i]- bicycle$Temp.C[i]
        
        rm(temp_within_rad, temp_dist, temp_temp,temp_name, temp_within_rad, temp_delta_t,
           temp_delta_t_within_rad_within_delta_t, temp_dist_within_rad_within_delta_t, temp_within_delta_t,
           temp_within_rad_within_delta_t) # remove temporary variables
      }
    }
    
    cws_analysis <- as.data.frame(cbind(cws_be_08_dist_mean,cws_be_08_dist, cws_be_08_dist_name,
                                        cws_be_08_dt_mean, cws_be_08_dt,  cws_be_08_temp,
                                        cws_be_08_temp_weighted_mean, cws_be_08_temp_min_T_filter,
                                        cws_be_08_number_of_cws, cws_be_08_temp_difference_weighted_mean,
                                        cws_be_08_temp_difference_min_T_filter))
    # replace NaN and Inf by NA
    cws_analysis <- replace(cws_analysis, cws_analysis == "NaN" | cws_analysis == "Inf", NA)
    # 
    write.csv2(cws_analysis, file = paste("output_reworked/2_spatial_and_temporal_analysis_reworked/cws_analysis/cws_analysis_radius_", r, "_dt_" , dt ,".csv", sep = ""))
    rm(cws_be_08_dist_mean,cws_be_08_dist, cws_be_08_dist_name,
       cws_be_08_dt_mean, cws_be_08_dt,  cws_be_08_temp,
       cws_be_08_temp_weighted_mean, cws_be_08_temp_min_T_filter,
       cws_be_08_number_of_cws, cws_be_08_temp_difference_weighted_mean,
       cws_be_08_temp_difference_min_T_filter, cws_analysis)
  }
}


# list the generated files
c <- list.files(path="output_reworked/2_spatial_and_temporal_analysis_reworked/cws_analysis/")
cws_list = lapply(paste0("output_reworked/2_spatial_and_temporal_analysis_reworked/cws_analysis/",c), read.csv2)
names(cws_list) <- c(substr(c[1:length(c)],14,24))

# read the files from the list to single df
for (f in c){
  print(f)
  name <- f
  assign(name,read.csv2(file=paste0("output_reworked/2_spatial_and_temporal_analysis_reworked/cws_analysis/",f),
                        stringsAsFactors = F)[,-1])
  rm(name)
}; rm(c, f)


### end cws ###


# plots to check ----------------------------------------------------------


# compare IDW temperature to minimum filter T
t = c(2430:2470)
q = cws_analysis_radius_300_dt_900.csv[t,]
q2 = cws_analysis_radius_300_dt_900_incl_inf_NaN.csv[t,]

t1 = c(2000: 2400)
plot(bicycle$RecNo[t1], as.numeric(cws_analysis_radius_300_dt_900.csv$cws_be_08_temp_weighted_mean[t1]), type = "l")
lines(bicycle$RecNo[t1],as.numeric(cws_analysis_radius_300_dt_900.csv$cws_be_08_temp_min_T_filter[t1]), col = "red")

plot(bicycle$RecNo[t1], as.numeric(cws_analysis_radius_300_dt_900.csv$cws_be_08_temp_difference_weighted_mean[t1]), type = "l")
lines(bicycle$RecNo[t1],as.numeric(cws_analysis_radius_300_dt_900.csv$cws_be_08_temp_difference_min_T_filter[t1]), col = "red")


mean(abs(as.numeric(cws_analysis_radius_300_dt_900.csv$cws_be_08_temp_difference_weighted_mean)), na.rm=T)
mean(abs(as.numeric(cws_analysis_radius_300_dt_900.csv$cws_be_08_temp_difference_min_T_filter )), na.rm=T)

var(cws_analysis_radius_300_dt_900.csv$cws_be_08_temp_difference_weighted_mean, na.rm = T)
var(cws_analysis_radius_300_dt_900.csv$cws_be_08_temp_difference_min_T_filter, na.rm = T)



# Mean Logger Analysis -------------------------------------------------------------

### Define vector with log temperature along the bicycle transect ###

# loop through every bicycle measurement (=timestep, i) and write the following to new columns:
#define
rad <- c(100,150,200,250,300,400,500,600,
         700,800,900,1000,1500,2000,3000) # search radii
p <- 1 # power parameter for the inverse spatial distance function

### log for loop ###

###
for (r in rad){
  log_dist <- (c(rep(NA, nrow(log_bicycle)))) # distances of closest cws measurement
  log_dist_mean <- (c(rep(NA, nrow(log_bicycle)))) # mean of those distances
  log_dist_name <- (c(rep(NA, nrow(log_bicycle)))) # name of the cws within the radius (=column name)
  log_temp <- (c(rep(NA, nrow(log_bicycle)))) # temperature values of those cws
  log_temp_weighted_mean <- (c(rep(NA, nrow(log_bicycle)))) # weighted mean of those values
  log_number_of_log <- (c(rep(NA, nrow(log_bicycle)))) # the ammount of cws within the radius
  log_temp_difference <- (c(rep(NA, nrow(log_bicycle)))) # difference to bicycle temp
  
  for (i in 1:nrow(log_bicycle)){
    print(paste("Calulating row",i,"for radius",r,"meters"))
    if (is.na(min(dist_log_bicycle[i,]) == TRUE)){
      log_dist[i] <- NA
      log_dist_mean[i] <- NA
      log_dist_name[i] <- NA
      log_temp[i] <- NA
      log_temp_weighted_mean[i] <- NA
      log_number_of_log[i] <- NA
      log_temp_difference[i] <- NA
    }
    else if ((length(which((dist_log_bicycle[i,] <= r) == TRUE)) == 0L)==TRUE){
      # if no distance is within the radius
      log_dist[i] <- NA
      log_dist_mean[i] <- NA
      log_dist_name[i] <- NA
      log_temp[i] <- NA
      log_temp_weighted_mean[i] <- NA
      log_number_of_log[i] <- NA
      log_temp_difference[i] <- NA
    }
    else {
      # write to temporary variables
      temp_within_rad <- t(as.data.frame(which((dist_log_bicycle[i,] <= r) == TRUE))) # indices of distance values within radius
      temp_dist <- as.data.frame(dist_log_bicycle[i,temp_within_rad]) # distances of those indices (temporarily stored)
      temp_within_rad_1 <- temp_within_rad + 1 # +1 because log_bicycle is one column longer than dist)
      temp_temp <- data.table(log_bicycle[i, temp_within_rad_1]) # temperature of log within radius
      temp_temp <- as.data.frame(temp_temp) #convert back to df
      temp_name <- names(temp_temp) # names of the cws stations within the radius (stored temporarily)
      # write to actual vectors
      log_dist_mean[i] <- mean(as.numeric(temp_dist[])) # mean of those distances
      log_dist_name[i] <- paste(temp_name[],
                                collapse = ",") # collaps the names into one cell
      log_temp_weighted_mean[i] <- weighted.mean(temp_temp, (1/((temp_dist))^p), na.rm = TRUE) # mean of these temps
      log_number_of_log[i] <- length(temp_within_rad)
      log_dist[i] <- apply(temp_dist, 1,
                           function(x) paste(x[!is.na(x)],collapse = ", ")) # collaps distances into one cell
      log_temp[i] <- paste(temp_temp[1:ncol(temp_temp)],collapse = ", ") # collaps temperatures into 1 cell
      log_temp_difference[i] <- log_temp_weighted_mean[i]- bicycle$Temp.C[i]
      rm(temp_within_rad, temp_dist, temp_temp,temp_name, temp_within_rad_1) # remove temporary variables
    }
  }
  log_analysis <- as.data.frame(log_dist_mean)
  log_analysis$log_dist <- log_dist
  log_analysis$log_dist_name <- log_dist_name
  log_analysis$log_temp_weighted_mean <- log_temp_weighted_mean
  log_analysis$log_temp <- log_temp
  log_analysis$log_number_of_log <- log_number_of_log
  log_analysis$log_temp_difference <- log_temp_difference
  write.csv2(log_analysis,file = paste("output_reworked/2_spatial_and_temporal_analysis_reworked/log_analysis/log_analysis_radius_", r, ".csv", sep = ""))
  rm(log_dist, log_dist_mean,log_dist_name,log_temp,log_analysis,
     log_temp_weighted_mean,log_number_of_log, log_temp_difference)
}

# read the .csv files
l <- list.files(path="output_reworked/2_spatial_and_temporal_analysis_reworked/log_analysis/")
log_list = lapply(paste0("output_reworked/2_spatial_and_temporal_analysis_reworked/log_analysis/",l), read.csv2)
names(log_list) <- c(substr(l[1:length(l)],14,24))
rm(rad,p)

# read the files from the list to single df
for (f in l){
  print(f)
  name <- f
  assign(name,read.csv2(file=paste0("output_reworked/2_spatial_analysis_reworked/log_analysis/",f))[,-1])
  rm(name)
}; rm(f,l,rad,p)

### end mean log ###



