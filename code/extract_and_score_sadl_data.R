
library(sf)
library(terra)
library(tidyterra)
library(dplyr)
library(spatstat)
library(stringr)


hex_grid = st_read("./data/atlcen_wind2_emptyHexGrid_20241212.gpkg")

fp = "./data/atlcen_wind2_sadlLineData_20241218.gpkg"
data1 = st_read(fp) %>% st_transform(st_crs(hex_grid))

fp = "./data/SADL_grid.gdb"
data2 = st_read(fp, layer="SADL_grid_NAD_1983_Contiguous_USA_Albers") %>% st_transform(st_crs(hex_grid))


#
data1 = st_buffer(data1, dist=10000)
extraction1 = st_join(hex_grid, data1, left=FALSE) %>%
  st_drop_geometry() %>% 
  group_by(GRID_ID) %>%
  summarise(CPUE100 = mean(CPUE100, na.rm=TRUE))
extraction1$cpue100_zmem = z_membership(extraction1$CPUE100)

extraction1 = inner_join(hex_grid, extraction1, by=c("GRID_ID"))

st_write(extraction1, "./data/atlcen_wind2_sadlBufferExtract_20241219.gpkg", delete_layer=TRUE)

#
extraction2 = st_join(hex_grid, data2, left=FALSE) %>%
  st_drop_geometry() %>% 
  group_by(GRID_ID) %>%
  summarise(mean_CPUE100 = max(mean_CPUE100, na.rm=TRUE))
extraction2$cpue100_zmem = z_membership(extraction2$mean_CPUE100)

extraction2 = inner_join(hex_grid, extraction2, by=c("GRID_ID"))

st_write(extraction2, "./data/atlcen_wind2_sadlOrigGridExtract_20241219.gpkg", delete_layer=TRUE)





