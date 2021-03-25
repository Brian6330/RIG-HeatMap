# Netatmo statistical analysis

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
library("RColorBrewer") # for plotting colours
library("sos") # for better searching options (grepFn)


# load functions
source("r_scripts/functions/len_no_NA.R")

# Load files --------------------------------------------------------------

# bicycle
bicycle <- read.csv(file = "output_reworked/0_pre_processing_orig/bicycle/bicycle.csv")
bicycle$Date.Time <- as.POSIXct(bicycle$Date.Time,
                                tz = "Europe/Zurich") # convert to POSIXct

#log
log <- read.csv(file="output_reworked/0_pre_processing_orig/log/log.csv")[-1]
log$date_time_gmt_plus_2 <- as.POSIXct(log$date_time_gmt_plus_2,
                              tz = "Europe/Zurich")
log_meta <- read.csv(file="output_reworked/0_pre_processing_orig/log/log_meta.csv")

# cws
cws_be_08 <- read.csv(file="output_reworked/0_pre_processing_orig/cws_be_08/cws_be_08.csv")[-1]
cws_be_08$time_orig <- as.POSIXct(cws_be_08$time_orig,
                                       tz = "Europe/Zurich")
cws_be_08_meta <- read.csv(file="output_reworked/0_pre_processing_orig/cws_be_08/cws_be_08_meta.csv")

# time distance
log_bicycle_dt <- read.csv(file="output_reworked/0_pre_processing_orig/distance/log_bicycle_dt.csv",
                      header = T)

# distance matrices
files <- list.files(path="output_reworked/0_pre_processing_orig/distance/")
for (f in files){
  print(f)
  name <- substr(f,1,nchar(f)-4)
  assign(name,read.csv(file=paste0("output_reworked/0_pre_processing_orig/distance/",f),
                       header = T, sep = ","))
  rm(name)
}; rm(f, files)

Date.Time <- bicycle$Date.Time
log_spatial_distance <- cbind(Date.Time, dist_log_bicycle)

# log_list
l <- list.files(path="output_reworked/2_spatial_and_temporal_analysis_reworked/log_analysis/")
log_list = lapply(paste0("output_reworked/2_spatial_analysis_reworked/log_analysis/",l), read.csv2)
names(log_list) <- c(substr(l[1:length(l)],14,nchar(l)-4)); rm(l)

# cws_list
c <- list.files(path="output_reworked/2_spatial_and_temporal_analysis_reworked/cws_analysis")
cws_list = lapply(paste0("output_reworked/2_spatial_and_temporal_analysis_reworked/cws_analysis/",c), 
                  function(i){read.csv2(i, stringsAsFactors = F)})
names(cws_list) <- c(substr(c[1:length(c)],14,nchar(c)-4)); rm(c)


# transect means

#log
log_transect_means <- read.csv(file="output_reworked/1b_processing_transect_means/log_means.csv",
                      header = T)
#cws
cws_transect_means <- read.csv(file="output_reworked/1b_processing_transect_means/cws_means.csv",
                               header = T)

# Select and prepare data --------------------

# Select only LOG rad200, rad500 and CWS rad500 (temporarily)
log500 <- log_list$radius_500[,-1] # without first row, which is just index
log200 <- log_list$radius_200[,-1] # without first row, which is just index
cws500 <- cws_list$radius_500_dt_3600[,-1] # without first row, which is just index



# combine bicycle, log200, cws500
all <- cbind(bicycle,log200,cws500)
log500_interpolation <- cbind(bicycle$Date.Time, log500)
rm(log200,cws500, log500)

# Select only 22:00 to 06:00
all_night <- subset(all, Date.Time >= "2018-08-07 22:00:00" & Date.Time <= "2018-08-08 06:00:00")
log500_interpolation_night <- subset(log500_interpolation, Date.Time >= "2018-08-07 22:00:00" & Date.Time <= "2018-08-08 06:00:00")
rm(all, log500_interpolation)
log_mean_night <- data.frame(log_transect_means$NUMMER, log_transect_means$night_22_06)
cws_mean_night <- data.frame(cws_transect_means$p_id, cws_transect_means$night_22_06)

log_spatial_distance_night <- subset(log_spatial_distance, Date.Time >= "2018-08-07 22:00:00" & bicycle$Date.Time <= "2018-08-08 06:00:00")

# combine log/cws transect means with metadata (coordinates)
cws_mean_night <- inner_join(cws_mean_night, cws_be_08_meta, by = c("cws_transect_means.p_id" = "p_id"))
log_mean_night <- inner_join(log_mean_night, log_meta, by = c("log_transect_means.NUMMER" = "NUMMER"))


# remove unecessary data
rm(bicycle,cws_be_08,cws_list,cws_transect_means,
   log,log_list,log_transect_means, time_dist, log_meta, cws_be_08_meta,
   log_spatial_distance, Date.Time)



# difference between mean night T and current T (log) -------------

# add night mean T of loggers within radius
log_temp_night_weighted_mean <- (c(rep(NA, nrow(all_night))))

# set parameters for loop
# i <- 1339 (1337, 1338, 1339 have 4 loggers within the radius 200m)
# i <- 65 (here there are two loggers within 200m)

p <- 1 

for (i in 1:nrow(all_night)){
  # NA if no LCD within radius
  if (is.na(all_night$log_dist_name[i]) == TRUE){
    log_temp_night_weighted_mean[i] <- NA
  }
  else {
    # names and temperatures of loggers within radius of the current bicycle measurement
    temp_string <- paste0(all_night$log_dist_name[i])
    temp_unlisted <- unlist(strsplit(temp_string, ","))
    temp_log_temp <- ((rep(NA, length(temp_unlisted))))

    # distance of loggers within radius
    temp_dist_string <- paste0(all_night$log_dist[i]) # select the distances
    temp_dist_unlisted <- as.numeric(unlist(strsplit(temp_dist_string, ",")), digits = 5)
    rm(temp_string, temp_dist_string)
    
    # extract columns from log_mean_night which match these logger names
    for (k in 1:length(temp_unlisted)){
      temp_row_selection <- grepFn(temp_unlisted[k], log_mean_night, column='objectID') # temporarily save the correct row from log_mean_night
      temp_row_selection <- temp_row_selection[temp_row_selection$objectID == (temp_unlisted[k]), ]
      temp_log_temp[k] <- as.numeric(temp_row_selection[2], digits = 5) # save the transect mean T of that logger
          }
  # calculate the distance weighted means of these mean night temperatures
    log_temp_night_weighted_mean[i] <- weighted.mean(temp_log_temp, (1/((temp_dist_unlisted))^p), na.rm = TRUE) # mean of these temps
  }
}

# save night weighted mean as data frame for better viewing
# log_temp_night_weighted_mean <- as.data.frame(log_temp_night_weighted_mean)



# find delta_T_log between current T_log and night mean T_log -------------
delta_T_log <- (c(rep(NA, nrow(all_night))))


for (i in 1:nrow(all_night)){
  if (is.na(all_night$log_temp_weighted_mean[i]) == TRUE){
    delta_T_log[i] <- NA
  }
  else {
    # calculate delta T between T at current time (ll_night$log_temp_weighted_mean[i])
    # and mean night temperature of those loggers (log_temp_night_weighted_mean[i])
    delta_T_log[i] <- all_night$log_temp_weighted_mean[i] - log_temp_night_weighted_mean[i]
  }
}

# plot to check
plot(all_night$Date.Time, delta_T_log)
abline(h = 0)
# we see that at the beginning of the night the values were warmer than the nights average.
# As temperatures drop, the values are lower than average.


# subtract delta_T_log from bicycle T to get diurnaly adjusted T --------

bicycle_T_diurnal_corrected <- (c(rep(NA, nrow(all_night))))

for (i in 1:nrow(all_night)){
  bicycle_T_diurnal_corrected[i] <- all_night$Temp.C[i] - delta_T_log[i]
}

# plot to check
plot(all_night$Date.Time, bicycle_T_diurnal_corrected)

# check with bicycle data
plot(all_night$Date.Time, all_night$Temp.C)
plot(bicycle$RecNo, bicycle$Temp.C)
abline(v = c(3564,5484))


# remove temporary data
rm(temp_dist_unlisted, temp_log_temp, temp_unlisted, k, p, i, temp_row_selection)

# add newly calculated data to all_night
all_night$log_temp_night_weighted_mean <- log_temp_night_weighted_mean
all_night$delta_T_log <- delta_T_log
all_night$bicycle_T_diurnal_corrected <- bicycle_T_diurnal_corrected

rm(log_temp_night_weighted_mean, delta_T_log, bicycle_T_diurnal_corrected)

# plot the corrected mean data
plot(all_night$log_temp_night_weighted_mean)
plot(all_night$bicycle_T_diurnal_corrected)



# interpolate the T correction for bicycle data within 500m of a logger --------

# lists to store the next/previous delta_T and their weights
delta_T_log_unweighted <- matrix((c(rep(NA, 2*nrow(all_night)))),ncol = 2)
delta_T_log_weights <- matrix((c(rep(NA, 2*nrow(all_night)))),ncol = 2)
colnames(delta_T_log_unweighted) <- c("forwards","backwards")
colnames(delta_T_log_weights) <- c("forwards","backwards")

# lists to store the IDW delta_T and the additional bicycle_T
delta_T_interpolated <- (c(rep(NA, nrow(all_night))))
bicycle_T_diurnal_corr_interpolated <- (c(rep(NA, nrow(all_night))))

# find delta_T_log_forward/backward

# radius for interpolation is 500m. If changed, then change
# log500_interpolation_night to whichever distance you want
# This is done in Section "Load and select data")

# define file with data of radius for which to interpolate (here it is 500m)
log_bicycle_interpolation_radius_night <- log500_interpolation_night
rm(log500_interpolation_night)

# i <- 3 #(within 500m but not within 200m)
# i <- 19 # NA value with one NA on each side, so the script will have to iterate

p <- 1 # power value for weighting function

for (i in 1:nrow(all_night)){
  
  # if bicycle measurement is already within 200m (is.na == FALSE)
  if (is.na(all_night$bicycle_T_diurnal_corrected[i])== FALSE) {
    bicycle_T_diurnal_corr_interpolated[i] <- all_night$bicycle_T_diurnal_corrected[i] # copy diurnal correction value
  } else if ((is.na(log_bicycle_interpolation_radius_night$log_dist[i]) == TRUE)) { # if is outside 500m radius
    bicycle_T_diurnal_corr_interpolated[i] <- NA # don't interpolate
  }
  
  # this leaves only values not within 200m, but within 500m
  # these we interpolate
  else {
    # iterate forward through bicycle data until one has a delta_T correction
    f <- i # start forward iteration at step i
    while ((is.na(all_night$delta_T_log[f]) == TRUE)&(f <= nrow(all_night))){
      print(f)
      f = f + 1
    }
    delta_T_log_unweighted[i,1] <- all_night$delta_T_log[f]
    
    # iterate backwards through bicycle data until one is within 500m

    b <- i # start backward iteration at step i
    while ((is.na(all_night$delta_T_log[b]) == TRUE)&(b > 1)){
      print(b)
      b = b - 1
    }
    delta_T_log_unweighted[i,2] <- all_night$delta_T_log[b]

    # find weights (distances between bicycle - log)
    # forwards
    delta_T_log_weights[i,1] <- (pointDistance(all_night[i,c("Longitude.E.","Latitude.N.")], # current bicycle point
                                                            all_night[f,c("Longitude.E.","Latitude.N.")], lonlat = TRUE))
    
    # backwards
    delta_T_log_weights[i,2] <- (pointDistance(all_night[i,c("Longitude.E.","Latitude.N.")], # current bicycle point
                                                        all_night[b,c("Longitude.E.","Latitude.N.")], lonlat = TRUE))
    

    # calculate delta_T_interpolated
    delta_T_interpolated[i] <- weighted.mean(delta_T_log_unweighted[i,], (1/((delta_T_log_weights[i,]))^p))
    bicycle_T_diurnal_corr_interpolated[i] <- all_night$Temp.C[i] - delta_T_interpolated[i]
  }
}


# test with plots

# delta T
par(mfrow = c(1,2))
plot(all_night$delta_T_log, col = "red", type = "l", xlim = c(0,50))
abline(v=10)
plot(delta_T_interpolated, type = "l", xlim = c(0,50)) # many more measurements are now included
abline(v=10)
# the two do not overlap though!

# bicycle T (interpolated and not)
par(mfrow = c(1,2))
plot(all_night$bicycle_T_diurnal_corrected, col = "red", type = "l", xlim = c(0,500))
abline(v=10)
plot(bicycle_T_diurnal_corr_interpolated, type = "l", xlim = c(0,500)) # many more measurements are now included
abline(v=10)
par(mfrow = c(1,1))


# remove temporary data
rm(temp_dist_unlisted, temp_log_temp, temp_unlisted, k, p, i, temp_row_selection)
rm(delta_T_log_unweighted, delta_T_log_weights)

# add newly calculated data to all_night
all_night$log_temp_night_weighted_mean <- log_temp_night_weighted_mean
all_night$delta_T_log <- delta_T_log
all_night$bicycle_T_diurnal_corrected <- bicycle_T_diurnal_corrected
all_night$delta_T_log_interpolated <- delta_T_interpolated
all_night$bicycle_T_diurnal_corr_interpolated <- bicycle_T_diurnal_corr_interpolated

rm(log_temp_night_weighted_mean, delta_T_log, bicycle_T_diurnal_corrected)
rm(delta_T_interpolated, bicycle_T_diurnal_corr_interpolated,b,f)

# plot the corrected mean data
plot(all_night$log_temp_night_weighted_mean)
plot(all_night$bicycle_T_diurnal_corrected)

bicycle_T_diurnal_corr_interpolated <- as.data.frame(bicycle_T_diurnal_corr_interpolated)

# plot original 200m delta T and interpolated delta T
plot(all_night$delta_T_log, type = "l")
lines(all_night$delta_T_log_interpolated, col = "red")

# plot interpolated bicycle data
plot(all_night$bicycle_T_diurnal_corr_interpolated, type = "l")
lines(all_night$bicycle_T_diurnal_corrected, col = "red")


# only select columns from all night, which I really need
# recno, datetime, lat, lon, bicycle T diurnal corrected
bicycle_diurnal_corrected <- all_night[,c(1,2,7,8,38)]




# Plots of Night delta_T, ammount of cws/log included ---------------------------


plot(all_night$Date.Time, all_night$cws_be_08_temp_difference, pch = 3, main = "delta T [K]")
points(all_night$Date.Time, all_night$log_temp_difference, col = "red", pch = 3)
abline(h=0)
legend.text <- c("cws_r500","log_r200")
legend.col <- c("black", "red")
legend("topleft", legend = legend.text,
       col=legend.col, lty=1, cex=0.6)


plot(all_night$Date.Time, all_night$cws_be_08_number_of_cws, type= "l", main = "delta T [K]")
points(all_night$Date.Time, all_night$log_temp_difference, col = "red", pch = 3)
abline(h=0)
legend.text <- c("cws_r500","log_r200")
legend.col <- c("black", "red")
legend("topleft", legend = legend.text,
       col=legend.col, lty=1, cex=0.6)


# all night
colnames <- colnames(all_night)
colnames <- gsub("\\.","_",colnames)
colnames <- gsub("__","",colnames)
colnames(all_night) <- colnames

# cws and log night mean and meta
colnames <- colnames(log_mean_night)
colnames <- gsub("\\.","_",colnames)
colnames(log_mean_night) <- colnames

colnames <- colnames(cws_mean_night)
colnames <- gsub("\\.","_",colnames)
colnames(cws_mean_night) <- colnames




# plots and analysis -------------------------------------------------------------------

### summary statistics
# BCY
min(bicycle_diurnal_corrected$bicycle_T_diurnal_corr_interpolated, na.rm=T)
max(bicycle_diurnal_corrected$bicycle_T_diurnal_corr_interpolated, na.rm=T)
mean(bicycle_diurnal_corrected$bicycle_T_diurnal_corr_interpolated, na.rm=T)
var(bicycle_diurnal_corrected$bicycle_T_diurnal_corr_interpolated, na.rm=T)

# CWS
min(cws_mean_night$cws_transect_means_night_22_06, na.rm=T)
max(cws_mean_night$cws_transect_means_night_22_06, na.rm=T)
mean(cws_mean_night$cws_transect_means_night_22_06, na.rm=T)
var(cws_mean_night$cws_transect_means_night_22_06, na.rm=T)

# LCD
min(log_mean_night$log_transect_means_night_22_06, na.rm=T)
max(log_mean_night$log_transect_means_night_22_06, na.rm=T)
mean(log_mean_night$log_transect_means_night_22_06, na.rm=T)
var(log_mean_night$log_transect_means_night_22_06, na.rm=T)

# boxplots
dT_cols <- c("orange", "#00CDFF", "darkgreen")

par(xpd=F)
par(mfrow=c(1,1), mar=c(2.3, 3.9, 1.8, 1))
boxplot(cws_mean_night$cws_transect_means_night_22_06
        ,log_mean_night$log_transect_means_night_22_06
        ,bicycle_diurnal_corrected$bicycle_T_diurnal_corr_interpolated
        , na.rm =T
        ,axes = FALSE
        ,col = dT_cols
        , ylab = "T [K]"
        ,varwidth = F
        ,main = "Mean night temperature"
        ,cex.main = 1
        ,cex.axis = 0.9
        ,cex.lab = 0.9
)

axis(2, at=c(seq(from = 20, to = 30, by = 2)), cex.axis = 0.9)
axis(1, at = c (1,2,3)
     ,labels = c("CWS", "LCD", "BCY")
     ,lwd.ticks = FALSE
     ,lwd = 0
     ,cex.axis = 0.9
)


## data coverage and sample size

# sample size n
length(log_mean_night$log_transect_means_night_22_06)
len_no_NA(log_mean_night$log_transect_means_night_22_06)

# save files --------------------------------------------------------------
# save colnames without . ("dot"), which is hard for GIS to deal with

dir.create("output_reworked/4_diurnal_cycle_reduction_for GIS/")

# write.csv(all_night,row.names = F,
#           file = paste0("output_reworked/4_diurnal_cycle_reduction_for GIS/","all_night_means_22_06.csv"))
# 
# write.csv(bicycle_diurnal_corrected,row.names = F,
#           file = paste0("output_reworked/4_diurnal_cycle_reduction_for GIS/","bicycle_diurnal_corrected.csv"))
# 
# write.csv(cws_mean_night,row.names = F,
#           file = paste0("output_reworked/4_diurnal_cycle_reduction_for GIS/","cws_mean_night.csv"))
# write.csv(log_mean_night,row.names = F,
#           file = paste0("output_reworked/4_diurnal_cycle_reduction_for GIS/","log_mean_night.csv"))
# 

