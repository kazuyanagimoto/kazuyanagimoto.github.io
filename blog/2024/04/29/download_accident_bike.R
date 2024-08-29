library(dplyr)
dir_data <- here::here("blog/2024/04/29/data/")
url_base <- "https://datos.madrid.es/egob/catalogo/300228-%s-accidentes-trafico-detalle.csv"

for (dir in c(dir_data, file.path(dir_data, "txt"))) {
  if (!dir.exists(dir)) {
    dir.create(dir)
  }
}

years <- 2019:2023
keys <- c(19, 21, 22, 24, 26) #URL becomes caos since 2020
for (i in seq_along(years)) {
  year <- years[i]
  key <- keys[i]

  url <- sprintf(url_base, key)
  path_file <- file.path(dir_data, "txt", paste0(year, ".txt"))
  if (!file.exists(path_file)) {
    download.file(url, destfile = path_file)
  }
}

# Convert to parquet
## Since the file column type is not consistent, we cannot use arrow::open_dataset()
purrr::map(years, ~readr::read_delim(file.path(dir_data, "txt", paste0(.x, ".txt")),
                                           delim = ";")) |>
  purrr::list_rbind() |>
  select(-starts_with("...")) |>
  nanoparquet::write_parquet(file.path(dir_data, "raw.parquet"))
