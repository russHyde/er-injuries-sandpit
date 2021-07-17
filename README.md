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

## Converting to a package (Sec 20.1 of Mastering Shiny)

- Add R/
- Move app.R into R/
- Wrap code in R/app.R into a standalone function (`er_app()`)
- Renamed `er-injuries-sandpit.Rproj` as `er.injuries.sandpit.Rproj`
- Add a DESCRIPTION (Ugh!!!)
- (The app already had an .Rproj file)
- (The app had no `source(...)` calls)
- Replace read.csv calls with data() access
- Restarted RStudio (so build tools are available for the project)
- Call `devtools::load_all()` and check that `er_app()` runs
- Configured the build tools for the project (ensure docs are made by roxygen etc)

### Adding the DESCRIPTION:

- `usethis::use_description()` didn't work immediately, because the reponame (`er-injuries-sandpit`)
  is not a valid CRAN package name.
- So I used `usethis::use_description(list(Package = "er.injuries.sandpit"))`; all of
  these failed, despite the package name being a valid CRAN package name. usethis was still checking
  that the reponame was a valid CRAN package name. Which doesn't make sense, given that I've passed
  in a package name explicitly.
- So then I used `use_description(use_description_defaults(package = "er.injuries.sandpit"))`. Which
  again failed
- Then I used the following:

```r
usethis::use_description(
  usethis::use_description_defaults(
    package = "er.injuries.sandpit"
  ),
  check_name = FALSE
)
```

### Replacing `read.csv`

- Created package datasets for `injuries`, `population` and `products`

```
usethis::use_data(injuries)
usethis::use_data(population)
usethis::use_data(products)
```

- Removed the `./neiss/` directory (all associated data are now in `./data/`)

- Removed the use of `vroom::vroom()` and `library(vroom)`