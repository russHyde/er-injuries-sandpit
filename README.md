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

### Replacing file-imports (`vroom::vroom`)

- Created package datasets for `injuries`, `population` and `products`

```
usethis::use_data(injuries)
usethis::use_data(population)
usethis::use_data(products)
```

- Removed the `./neiss/` directory (all associated data are now in `./data/`)

- Removed the use of `vroom::vroom()` and `library(vroom)`

## Checked the package loads / builds / checks etc

- "Load All" passed
- "Clean and Rebuild" failed: needed a NAMESPACE
  - Ran `devtools::document()`
- "Clean and Rebuild" then passed
- "Test Package" failed because no testing infrastructure has been added yet
- "Check package" failed
  - Errors
    - `library(shiny)`
      - Removed the `library(shiny)` call
      - `usethis::use_package("shiny")`
      - Then placed `#' @import   shiny` above `er_app` definition
      - Ran document() again
    - `library(tidyverse)`
      - Removed the `library(tidyverse)` call
      - `usethis::use_package("dplyr")` and same for "ggplot2"
  - Warning
    - Non-standard license
      - `usethis::use_mit_license()`
    - Undocumented datasets / code objects
      - Add `./R/data.R` with roxygen stub for each dataset
    - LazyData used without specifying LazyDataCompression (for large files)
      - Added `LazyDataCompression: gzip` to DESCRIPTION
  - Note
    - installed package size
      - The dataset is relatively large
      - Won't fix
    - no visible binding for global ...
      - Used `Prefixer::` on `./R/app.R` (from Addins)
      - Skipped all functions / data from {shiny} and {er.injuries.sandpit}
      - `%>%`:
        - add package docs `use_package_doc()` then `use_pipe(export = FALSE)`
      - datasets:
        - replace `injuries` with `injuries <- get("injuries")`
      - column names:
        - wrap with .data[[colname]]

## Adding a test for a (non-reactive) function

- Identify some functionality that we could test:
  - The 'renderTable' calls in the server function are duplicated
  - Suggest: make a function to abstract the non-reactive logic away
  
- Do we add function first, or test first?
  - Neither: we decide what the behaviour of the function should be first

- The calls look like:
  - `some_data_frame %>% dplyr::count(.data[[some_column]], wt = .data[["weight"]], sort = TRUE)`
  - So the function should:
    - count up the different types of entry in one column,
    - weighted by a value in some other column,
    - and then sort the table before output (how? increasing or decreasing)

- Design concerns
  - The input is a data-frame (a tibble here):
  - The output could be a data-frame too:
    - one column for the counted-column;
    - and one column for the count
  - it's good to be precise about the return type:
    - so you could definitely return a tibble
    - or you could definitely return the same type (data.frame, tibble, ... etc) as the input
  - and liberal about the input type
    - the data-frame input may need to be extended in the future ...
  - should we allow the user to specify:
    - which column provides the weights?
    - whether the output is sorted?
    - IMO, no: if required, the caller can use dplyr::count; here, we're just constraining 'count'
    to work with our particular dataset

- We add the barebones of:
  - a function to `./R/count_by_weight.R`
    - `use_r("count_by_weight")`
    - `count_by_weight <- function(x) x`
  - a test to `./tests/testthat/test-count_by_weight.R`
    - `use_test("count_by_weight")`
    - This adds testing infrastructure (testthat -> DESCRIPTION::Suggests, etc)

- We'll work test first

- New test "Output values are sorted":
  - Added the following code
  - Then ran all tests for the package (`[Ctrl-Shift-T]`)
  
```
test_that("it returns in count-sorted order", {
  df <- tibble::tibble(
    x = c(rep("a", 5), rep("b", 3), rep("c", 9)),
    weight = 1
  )

  counted <- count_by_weight(df, column = "x")
  expect_equal(
    object = counted[["n"]],
    expected = sort(counted[["n"]])
  )
})
```

- That's a failing test:
  - We needed to state which column should be counted (so we add that to `count_by_weight`s formals)
  - Doing that makes the test pass trivially
  - But we don't even have a count column (`n`) in the output
  - ... so maybe that was a silly test to add first

- Add another test:
  - The colnames of the returned object should be (x, "n")
  - ... where x is the counted column from the input
  - code not shown
  - the following trivial implementation makes both tests pass

```
count_by_weight <- function(x, column) {
  tibble::tibble(
    {{ column }} := character(0),
    n = numeric(0)
  )
}
```

- Then we add a bunch more tests:
  - counts equal number of rows when weights are 1
  - counts can be weighted

- ... and fix the code so that each test passes, and then any newly-failing tests pass as well:
  - eg, this revealed that:
    - dplyr::count(... sort = TRUE) returns in decreasing order,
    - but base::sort returns in increasing order (so our test was wrong)

- Then, when all the behaviours we want are implemented, and all tests pass, we run:
  - styler::style_package()
  - devtools::check() [Ctrl-Shift-E]