# install libraries
library("ggplot2")
library("tidyverse")

# SET WORKING DIRECTORY
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

loggers <- read.csv(file = "Formatted Data/log.csv", sep=";")
time <- loggers$Time_HH

# log_A should be the "urban" one. Title is also the filename.
plot_temp_comparison <-
	function(time, log_A, log_B, log_C=NULL, station_A, station_B, station_C=NULL) {

		if(is.null(log_C)){
		  outfile = paste("Temperaturverlauf/", station_A, station_B, ".png", sep = "_")
			data <- data.frame(time, log_A, log_B)
			ggplot(data, aes(x = time, y = log_A, group = 1)) +
				geom_line(aes(y = log_A, color = "black")) +
				geom_line(aes(y = log_B, color = "green")) +
				theme_minimal() +
				coord_cartesian(ylim = c(16, 38)) +
				scale_x_continuous(labels = c("20:00", "02:00", "08:00", "14:00", "20:00"), 
				                   breaks = c(20,26,32,38,44)) +
			  scale_colour_manual(name = "Loggerstation", values = c("black","green"), labels = c(station_A, station_B)) +
			  geom_hline(yintercept = 20, color="red") +
			  labs(
					y = "Temperatur in Grad Celsius",
					x = "Zeit",
					title = "Temperaturverlauf",
					subtitle = "20:00 06.26.19  - 20:00 27.06.19 "
				) + ggsave(outfile, dpi = "print")
		} else {
		  outfile = paste("Temperaturverlauf/", station_A, station_B, station_C, ".png", sep = "_")
			data <- data.frame(time, log_A, log_B, log_C)
			ggplot(data, aes(x = time, y = log_A, group = 1)) +
				geom_line(aes(y = log_A, color = "black")) +
				geom_line(aes(y = log_B, color = "blue")) +
				geom_line(aes(y = log_C, color = "green")) +
				theme_minimal() +
				coord_cartesian(ylim = c(16, 38)) +
			  scale_x_continuous(labels = c("20:00", "02:00", "08:00", "14:00", "20:00"), 
			                     breaks = c(20,26,32,38,44)) +
			  scale_color_manual(name = "Loggerstation", values = c("black", "blue", "green"), labels = c(station_A, station_B, station_C)) +
			  geom_hline(yintercept = 20, color="red") +
			  labs(
					y = "Temperatur in Grad Celsius",
					x = "Zeit",
					title = "Temperaturverlauf",
					subtitle = "20:00 06.26.19  - 20:00 27.06.19 "
				) + ggsave(outfile, dpi = "print")
		}
	}

# Westside vs. Land
plot_temp_comparison(time, loggers$Log_61, loggers$Log_52, station_A="Westside", station_B="Umland Bumpliz")

# Inselspital vs. Bremgartenfriedhof vs. Bremgartenwald
plot_temp_comparison(time, loggers$Log_26, loggers$Log_9, loggers$Log_32, station_A="Inselspital", station_B="Bremgartenfriedhof", station_C="Bremgartenwald")

# Europaplatz vs. Schlossmatte Familiengärten
plot_temp_comparison(time, loggers$Log_2, loggers$Log_59, station_A="Europaplatz", station_B="Schlossmatte Familiengarten")

# Viktoriarein vs. Kasernenareal
plot_temp_comparison(time, loggers$Log_36, loggers$Log_34, station_A="Viktoriarein", station_B="Kasernenareal")

# Galgenfeld Neubausidelung vs. Galgenfeldindustrie vs. Rosengarten
plot_temp_comparison(time, loggers$Log_19, loggers$Log_30, loggers$Log_17, station_A="Galgenfeld Neubausiedlung", station_B="Galgenfeldindustrie", station_C="Rosengarten")

# Helvetiaplatz vs. Egelsee-Siedlung  vs.  Egelsee
plot_temp_comparison(time, loggers$Log_14, loggers$Log_12, loggers$Log_13, station_A="Helvetiaplatz", station_B="Egelsee Siedlung", station_C="Egelsee")

# Thunplatz vs. Dalholzli-Wald
plot_temp_comparison(time, loggers$Log_82, loggers$Log_33, station_A="Thunplatz", station_B="Dalholzli-Wald")
