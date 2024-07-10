
# source("scripts/03_loadSaveRasters.R")
RGBI_zh <- terra::rast("geodata/RGBI_terra_2056.tif")

# We take a 4 Band Raster as stars object and calculate the NDVI
str(RGBI_zh)


# calculate NDVI using the red (band 1) and nir (band 4) bands
sent2_ndvi <- (RGBI_zh[[4]] - RGBI_zh[[1]]) / (RGBI_zh[[4]] + RGBI_zh[[1]])
sent2_ndvi |> terra::writeRaster("geodata/ndvi_terra.tif")

plot(sent2_ndvi)
hist(sent2_ndvi)
