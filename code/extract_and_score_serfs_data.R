
library(sf)
library(terra)
library(tidyterra)
library(dplyr)
library(spatstat)
library(stringr)
source("../MspModelR/src/membership_functions.R")


# fp = "../CA2/data/atlcen_wind2_serfsInterpRastSr20kmRes2km_20241219.tif"
fp = "../CA2/data/atlcen_wind2_serfsInterpRastSr20kmRes10km_20241219.tif"
data1 = rast(fp)

# fp = "../CA2/data/SERFS_grid.gdb"
# data2 = vect(fp)
# data2 = project(data2, crs(data1))

hex_grid = vect("../CA2/data/atlcen_wind2_emptyHexGrid_20241212.gpkg")
# hex_grid = crop(hex_grid, terra::union(ext(data1), ext(data2)))
hex_grid = crop(hex_grid, data1)

#
extraction1 = extract(data1, hex_grid, fun="max", bind=TRUE)
extraction1$individuals_zmem = z_membership(extraction1$Individuals)

writeVector(extraction1, "../CA2/data/atlcen_wind2_serfsInterpExtract10km_20241219.gpkg")

#
# extraction2 = st_join(st_as_sf(hex_grid), st_as_sf(data2), left=FALSE)
# extraction2 = extraction2 %>%
#   st_drop_geometry() %>%
#   group_by(GRID_ID) %>%
#   summarise(sumcounts = max(sumcounts))
# extraction2$sumcounts_zmem = z_membership(extraction2$sumcounts)
# 
# extraction2 = inner_join(hex_grid, extraction2, by="GRID_ID")
# writeVector(extraction2, "./data/atlcen_wind2_serfsOrigGridExtract_20241219.gpkg", overwrite=TRUE)
# 
# 



