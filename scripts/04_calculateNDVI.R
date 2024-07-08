library(stars)
# source("scripts/03_loadSaveRasters.R")

# We take a 4 Band Raster as stars object and calculate the NDVI
str(RGBI_zh)

# Calculate NDVI using Red and NIR Bands -----------------------------------
ndvi_fn <- function(b1, b2, b3, b4) (b4 - b1)/(b4 + b1)

s2_ndvi <- st_apply(RGBI_zh, c("x", "y"), ndvi_fn)
stars::write_stars(s2_ndvi,
                   "geodata/ndvi_float32.tif", type = "Float32")

plot(s2_ndvi)
hist(s2_ndvi)

# terra::plotRGB(terra::rast(s2_ndvi), scale = 45000, stretch="lin")
