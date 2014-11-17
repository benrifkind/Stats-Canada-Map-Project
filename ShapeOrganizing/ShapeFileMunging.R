# Input is .shp file of census divisions for all of Canada
# Output is a folder of folders with names of the province
# Directories are "Shapefiles/ProvinceName"
# Each folder contains the .shp file of that province

# Also cleans up the labels in the .shp file so that 
# they fit with our data frame labels of the stat data downloaded from
# the Stats Canada website

library('sp')
library('rgeos')
library('maptools')

#get shape file
sp <- readShapeSpatial('Boundary Files//gcd_000a07a_e.shp', 
                       proj4string = CRS("+proj=longlat +datum=WGS84") )

#helper function that removes surrounding whitespace
trim <- function (x) gsub("^\\s+|\\s+$", "", x)

#remove French from province names 
sp$PRNAME = trim(gsub("/.*", "", sp$PRNAME))

#remove spaces from census division names
sp$CDNAME = gsub(" ", "", sp$CDNAME)

#add back spaces to census division names for readability
sp$CDNAME = gsub("([a-z])([A-Z])", "\\1 \\2", sp$CDNAME)
sp$CDNAME = gsub("(\\.)([1-9])", "\\1 \\2", sp$CDNAME)

#write each shapefile to folder

#create folders to put the shapefiles in
shp.dir = "Shapefiles/"
dir.create(shp.dir)
provinces = c("Newfoundland and Labrador", "Prince Edward Island", "Nova Scotia", 
              "New Brunswick", "Quebec", "Ontario", "Manitoba", "Saskatchewan", 
              "Alberta", "British Columbia", "Yukon Territory", "Northwest Territories", "Nunavut")
lapply(paste0(shp.dir, provinces), dir.create)

#subset shape files by province
temp = sapply(provinces, function(x){sp[sp$PRNAME == x,]}, simplify = F)

#write to file
lapply(provinces, function(x) { 
  writeSpatialShape(temp[[x]], 
                    paste(paste0(shp.dir, x), x, sep ="/")) })
