# Setup

# Install needed packages
install.packages(c(
  "dplyr",
  "stringr",
  "sf",
  "terra",
  "tmap",
  "devtools",
  "units",
  "httr",
  "rstac",
  "exactextractr",
  "mapview",
  "rmapshaper",
  "purrr"
  ))

# Load the project
devtools::load_all(".")


# Init folder if not existing
if (!dir.exists("geodata")) {
  print("geodata folder does not exist, will be created.")
  dir.create("geodata")
} else {
  print("geodata folder already exists.")
}
