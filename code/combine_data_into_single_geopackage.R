
library(sf)
library(dplyr)


hex_grid = st_read("../CA2/data/atlcen_wind2_emptyHexGrid_20241212.gpkg")


files = c(
  "../CA2/data/atlcen_wind2_sadlBufferExtract_20241219.gpkg",
  "../CA2/data/atlcen_wind2_sadlOrigGridExtract_20241219.gpkg",
  "../CA2/data/atlcen_wind2_serfsInterpExtract_20241219.gpkg",
  "../CA2/data/atlcen_wind2_serfsInterpExtract10km_20241219.gpkg",
  "../CA2/data/atlcen_wind2_serfsOrigGridExtract_20241219.gpkg"
)


for(i in seq(length(files))){
  data1 = st_read(files[i]) %>%
    st_drop_geometry()
  hex_grid = hex_grid %>% left_join(data1, by=c("GRID_ID"))
}


colnames(hex_grid)[2:(ncol(hex_grid)-1)] = c(
  "sadl_cpue100_buffer", "sadl_cpue100_buffer_zmem",
  "sadl_cpue100_grid", "sadl_cpue100_grid_zmem",
  "serfs_inds_interp2km", "serfs_inds_interp2km_zmem",
  "serfs_inds_interp10km", "serfs_inds_interp10km_zmem",
  "serfs_inds_grid", "serfs_inds_grid_zmem"
)

hex_grid = hex_grid %>%
  mutate(across(contains("zmem"),
      ~ifelse(is.na(.),1,.)))

st_write(hex_grid, "../CA2/data/atlcen_wind2_serfsAndSadlProcessed_20241220.gpkg", delete_layer=TRUE)





