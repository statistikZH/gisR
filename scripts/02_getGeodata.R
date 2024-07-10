source("R/functions.R")


# Get Data using WFS requests ---------------------------------------------
# Define base url
wfs_zh <- "https://maps.zh.ch/wfs/OGDZHWFS"

# Simple GetCapabilities request:
url <- httr::parse_url(wfs_zh)
url$query <- list(service = "WFS",
                  version = "2.0.0",
                  request = "GetCapabilities"
                  )

request <- httr::build_url(url)
request
# res <- httr::GET(request)


# BEZIRKE -----------------------------------------------------------------
url <- httr::parse_url(wfs_zh)
url$query <- list(service = "WFS",
                  version = "2.0.0",
                  request = "GetFeature",
                  typename = "ms:ogd-0095_arv_basis_up_bezirke_f",
                  outputformat = "geojson"
                  )

request <- httr::build_url(url)
bezirke <- sf::read_sf(request)

# Save Bezirke Layer
sf::write_sf(bezirke, "geodata/Bezirke.gpkg")

# Save die Grenze des KTZH
sf::write_sf(sf::st_union(bezirke), "geodata/GrenzeKTZH.gpkg")

# Extrahieren eines Bezirks, Dielsdorf
dielsdorf <- bezirke |> dplyr::filter(bezirk == "Dielsdorf")

# Bounding Box von Dielsdorf
diels_box <- format_bbox(sf::st_bbox(dielsdorf))


# Landwirtschaftliche Nutzungsflächen -------------------------------------
url <- httr::parse_url(wfs_zh)
url$query <- list(service = "WFS",
                  version = "2.0.0",
                  request = "GetFeature",
                  typename = "ms:ogd-0170_giszhpub_lw_nutzungsflaechen_f",
                  bbox = diels_box # bbox begrenzt den Request räumlich
                  )

request <- httr::build_url(url)

lwnutz_dielsdorf <- sf::read_sf(request) |>
  # GML kommen als Geometrycollection und Multisurface daher, wir wandeln sie um
  sf::st_cast("GEOMETRYCOLLECTION") |>
  sf::st_collection_extract("POLYGON")

# Intersect and save it
lwnutz_dielsdorf |>
  dplyr::filter(lengths(sf::st_intersects(geometry, dielsdorf)) > 0) |>
  sf::write_sf(("geodata/LWNutz_Dielsdorf.gpkg"))


# Gemeindegrenzen ----------------------------------------------------------
url <- httr::parse_url(wfs_zh)
url$query <- list(service = "WFS",
                  version = "2.0.0",
                  request = "GetFeature",
                  typename = "ms:ogd-0095_arv_basis_up_gemeinden_seen_f",
                  outputformat = "geojson"
)

request <- httr::build_url(url)
Grenzen <- sf::read_sf(request)

# Save Bezirke Layer
sf::write_sf(Grenzen, "geodata/Gemeindegrenzen_-OGD.gpkg")

