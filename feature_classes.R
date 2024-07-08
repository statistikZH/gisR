# Lesen der Gebäudedaten
gwr <- read.csv("https://www.web.statistik.zh.ch/ogd/daten/ressourcen/KTZH_00002022_00004064.csv") |>
  dplyr::rename_all(tolower)

# gwr <- readRDS("gwr.RDS")
#
# saveRDS(gwr, file = "gwr.RDS")

# Umwandeln in ein sf-Objekt -> Geodatenobjekt
gwr_sf <- sf::st_as_sf(gwr, coords = c("e.gebaeudekoordinate", "n.gebaeudekoordinate"), crs = 2056)

# interaktives Darstellen
mapview::mapview(head(gwr_sf, 100))

gemeinden <- sf::st_read("https://maps.zh.ch/wfs/OGDZHWFS?SERVICE=WFS&VERSION=2.0.0&Request=getfeature&TYPENAME=ms:ogd-0095_arv_basis_up_gemeinden_seen_f&outputformat=geojson") |>
  dplyr::rename_all(tolower)

# Lesen des Gemeindelayers
#gemeinden <- sf::read_sf("Gemeindegrenzen_-OGD.gpkg", layer = "UP_GEMEINDEN_F")


# Matchen der Gemeindeinformation an die GWR-Daten
# Die geometrie wird hier entfernt, da die Datenanalyse danach viel schneller läuft
gwr_sf_gem <- gwr_sf |>
  dplyr::select(gebaeudekategorie_code, gebaeudekategorie_bezeichnung) |>
  sf::st_join(gemeinden) |>
  sf::st_drop_geometry()


# Berechnung der Anteile der Geböude ohne Wohnnutzung am gesamten Gebäudebestand einer Gemeinde
geb_ohne_wohnnutzung_pro_gem <- gwr_sf_gem |>
  dplyr::group_by(gebaeudekategorie_code, gebaeudekategorie_bezeichnung, bfs, gemeindename) |>
  dplyr::summarise(anzahl = dplyr::n()) |>
  dplyr::ungroup() |>
  dplyr::group_by(bfs, gemeindename) |>
  dplyr::mutate(anteil = round(anzahl/sum(anzahl)*100, 2)) |>
  dplyr::ungroup() |>
  dplyr::filter(gebaeudekategorie_code == 1060)



# Hinzufügen der Gemeindepolygone
# Herausfiltern der Seen und fixen der Polygone
geb_ohne_wohnutzung_sf <- gemeinden  |>
  dplyr::select(bfs) |>
  dplyr::left_join(geb_ohne_wohnnutzung_pro_gem, by = "bfs") |>
  dplyr::filter(bfs != 0) |>
  sf::st_make_valid() |>
  # tmap vewendet die erste Spalte als Bezeichner, deshalb hier die Änderung in der Spaltenanordnung
  dplyr::select(gemeindename, dplyr::everything())


geb_ohne_wohnnutzung_sf_generalized <- geb_ohne_wohnutzung_sf |>
  rmapshaper::ms_simplify(keep = 0.005)


# Statisches Darstellung
tmap::tm_shape(geb_ohne_wohnnutzung_sf_generalized) +
  tmap::tm_polygons("anteil")


# Setzt tmap auf interaktiv
tmap::tmap_mode("view")

# Interaktive Darstellung
tmap::tm_shape(geb_ohne_wohnnutzung_sf_generalized) +
  tmap::tm_polygons("anteil")




