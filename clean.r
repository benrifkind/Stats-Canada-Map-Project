############################

# 
# Clean the data.frame
# Helper functions

#remove surrounding whitespace
trim <- function (x) gsub("^\\s+|\\s+$", "", x)

#removes spaces and "[ ]# from the data frame of statistics 
clean.data <- function(data){
  names(data) = c("Characteristics", "Total", "English", "French")
  data$Characteristics= fix.labels(data$Characteristics)
  return(data)
}


#fixes bad column labels
fix.labels <- function(data.column){
  #data.column = gsub("\\[.*\\]", "", data.column)
  data.column = trim(data.column)
  #data.column = gsub("\"", "", data.column)
  return(data.column)
}

# 
# End clean data frame
# 