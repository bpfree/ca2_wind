
library(terra)
library(tidyterra)
library(dplyr)
library(spatstat)
library(stringr)

################################################################
############ Define functions ##################################
### Function to make an empty terra raster from initial settings
# res is in meters (almost always haha)
initialize_empty_raster <- function(extent, res=100, spatRef){
  # initialize empty raster with a cell centered on each point
  empty_ras <- terra::rast(resolution=res,
                           xmin=xmin(extent),
                           xmax=xmax(extent), 
                           ymin=ymin(extent),
                           ymax=ymax(extent), 
                           crs=spatRef,
                           vals=NA)
  return(empty_ras)
}
###

### function to create an interpolated grid from desired search settings
# my_pts = vect object of the points to interpolate
# value_field = the field name in the pts that the raster values will come from
# empty_ras = empty raster grid that the interpolated valyes will fill into
interpolate_raster_from_mesh_points <- function(my_pts, value_field, empty_ras,
              searchRadius=NULL, power=2, smooth=1, minPoints=1){
  if(is.null(searchRadius)){
    ### get the spacing distance between the points
     # the 0.9 is used to get a 90% of the points grid spacing as the spacing distance
      # which is important for variable-distance points
    pp <- ppp(x = geom(my_pts)[,'x'], y = geom(my_pts)[,'y'],
              window = owin(range(geom(my_pts)[,'x']), range(geom(my_pts)[,'y'])))
    min_spacing <- nndist(pp)
    searchRadius = as.numeric(quantile(min_spacing, 0.9)) # 90% of pts spaced by this distance or less in meters
  }
  # use inverse distance weighting to interpolate the grid
  interpolated_raster = interpIDW(
    empty_ras, my_pts, field=value_field, radius=searchRadius, power=power, smooth=smooth,
        fill=NA, minPoints=minPoints)
  names(interpolated_raster) = value_field
  return(interpolated_raster)
}
###
##########################################################################

#######################################################################
################### Run raster creation from pts ######################

### Run the loading of points and settings
# What is the filepath for the output raster
opath = "../CA2/data/atlcen_wind2_serfsInterpRast_20241219.tif"

# input point files
in_files <- c("../CA2/data/atlcen_wind2_serfsVideoDataset_20241218.gpkg")
value_fields = c("Individuals")

my_res <- 10000 # 2km grid resolution
my_ext <- ext(c(1566415, 1765926, -649713, -394048) + c(-1,1,-1,1)*my_res)
search_radius <- 20000 # 20km search radius

# what spatial reference are we using? Can be set to the same as the points, but 
# if not the points will be transformed to this desired crs
my_crs <- crs("ESRI:102008")

# empty raster creation
empty_ras <- initialize_empty_raster(extent=my_ext, res=my_res, spatRef=my_crs)

### Interpolate the grid
# iterate through each file
for(i in seq(length(in_files))){
  # load pts
  my_pts <- vect(in_files[i]) 
  my_pts <- project(my_pts, my_crs)   # project to crs
  
  # interpolate the grid from the empty raster and the points
  interp_ras <- interpolate_raster_from_mesh_points(
    my_pts, value_field=value_fields[i], empty_ras=empty_ras,
    searchRadius=search_radius, power=1, smooth=3, minPoints=10)
  
  # combine raster layers
  if(i==1){out_ras = interp_ras
  }else{out_ras = c(out_ras, interp_ras)}
}


opath = str_replace(opath, "InterpRast",
    paste0("InterpRast","Sr",search_radius/1000,"km","Res",my_res/1000,"km"))
# save raster
writeRaster(out_ras, opath, overwrite=TRUE)






