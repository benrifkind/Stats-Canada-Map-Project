# Rearrange the data. From bunch of files of each census divison with statistics to files of  
# each statistic with census division 


# Input province, characteristic, number of subcategories
# Output is files: each file is a characteristic with data for each census division
# of that province 
getCategories = function(province = "Ontario", 
                         characteristic = "Total population by immigrant status and place of birth",
                         depth = 2){
  df.list = getProvinceFiles("Ontario")
  df.list = sapply(df.list, getSubCategory, characteristic = characteristic, 
                   depth = depth, simplify = FALSE)
  characteristics = df.list[[1]][['Characteristics']]
  df.list = sapply(characteristics, getCharDataFrame, df.list = df.list, simplify = F)
  #write to file
  dir.name = paste(province, characteristic, sep = " - ")
  dir.create(dir.name)
  lapply(names(df.list), 
         function(x) {
           write.csv(df.list[[x]], 
                     paste0(paste(dir.name, x, sep = "/"), ".csv") )
         }
  )
}

# Read files from a particular province
# Values is list of data frames 
# Skip first 4 rows and look at only 830 total rows of interest since end of file is notes
getProvinceFiles <- function(province){
 province.dir = paste0("StatsCanadaData/", province) 
 file.names = list.files(province.dir, full.name = T)
 names(file.names) = gsub(".csv", "", list.files(province.dir, full.name = F))
 temp = sapply(file.names, read.csv, skip = 5, nrows = 830, 
        col.names = c("Characteristics", "Total", "English", "French", "English and French"), 
        header = F,
        simplify = FALSE)
 sapply(temp, cleanUp, simplify = FALSE)
}


# Construct data frame of characteristic over all census divisions
# input is list of data frames, characteristic
# output is data frame
getCharDataFrame <- function(df.list, characteristic){
  helper = function(x){
   x[x[[1]] == characteristic, ]
  }
  temp = sapply(df.list, helper, simplify = F) 
  do.call(rbind, temp)
}

# Fixes formatting of the data frame
# change name of first column to Characteristics
# removes footnotes ([]) from first column.
cleanUp <- function(df){
  column = "Characteristics"
  df[[column]] = gsub("\\[.+\\]", "", df[[column]])
  df[[column]] = gsub("(\\$$)|(\\$\\s$)", "in CDN", df[[column]])
  df[[column]] = gsub("\\s+$", "", df[[column]])
  df
}

# helper function that extracts a particular characteristic of the data and all subcategories
# top category has no spaces at start of the word, sub catergory has 2 spaces, sub sub has 4 
# input is the data frame and characteristics we want
# value is subset of the data frame
getFullCategory <- function(df, characteristic){
 begin = grep(paste0("\\w*", characteristic), df[["Characteristics"]])
 end = begin
 bool = TRUE
 while (bool){ 
   bool = grepl("^\\s", df[["Characteristics"]][end+1])
   end = end + 1
 }
 return(df[begin:(end-1),])
}

## helper function that extracts a particular characteristic of the data and specified subcat
# input is the data frame, characteristics, and number of subcategories
# value is subset of the data frame
getSubCategory <- function(df, characteristic, depth){
 depth = 2*depth +1
 temp = getFullCategory(df, characteristic)
 temp[!(grepl(paste0("^\\s{", depth,"}"), temp[["Characteristics"]])),]
}

# get the top level characteristics of the data frame
getCharacters <- function(df){
 df[grepl("^\\w", df[["Characteristics"]]), ][["Characteristics"]] 
}