## Run 'autotest' to check the documentation

Testing takes many forms and there are tools to help you at all stages.

{testthat} and related tools test the implementation of your ideas.
`R CMD check` tests the structure of your package conforms to guidelines (amongst other things).
Tools like {lintr} and {styler} can be used as tests on the quality of your code.
There are even tools to test your tests:

- Can {covr} find any lines of code that aren't covered by your test suite?
- Can a random search using
  [{hedgehog}](https://cran.r-project.org/web/packages/hedgehog/index.html) find a test example that
  would fail your tests?
- Can [mutant](https://sckott.github.io/mutant/) manipulate the logic in your source code without
  breaking your tests?

{goodpractice} combines many of the above approaches (eg, it will check the contents of your
DESCRIPTION for things that will make it easier for your users to report bugs', it calls covr to
check whether all your source code has test coverage, it calls lintr to check things like
line-lengths and some dubious programming patterns).

That's all great and helps you work out if your code behaves correctly and your package is
structured sensibly.
But, perhaps it's more important to determine whether people can use your code.

What would help with the usability of your tool?

- A place to file bug reports and / or get help
- An easily navigated support website
- Tutorials / Vignettes
- Up to date help-pages

### {autotest}

<!--- Describe the @examples section -->

{autotest} is a tool that has recently been developed by rOpenSci and performs some checks on the
examples and function-documentation for R packages.

Firstly, `R CMD check` already runs the code in your examples and checks that no errors arise when
it is running.
It also checks that the parameters for all your exported functions are documented.

Let's assume that `R CMD check` already passes.
What does autotest add beyond that?

Suppose the following is the only function in your package (seems like a waste of a package).
Both parameters are documented (if poorly) and there is an example (a poor one).

```
#' Count the number of observations, weighted by a weight column
#'
#' @param   x    The input data.
#' @param   column   Some column in the input data.
#'
#' @examples
#' df <- data.frame(x = letters[1:3], weight = 1)
#' count_by_weight(df, "x")
#' @export

count_by_weight <- function(x, column) {
  dplyr::count(x, .data[[column]], wt = .data[["weight"]], sort = TRUE)
}
```

Now, `autotest::autotest_package(test = TRUE)` will run various different versions of that example
code: replacing the data.frame with a tibble, or a data.table; using a random character for the
selected column etc.

Five issues were raised for that function:

```
autotest_package(test = TRUE) %>% select(parameter, operation, content)
── autotesting er.injuries.sandpit ──

✓ [1 / 1]: count_by_weight
# A tibble: 5 x 3
  parameter      operation                                  content
  <chr>          <chr>                                      <chr>
1 x              Check that documentation matches class of… Parameter documentation does not describe cla…
2 column         upper-case character parameter             is case dependent
3 (return objec… Check that description has return value    Function [count_by_weight] does not specify a…
4 (return objec… Check whether description of return value… Function [count_by_weight] does not describe …
5 (return objec… Compare class of return value with descri… Function [count_by_weight] does not describe …
```

The first issue it raises is that the documentation doesn't describe the required class of the
first parameter (which is a data.frame in the example).
The last issue states that there is no return type described in the documentation.
We can fix those two by adding "data.frame" to the param for "x" and adding an "@return" roxygen
line.

Then as you add further examples, or modify your code or documentation, by running autotest and
making sure it returns an empty table, your confidence in your documentation should be improved.