# install libraries
library("ggplot2")

# SET WORKING DIRECTORY
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

loggers <- read.csv(file = "Formatted Data/log.csv", sep=";")
time <- loggers$Time.HH

# log_A should be the "urban" one. Title is also the filename.
plot_temp_comparison <-
	function(time, log_A, log_B, log_C=NULL, station_A, station_B, station_C=NULL) {
		

		if(is.null(log_C)){
		  outfile = paste("Temperaturverlauf/", station_A, station_B, ".png", sep = "-")
			data <- data.frame(time, log_A, log_B)
			ggplot(data, aes(x = time, y = log_A, group = 1)) +
				geom_line(aes(y = log_A, color = "station_A")) +
				geom_line(aes(y = log_B, color = "station_B")) +
				theme_minimal() +
				coord_cartesian(ylim = c(15, 40)) +
			  scale_x_continuous(label = c("20:00", "01:00", "06:00", "11:00", "16:00")) +
			  scale_color_manual(name = "Loggerstation", values = c(station_A = "black", station_B = "blue")) +
			  labs(
					y = "Temperatur in Grad Celsius",
					x = "Zeit",
					title = "Temperaturverlauf",
					subtitle = "06.26. 20 Uhr - 27.06. 16 Uhr, 2019. "
				) + ggsave(outfile, dpi = "print")
		} else {
		  outfile = paste("Temperaturverlauf/", station_A, station_B, station_C, ".png", sep = "-")
			data <- data.frame(time, log_A, log_B, log_C)
			ggplot(data, aes(x = time, y = log_A, group = 1)) +
				geom_line(aes(y = log_A, color = "station_A")) +
				geom_line(aes(y = log_B, color = "station_B")) +
				geom_line(aes(y = log_C, color = "station_C")) +
				theme_minimal() +
				coord_cartesian(ylim = c(15, 40)) +
			  scale_x_continuous(label = c("20:00", "01:00", "06:00", "11:00", "16:00")) +
			  scale_color_manual(name = "Loggerstation", values = c(station_A = "black", station_B = "blue", station_C = "green")) +
			  labs(
					y = "Temperatur in Grad Celsius",
					x = "Zeit",
					title = "Temperaturverlauf",
					subtitle = "06.26. 20 Uhr - 27.06. 16 Uhr, 2019. "
				) + ggsave(outfile, dpi = "print")
		}
}

# Westside vs. Land
plot_temp_comparison(time, loggers$Log_61, loggers$Log_52, station_A="Westside", station_B="Bumpliz")

# Inselspital vs. Bremgartenfriedhof vs. Bremgartenwald
plot_temp_comparison(time, loggers$Log_26, loggers$Log_9, loggers$Log_32, station_A="Bremgartenfriedhof", station_B="Bremgartenwald", station_C="Inselspital")

