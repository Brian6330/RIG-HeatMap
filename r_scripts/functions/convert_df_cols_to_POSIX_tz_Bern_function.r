# convert time to POSIX function


convert_df_cols_to_POSIX_tz_Bern <- function(dataframe, column_numbers){
  for (i in column_numbers){
    dataframe[,i] <- as.POSIXct(as.character(dataframe[,i]), tz = "Europe/Berlin")
  }
}

