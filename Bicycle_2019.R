# First readout Bicycle transects 2019

# setwd to current folder
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))


#Specify Infile Transect and GPS files
INFILE_Transect <- "Raw Data/Transekt_Juni_2019/Transekt_Juni_2019.txt"
INFILE_GPS <- "Raw Data/Transekt_Juni_2019/Transekt_Juni_2019.CSV"

# read and prepare dataframes ---------------------------------------------------------------

### import your file to R:
INFILE   <- INFILE_Transect
transect <- read.csv(INFILE, header=FALSE, na.string=c("-6999","6999"))
colnames(transect) <- c("ID", "Year", "DOY", "HHMM", "Seconds", "Temp.degC",
                        "RelHum.percent", "CO2.ppm", "H2O.degC", "Tdew?", "Tfrost?")


### generate a continuous time variable:
### timestamp is GMT (i.e. in summer localtime-2hours)
transect$TIMESTAMP <- strptime(sprintf("%04d %03d %04d %02f", transect$Year, transect$DOY, 
                                       transect$HHMM, transect$Seconds), "%Y %j %H%M %S", tz="GMT")



### import your file to R:
INFILE  <- INFILE_GPS
gps     <- read.csv(INFILE,header=TRUE)

# install.packages("stringr")
library(stringr)
### in GPS file only the last two digits are given, 
### thus add 20 to column DATE to get 2017
gps$DATE[1:10]
gps$DATE <- as.numeric(paste(20,gps$DATE, sep=""))
gps$DATE[1:10]

### now you can generate a continuous time variable:
### timestamp is GMT (i.e. in summer localtime-2hours)
gps$TIMESTAMP <- strptime(sprintf("%06d %06d", gps$DATE, gps$TIME), "%Y%m%d %H%M%S", tz="GMT")



# Interpolate GPS position to match CR10X records -------------------------


### create numeric timestamp
transect$TNUM <- as.numeric(transect$TIMESTAMP)
gps$TNUM      <- as.numeric(gps$TIMESTAMP)

### in GPS file latitude values are followed by N or W,
### remove N after latitude value
gps$LATITUDE.N.S[1:10]
gps$LATITUDE  <- as.numeric(substr(gps$LATITUDE.N.S, 1, 9))
options(digits=10)
gps$LATITUDE[1:10]

### interpolate longitude latitude values from GPS dat to Transect data
transect$X    <- approx(gps$TNUM, gps$LONGITUDE.E.W, xout=transect$TNUM, rule=2)$y
transect$Y    <- approx(gps$TNUM, gps$LATITUDE, xout=transect$TNUM, rule=2)$y
transect$Z    <- approx(gps$TNUM, gps$HEIGHT, xout=transect$TNUM, rule=2)$y




# Check data with plots ---------------------------------------------------

# Note that often the GPS or data loggers were started at different times
# This can lead to data in "transect" with no latitude or longitude change.
# Probably discard that data later manually as that is between transects
# when the bike was not moving  (but plot it in GIS first to really check)


# Plots for finding constant lon/lat values
par(mfrow=c(1,2), mar=c(4, 4, 1.8, 2))
plot(transect$X)
plot(transect$Y)


# plot lat,lon together
par(mfrow=c(1,1), mar=c(4, 4, 1.8, 2))
plot(transect$X, transect$Y)


# save data ---------------------------------------------------------------

# save only 
write.csv(transect, row.names = F
          , file = "Transekt1_2019.csv")


