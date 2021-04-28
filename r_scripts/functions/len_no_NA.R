# lenght excluding NA values
len_no_NA <- function(x){
  length(x[(!is.na(x))])
}
