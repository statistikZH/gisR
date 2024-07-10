



# STAC Source -------------------------------------------------------------
stac_source <- rstac::stac(
  "https://planetarycomputer.microsoft.com/api/stac/v1",
  force_version = "1.0.0"
)

# str(stac_source)
# Perform the Request
rstac::get_request(stac_source)



# List available Collections ----------------------------------------------
collections_query <- stac_source |>
  rstac::collections()

available_collections <- rstac::get_request(collections_query)
available_collections



# Search for Sentinel 2 Data ----------------------------------------------
q <- rstac::stac_search(
  q = stac_source,
  collections = "sentinel-2-l2a",
  datetime = "2024-06-01/2024-07-11",
  limit = 99
)

res <- rstac::get_request(q)
# Pick one element
# View(res[[2]][[2]])



# Real Query, KTZH Bounding Box, Given Date and Cloud Cover Limit ---------

ktzh_bbox <- "8.35769337170312,47.1594356217277,8.98495097693861,47.6944697371138"

stac_query <- rstac::stac_search(
  q = stac_source,
  collections = "sentinel-2-l2a",
  datetime = "2023-06-10/2023-06-14",
  bbox = ktzh_bbox
) |>
  rstac::ext_filter(
    `eo:cloud_cover` <= 20)

executed_stac_query <- rstac::get_request(stac_query)

executed_stac_query
# --> One Resulting Item


# Sign the query
signed_stac_query <- rstac::items_sign(
  executed_stac_query,
  rstac::sign_planetary_computer()
)
# signed_sstac_query

# STAC Source -------------------------------------------------------------
stac_source <- rstac::stac(
  "https://planetarycomputer.microsoft.com/api/stac/v1",
  force_version = "1.0.0"
)

# str(stac_source)
# Perform the Request
rstac::get_request(stac_source)



# List available Collections ----------------------------------------------
collections_query <- stac_source |>
  rstac::collections()

available_collections <- rstac::get_request(collections_query)
available_collections



# Search for Sentinel 2 Data ----------------------------------------------
q <- rstac::stac_search(
  q = stac_source,
  collections = "sentinel-2-l2a",
  datetime = "2024-06-01/2024-07-11",
  limit = 99
)

res <- rstac::get_request(q)
# Pick one element
# View(res[[2]][[2]])



# Real Query, KTZH Bounding Box, Given Date and Cloud Cover Limit ---------

ktzh_bbox <- "8.35769337170312,47.1594356217277,8.98495097693861,47.6944697371138"

stac_query <- rstac::stac_search(
  q = stac_source,
  collections = "sentinel-2-l2a",
  datetime = "2023-06-10/2023-06-14",
  bbox = ktzh_bbox
) |>
  rstac::ext_filter(
    `eo:cloud_cover` <= 20)

executed_stac_query <- rstac::get_request(stac_query)

executed_stac_query
# --> One Resulting Item


# Sign the query
signed_stac_query <- rstac::items_sign(
  executed_stac_query,
  rstac::sign_planetary_computer()
)
# signed_sstac_query




# Downloading Items -------------------------------------------------------
## Rendered Preview
rstac::assets_download(signed_stac_query, "rendered_preview",
                       output_dir = "geodata/")

## Scene Classification Layer
rstac::assets_download(signed_stac_query, "SCL",
                       output_dir = "geodata/")

## Grab multiple Bands Blue, Green, Red, Near-Infrared
rstac::assets_download(signed_stac_query, c("B02", "B03", "B04", "B08"),
                       progress = TRUE, output_dir = "geodata/", overwrite = F)


## We could also get the raw Item-URL
B03_url <- rstac::assets_url(executed_stac_query, "B03")
B03_url

## We need this pattern again:
storage_pattern_list <- B03_url |>
  stringr::str_split("/") |> unlist()
