library(purrr)


# Helper to get a bbox-string from a bbox
format_bbox <- function(bbox) {
  bbox %>%
    map_chr(~ paste(.x, collapse = ",")) %>%
    paste(collapse = ",") %>% return()
}
