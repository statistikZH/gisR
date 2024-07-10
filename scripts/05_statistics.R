
# statistics --------------------------------------------------------------

# Ziel: NDVI mean Pro LW Fläche -------------------------------------------
# Load Polygon Layer
LWNutz_Diels <- sf::read_sf("geodata/LWNutz_Dielsdorf.gpkg") |>
  dplyr::mutate(area = sf::st_area(geom))

hist(LWNutz_Diels$area,
     main = "Flächengrössen aller Landw. Nutzflächen in Dielsdorf",
     xlab = "Fläche",
     ylab = "Anzahl")

# Erntezeitpunkte:
LWNutz_Diels$harvest_date |> unique()

# Set aller Flächen, die erst am 15.06. sollten geschnitten werden:
BF_Fl <- LWNutz_Diels |>
  dplyr::filter(harvest_date == "15.06.") |>
  # Drop die kleinsten Flächen unter 100 m^2
  dplyr::filter(area > units::set_units(500, "m^2"))

hist(BF_Fl$area,
     main = "Flächengrössen aller Landw. Nutzflächen in Dielsdorf",
     xlab = "Fläche",
     ylab = "Anzahl")

# Load Raster
ndvi_rast <- terra::rast("geodata/ndvi_terra.tif")

plot(ndvi_rast)

# calculate mean NDVI for every feature:
BF_Fl$mean_ndvi <- exactextractr::exact_extract(ndvi_rast, BF_Fl, 'mean', progress=TRUE,
                                 max_cells_in_memory = 1e4)


# final -------------------------------------------------------------------


hist(BF_Fl$mean_ndvi)

tmap::tmap_mode("view")
tmap::tmap_options(check.and.fix = TRUE)

# tm_shape(LWNutz_Diels) +
#   tm_polygons(legend.show = FALSE,
#               popup.vars = FALSE,
#               id = NA) +
  tmap::tm_shape(BF_Fl) +
  tmap::tm_polygons("mean_ndvi",
              style = "fixed",
              breaks = c(-0.4, -0.2, 0, 0.2, 0.4, 1)
              ) +
    tmap::tm_shape(ndvi_rast) +
    tmap::tm_raster()

hist(BF_Fl$mean_ndvi,
     main = "Mittlerer NDVI pro Biodiversitäts-Förderfläche",
     xlab = "NDVI",
     ylab = "Frequenz")

tmap::tm_shape(BF_Fl |> dplyr::filter(mean_ndvi < 0.35)) +
  tmap::tm_polygons("mean_ndvi",
              style = "fixed",
              breaks = c(-0.4, -0.2, 0, 0.2, 0.4, 1)
  )

