# SET WORKING DIRECTORY
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

library(ggplot2)

log <- read.csv(file = "../../Formatted Data/log.csv", sep=";")


# create data
xValue <- log$date_time_gmt_plus_2
timeScale <- log$Time.HH
urban <- log$Log_82
green <- log$Log_33
data <- data.frame(xValue,urban,green)

# Plot
ggplot(data, aes(x=timeScale, y=urban, group = 1)) +
  geom_line(aes(y=urban), color="black") +
  geom_line(aes(y=green), color="green") +
  labs(x = "Zeit", y = "Temperatur C", title = "Temperaturverlauf") +
  scale_x_continuous(label = c("20:00", "01:00", "06:00", "11:00", "16:00"))

#plot(factor(log$date_time_gmt_plus_2), log$Log_82, type="l") #Thunplatz
#lines(log$Log_33)
#points(log$log_33)
#lines(log$Log_82)
