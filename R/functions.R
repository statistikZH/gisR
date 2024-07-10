

# Helper to get a bbox-string from a bbox
format_bbox <- function(bbox) {
  formatted <- bbox |>
    purrr::map_chr(~ paste(.x, collapse = ",")) |>
    paste(collapse = ",")
  return(formatted)
}
