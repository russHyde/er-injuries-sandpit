# Neiss Injuries App

The code for the initial app comes from "Mastering Shiny" by Hadley Wickham.

This is a sandpit for:

- converting an app to a package
- adding tests to an app

## Initial app construction:

- Started new directory
- Converted that directory to an R project (in RStudio)
- Added app.R (based on the prototype code in CH4 of Mastering Shiny)
- Downloaded Neiss dataset, as described in Mastering Shiny

```r
download <- function(name) {
  url <- "https://github.com/hadley/mastering-shiny/raw/master/neiss/"
  download.file(paste0(url, name), paste0("neiss/", name), quiet = TRUE)
}
download("injuries.tsv.gz")
download("population.tsv")
download("products.tsv")
```