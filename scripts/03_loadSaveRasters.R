# load and combine Sentinel-2 using stars
library(stars)

ktzh <- sf::read_sf("geodata/GrenzeKTZH.gpkg")

# Build the path to the 4 single Band TIFs:
# Extract the 4-14 elements
storage_pattern_list <- base::readRDS("tmp_storage_pattern.Rds")
extracted_elements <- storage_pattern_list[4:14]

# Prepend "geodata"
prepended_elements <- c("geodata", extracted_elements)

single_files <- list.files(file.path(paste0(c(prepended_elements, "R10m"),
                                            collapse = "/")),
                           full.names = TRUE)


rasters = read_stars(single_files, proxy = TRUE, along = "band")
# terra::rast(rasters) %>% plotRGB(r=3, g=2, b=1, stretch="lin")


# mask and clip
RGBI_zh <- st_crop(rasters, ktzh %>% st_transform(st_crs(rasters)))
# terra::plot(RGBI_zh)
# terra::rast(RGBI_zh) %>% plotRGB(r=3, g=2, b=1, stretch="lin")

# save RGBI To File:
system.time(stars::write_stars(RGBI_zh, "geodata/RGBI.tif", type = "UInt16",
                  NA_value = 0))


