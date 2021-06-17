# libraries
install.packages ("ggplot2")
library("ggplot2")

# setting working directory
setwd("/Users/michelegrindat/RIG-HeatMap/output_reworked/0_pre_processing_orig/log")
getwd()

# read & view data
log <- read.csv(file = "log.csv")
View(log)

# create data
xValue <- log$date_time_gmt_plus_2
logger1 <- log$Log_26
logger2 <- log$Log_9
data <- data.frame(xValue,logger1,logger2)

# Plot
ggplot(data, aes(x=xValue, y=logger1, group = 1)) +
  geom_line(aes(y=logger1), color="blue") +
  geom_line(aes(y=logger2), color="green") +
  labs(x = "Zeit", y = "Temperatur C", title = "Temperaturverlauf")
