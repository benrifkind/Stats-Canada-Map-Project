#necessary stuff to run at start
source("clean.r")
library('rgeos')
library('maptools')
library('ggmap')

provinces = c("Newfoundland and Labrador", "Prince Edward Island", "Nova Scotia", 
              "New Brunswick", "Quebec", "Ontario", "Manitoba", "Saskatchewan", 
              "Alberta", "British Columbia", "Yukon", "Northwest Territories", "Nunavut")

#######################
##Stats Canada Data Side
#######################

#data for each province is in folder "Canada Ethnic Stats/Province Stats/"
#each file is a csv file named according to its ethnic statistic
#each row of the csv file is the data for the statistic for the census division

#function of province name 
#returns list of data.frames for each ethnic stat.
get.P.data = function(province){
  p.folder =  paste(province, "Stats", sep = " ")
  total.dir = paste0("Canada Ethnic Stats/", p.folder)
  division.names = gsub(".csv", "", list.files(total.dir)) #names of census divs
  files = list.files(total.dir, full.names = TRUE, include.dirs = TRUE) #filepath of census div
  x = lapply(files, read.csv)
  names(x) = division.names
  return(x)
}


#import all provincial ethnic data to a list of lists
get.P.all = function(){
  sapply(provinces, get.P.data, simplify = FALSE, USE.NAMES = TRUE) 
}

#reorder the names of the characteristics and change to "Born in"
reord = c(11, 9,3, 4, 15, 5, 13, 14, 7, 1, 2, 10, 6, 8, 12)
provinces.data = lapply(provinces.data,  
                        function(x) {x[reord]})
#change to "Born in"
born.in = function(x) {
 names(x)[5:15] = paste("Born in", names(x)[5:15])
 x }
provinces.data = lapply(provinces.data, born.in)

############################################### 
#Map and Shape File Side 
###############################################


#FUNCTIONS
# ###############################################################
# 
#Bridges the gap between shape data frame and the stats data frame
#merge with statistical data
merge.map = function(data.map, data){
  temp = merge(data.map, data, by.x = "id", by.y = "CDUID", sort = FALSE)
  temp = temp[order(temp$order), ]
  return(temp)
}


#################################################################

#gives me a cleaned shapefile restricted to the province 
# total.shape = function(shapefile, province){
#  sp = clean.shape(shapefile)
#  sp = restrict.province(sp, province)
#  return(sp)
# }

#cleaned, province restricted shapefile fortified
# #data.shape = function(shapefile, province){
#  sp = total.shape(shapefile, province)
#  sp = fortify(sp, region = "CDUID")
#  return(sp)
# }


# #clean shape file
# clean.shape = function(shapefile){
#   shapefile@data$PRNAME = trim(gsub("/.*", "", shapefile@data$PRNAME))
#   shapefile@data$CDNAME = trim(shapefile@data$CDNAME)
#   shapefile@data$CDNAME = gsub(" " ,"", shapefile@data$CDNAME)
#   return(shapefile)
# }
# 
# #restrict to province
# restrict.province = function(shapefile, province){
#   return(shapefile[shapefile@data$PRNAME == province, ])
# }

#DATA

#important variables
#sp.Canada.data - fortified shape files
#provinces.data - all the ethnic data for all provinces

#get shape file
sp <- readShapeSpatial('Boundary Files//gcd_000a07a_e.shp', 
                       proj4string = CRS("+proj=longlat +datum=WGS84") )
sp = clean.shape(sp)

#All the shape files of each province

sp.Canada = lapply(provinces, restrict.province, shapefile = sp)  
names(sp.Canada) = provinces

#fortified shape files of each province
sp.Canada = fortify(sp.Canada, region = "CDUID")


#Bridges the gap between shape data frame and the stats data frame
#merge with statistical data
merge.map = function(data.map, data){
  temp = merge(data.map, data, by.x = "id", by.y = "CDUID", sort = FALSE)
  temp = temp[order(temp$order), ]
  return(temp)
}

#################################################