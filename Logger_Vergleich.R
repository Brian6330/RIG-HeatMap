# install libraries
library("ggplot2")

# SET WORKING DIRECTORY
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

loggers <- read.csv(file = "Formatted Data/log.csv", sep=";")
time <- loggers$Time.HH

# log_A should be the "urban" one. Title is also the filename.
plot_temp_comparison <-
	function(time, log_A, log_B, log_C=NULL, title) {
		outfile = paste("Temperaturverlauf/", title, ".png", sep = "")

		if(is.null(log_C)){
			data <- data.frame(time, log_A, log_B)
			ggplot(data, aes(x = time, y = log_A, group = 1)) +
				geom_line(aes(y = log_A), color = "black") +
				geom_line(aes(y = log_B), color = "blue") +
				theme_minimal() +
				coord_cartesian(ylim = c(15, 40)) +
			  scale_x_continuous(label = c("20:00", "01:00", "06:00", "11:00", "16:00")) +
				labs(
					y = "Temperatur in degrees Celsius",
					x = "Zeit",
					title = title,
					subtitle = "Temperaturverlauf 06.26. 20 Uhr - 27.06. 16 Uhr, 2019. "
				) + ggsave(outfile, dpi = "print")
		} else {
			data <- data.frame(time, log_A, log_B, log_C)
			ggplot(data, aes(x = time, y = log_A, group = 1)) +
				geom_line(aes(y = log_A), color = "black") +
				geom_line(aes(y = log_B), color = "blue") +
				geom_line(aes(y = log_C), color = "green") +
				theme_minimal() +
				coord_cartesian(ylim = c(15, 40)) +
			  scale_x_continuous(label = c("20:00", "01:00", "06:00", "11:00", "16:00")) +
				labs(
					y = "Temperatur in degrees Celsius",
					x = "Zeit",
					title = title,
					subtitle = "Temperaturverlauf 06.26. 20 Uhr - 27.06. 16 Uhr, 2019. "
				) + ggsave(outfile, dpi = "print")
		}
}

# Westside vs. Land
plot_temp_comparison(time, loggers$Log_61, loggers$Log_52, title="Loggerstation Westside vs. Loggerstation Bümpliz Land")

# Inselspital vs. Bremgartenfriedhof vs. Bremgartenwald
plot_temp_comparison(time, loggers$Log_26, loggers$Log_9, loggers$Log_32, "Loggerstation Bremgartenfriedhof vs. Bremgartenwald vs. Loggerstation Inselspital")

