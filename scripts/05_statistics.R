
# statistics --------------------------------------------------------------
library(tidyverse)
library(exactextractr)
library(raster)
library(tmap)



# Ziel: NDVI mean Pro LW Fläche -------------------------------------------

# Load Polygon Layer
LWNutz_Diels <- sf::read_sf("geodata/LWNutz_Dielsdorf.gpkg") %>%
  mutate(area = st_area(geom))

hist(LWNutz_Diels$area,
     main = "Flächengrössen aller Landw. Nutzflächen in Dielsdorf",
     xlab = "Fläche",
     ylab = "Anzahl")

# Erntezeitpunkte:
LWNutz_Diels$harvest_date %>% unique()


# Set aller Flächen, die erst am 15.06. sollten geschnitten werden:
BF_Fl <- LWNutz_Diels %>%
  filter(harvest_date == "15.06.") %>%
  # Drop die kleinsten Flächen unter 100 m^2
  filter(area > units::set_units(500, "m^2"))

hist(BF_Fl$area,
     main = "Flächengrössen aller Landw. Nutzflächen in Dielsdorf",
     xlab = "Fläche",
     ylab = "Anzahl")

# Load Raster
ndvi_rast <- terra::rast("geodata/ndvi_terra.tif")

# # Reproject it, so it does align with the Polygons
# ndvi_2056 <- terra::project(ndvi_rast, "EPSG:2056", method="bilinear")

plot(ndvi_rast)

# calculate mean NDVI for every feature:
BF_Fl$mean_ndvi <- exact_extract(ndvi_rast, BF_Fl, 'mean', progress=TRUE,
                                 max_cells_in_memory = 1e4)


# final -------------------------------------------------------------------


hist(BF_Fl$mean_ndvi)

tmap_mode("view")
tmap_options(check.and.fix = TRUE)

# tm_shape(LWNutz_Diels) +
#   tm_polygons(legend.show = FALSE,
#               popup.vars = FALSE,
#               id = NA) +
  tm_shape(BF_Fl) +
  tm_polygons("mean_ndvi",
              style = "fixed",
              breaks = c(-0.4, -0.2, 0, 0.2, 0.4, 1)
              ) +
    tm_shape(ndvi_rast) +
    tm_raster()

hist(BF_Fl$mean_ndvi,
     main = "Mittlerer NDVI pro Biodiversitäts-Förderfläche",
     xlab = "NDVI",
     ylab = "Frequenz")

tm_shape(BF_Fl %>% filter(mean_ndvi < 0.35)) +
  tm_polygons("mean_ndvi",
              style = "fixed",
              breaks = c(-0.4, -0.2, 0, 0.2, 0.4, 1)
  )

