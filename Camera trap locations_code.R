##########################################
## Camera trap locations
##########################################

# Helpful tip: You can download most protected area shapefiles at protected planet:
# https://www.protectedplanet.net/en

# Helpful note: latlong projections are for mapping, UTM projections are for
# metric measurements and geospatial analyses.

setwd("your/path/to/studysite/shapefile")
list.files()

library(sf)
library(mapview)
library(leaflet.extras)

#-------------------------------------------------
## Step 1: Open shapefile and set UTM projection
#-------------------------------------------------
# read in your study site shapefile
shp <- st_read(getwd(), "your_shapefile_name")

# check the file
mapview(shp)

# check the projection
st_crs(shp)

# transform to UTM projection
# search "EPSG UTM {Your study site location}" on Google
shp.UTM <- st_transform(shp, crs="EPSG:3405") #replace this with your own UTM EPSG
#check
mapview(shp.UTM)

# subset a protected area (optional)
shp.sub <- subset(shp.UTM, Subset_column_name == "Subset_your_site_here_if_needed")

# check 
mapview(shp.sub)

#-------------------------------------------------
## Step 2: Generate site locations
#-------------------------------------------------

# To create points within this polygon
?st_sample() # check documentation

set.seed(123) # this just makes the random number stay the same so 
# you don't lose your sample generated

#---- random sample
pts.ran <- st_sample(shp.sub, size = 100, type = "random") 
mapview(shp.sub)+mapview(pts.ran, col.regions="red")

#---- systematic sample
pts.sys <- st_sample(shp.sub, size = 100, type = "regular") 
mapview(shp.sub)+mapview(pts.sys, col.regions="red")

#---- systematic sample with specific distances
pts.dist <- 2500 # set 2.5km from one another
# make the grid points
grid_points <- st_make_grid(shp.sub, cellsize = pts.dist, what = "centers")%>%
  st_intersection(shp.sub)%>%
  as.data.frame()%>%
  st_as_sf()

# Sample points from the grid within the studst_may area
mapview(shp.sub)+mapview(grid_points, col.regions="red")

#---- offset grid of systematic grid points
off.dist <- st_coordinates(grid_points)[,1] + 100 # 100m offset to the longitude/easting
offset_points <- st_as_sf(data.frame(cbind(off.dist, st_coordinates(grid_points)[,2])),
                          crs=st_crs(grid_points),
                          coords = c("off.dist","V2"))

# check
mapview(shp.sub)+mapview(grid_points, col.regions="red")+
  mapview(offset_points, col.regions="gold")

#-------------------------------------------------
## Step 3: Generate focused site locations
#-------------------------------------------------
library(mapedit)

###---- smaller area as a polygon to set points
new.shp <- mapview(shp.sub)%>%editMap()
new.shp <- new.shp$finished # extract the sf object
# transform to UTM
new.shp.UTM <- st_transform(new.shp, crs=st_crs(shp.sub))

#check the polygon
mapview(shp.sub)+ mapview(new.shp.UTM)

###---- systematic sample inside smaller shape
pts.sys.new <- st_sample(new.shp.UTM, size = 50, type = "regular") 
mapview(shp.sub)+mapview(pts.sys.new, col.regions="red")

#-------------------------------------------------
## Step 4: Write to GPS unit for your team
#-------------------------------------------------

# convert the points back to latlong for export
# note, change "pts.sys.new" to whatever points you want to save
pts.sys.ll <- st_transform(pts.sys.new, crs = st_crs(4326))%>%
  as.data.frame()%>%
  st_as_sf()

# first we should name the stations so we refer to them in our datasheet later on
pts.sys.ll$name <- rep(paste0("Station ", 1:length(pts.sys.new)))
pts.sys.new$name <- rep(paste0("Station ", 1:length(pts.sys.new)))

# write the data into a .csv file so teams can print out the coords if needed
write.csv(data.frame(pts.sys.new), "Camera_locations.UTM.csv")
write.csv(data.frame(pts.sys.ll), "Camera_locations.LL.csv")

library(sf)
# handheld GPS units use .gpx format 
#Now only write the "name" field to the file
st_write(pts.sys.ll["name"], driver="GPX", layer="waypoints", 
         dsn=paste0(getwd(),"/cam_locations.gpx"),
         delete_dsn = TRUE)

# with rgdal
library(rgdal)
pts.sp <- as(pts.sys.ll, "Spatial")
writeOGR(pts.sp["name"], driver="GPX", layer="waypoints", 
         dsn=paste0(getwd(),"/station_locations.gpx"))
