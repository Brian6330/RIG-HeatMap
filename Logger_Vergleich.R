# install libraries
library("ggplot2")

# SET WORKING DIRECTORY
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

loggers <- read.csv(file = "output_reworked/0_pre_processing_orig/log/log.csv")
time <- loggers$log.date_time_gmt_plus_2

# log_A should be the "urban" one, log_B the other one. Title is also the filename
plot_temp_comparison <- function(time, log_A, log_B, title) {
	outfile = paste("Temperaturverlauf/", title, ".png", sep="")

	data <- data.frame(time,log_A,log_B)
	ggplot(data, aes(x=time, y=log_A, group = 1)) +
		geom_line(aes(y=log_A), color="black") +
		geom_line(aes(y=log_B), color="blue") +
		theme_minimal() +
		coord_cartesian(ylim = c(15, 40)) +
		labs(y = "Temperatur in °C", x = "Zeit", title = title, subtitle = "Temperaturverlauf 06.26. 20 Uhr - 27.06. 16 Uhr, 2019. ") +
		ggsave(outfile, dpi = "print")
}

# Westside vs. Land
plot_temp_comparison(time, loggers$Log_61, loggers$Log_52, "Loggerstation Westside vs. Loggerstation Bümpliz Land")

