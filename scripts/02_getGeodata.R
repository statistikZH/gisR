# LOAD data from wfs
library(sf)
library(httr)
library(tidyverse)
source("scripts/functions.R")


# Get Data using WFS requests ---------------------------------------------
# Define base url
wfs_zh <- "https://maps.zh.ch/wfs/OGDZHWFS"

# Simple GetCapabilities request:
url <- parse_url(wfs_zh)
url$query <- list(service = "WFS",
                  version = "2.0.0",
                  request = "GetCapabilities"
                  )

request <- build_url(url)
request
res <- httr::GET(request)


# BEZIRKE -----------------------------------------------------------------
url <- parse_url(wfs_zh)
url$query <- list(service = "WFS",
                  version = "2.0.0",
                  request = "GetFeature",
                  typename = "ms:ogd-0095_arv_basis_up_bezirke_f",
                  outputformat = "geojson"
                  )

request <- build_url(url)
bezirke <- read_sf(request)
# Save Bezirke Layer
write_sf(bezirke, "geodata/Bezirke.gpkg")
# Save die Grenze des KTZH
write_sf(st_union(bezirke), "geodata/GrenzeKTZH.gpkg")

# Extrahieren eines Bezirks, Dielsdorf
dielsdorf <- bezirke |> filter(bezirk == "Dielsdorf")

# Bounding Box von Dielsdorf
diels_box <- format_bbox(st_bbox(dielsdorf))


# Landwirtschaftliche Nutzungsflächen -------------------------------------
url <- parse_url(wfs_zh)
url$query <- list(service = "WFS",
                  version = "2.0.0",
                  request = "GetFeature",
                  typename = "ms:ogd-0170_giszhpub_lw_nutzungsflaechen_f",
                  bbox = diels_box # bbox begrenzt den Request räumlich
                  )

request <- build_url(url)

lwnutz_dielsdorf <- read_sf(request) |>
  # GML kommen als Geometrycollection und Multisurface daher, wir wandeln sie um
  st_cast("GEOMETRYCOLLECTION") |>
  st_collection_extract("POLYGON")


# Intersect and save it
lwnutz_dielsdorf |>
  filter(st_intersects(dielsdorf, sparse=FALSE)[1,]) |>
  write_sf("geodata/LWNutz_Dielsdorf.gpkg")


# Gemeindegrenzen ----------------------------------------------------------
url <- parse_url(wfs_zh)
url$query <- list(service = "WFS",
                  version = "2.0.0",
                  request = "GetFeature",
                  typename = "ms:ogd-0095_arv_basis_up_gemeinden_seen_f",
                  outputformat = "geojson"
)

request <- build_url(url)
Grenzen <- read_sf(request)

# Save Bezirke Layer
write_sf(Grenzen, "geodata/Gemeindegrenzen_-OGD.gpkg")

