---
name: make-table
description: Create a Table 1 (descriptive or comparative) in R with gtsummary. Use it when the user asks for a descriptive table, a Table 1, or to compare variables across groups (by treatment, by outcome, etc.). If comparing across groups, add p-values with add_p().
---

# Skill: make-table

Generate a Table 1 from `data/cohort.csv` using **gtsummary**.

## When to use it
- "give me Table 1", "descriptive table" -> simple table.
- "compare by treatment / by outcome", "comparative table with p" -> use `by =` and `add_p()`.

## How to do it

1. Make sure `gtsummary` is installed; if not, install it.
2. Write a script at `R/make_table.R` with this pattern and run it with `Rscript`.

```r
# R/make_table.R
if (!requireNamespace("gtsummary", quietly = TRUE))
  install.packages("gtsummary", repos = "https://cloud.r-project.org")
library(gtsummary)

data <- read.csv("data/cohort.csv", stringsAsFactors = TRUE)
data$id <- NULL

# --- Simple descriptive table ---
tbl <- tbl_summary(data)

# --- COMPARATIVE table (uncomment and set the grouping variable) ---
# tbl <- tbl_summary(data, by = treatment) |> add_p()

# Save to HTML and print to the console
gtsummary::as_gt(tbl) |> gt::gtsave("table.html")
print(as_tibble(tbl), n = 100)
```

3. For a comparative table, change `by = treatment` to the requested variable
   (e.g. `by = died`) and keep `|> add_p()` for the p-values.
4. Report the table and give a short interpretation.

## Notes
- `add_p()` picks the test automatically (chi-squared, Wilcoxon, etc.).
- The table is saved to `table.html` so it can be opened in a browser.
