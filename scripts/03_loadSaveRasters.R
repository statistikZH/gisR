# load and combine Sentinel-2 using terra
library(terra)
library(sf)

ktzh_UTM32 <- sf::read_sf("geodata/GrenzeKTZH.gpkg") |>
  st_transform("EPSG:32632")

# Build the path to the 4 single Band TIFs:
# Extract the 4-14 elements
storage_pattern_list <- base::readRDS("tmp_storage_pattern.Rds")
extracted_elements <- storage_pattern_list[4:14]

# Prepend "geodata"
prepended_elements <- c("geodata", extracted_elements)

# List all Paths for the 4 Bands in the 10m-Resolution Folder
single_files <- list.files(file.path(paste0(c(prepended_elements, "R10m"),
                                            collapse = "/")),
                           full.names = TRUE)

Raster = rast(single_files)
# terra::plotRGB(Raster, r=3, g=2, b=1, stretch="lin")

# mask and clip
# RGBI_zh <- st_crop(rasters, ktzh |> st_transform(st_crs(rasters)))
RGBI_zh <- crop(Raster, ktzh_UTM32)
RGBI_zh <- mask(RGBI_zh, ktzh_UTM32) |>
  project("EPSG:2056")

# plot(RGBI_zh)
# one could also stretch the values:
# stretch(RGBI_zh, minq=0.02, maxq=0.98, minv=0, maxv=16384) |>
#   plotRGB(r=3, g=2, b=1)

# Write Raster to disk
system.time(terra::writeRaster(RGBI_zh, "geodata/RGBI_terra_2056.tif"))
