# ============================================================
# tools.R  -  The agent's TOOLS (complete version)
# ------------------------------------------------------------
# Each tool = a normal R function + a description that tells the
# model WHAT it does and WHEN to use it. The model never sees your
# code, only the description. That is why the description matters
# as much as the function.
#
# At the end we register them all in the list TOOLS, which agent.R reads.
# ============================================================

library(ellmer)

# ---- Shared state between tools ----------------------------
# (here we store the dataset once loaded, so the other tools can
#  use it without reloading it)
.state <- new.env()

# ---- Helper: install a package if missing ------------------
ensure_package <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    message("Installing package '", pkg, "' (it was not in your R session)...")
    install.packages(pkg, repos = "https://cloud.r-project.org")
  }
}

get_data <- function() {
  # Defensive: if the agent forgot to load the data, we load it ourselves.
  # (Good practice: a robust tool does not break if the model skips a step.)
  if (is.null(.state$data)) {
    message("(data was not loaded; loading 'cohort.csv' automatically)")
    load_data()
  }
  .state$data
}

# ============================================================
# TOOL 1: load_data
# ============================================================
load_data <- function(path = "cohort.csv") {
  if (!file.exists(path)) {
    for (alt in c(path, file.path("..", "data", basename(path)), basename(path))) {
      if (file.exists(alt)) { path <- alt; break }
    }
  }
  d <- read.csv(path, stringsAsFactors = TRUE)
  d$id <- NULL                      # the id is not analysed
  .state$data <- d
  paste0("Data loaded from '", path, "': ", nrow(d), " rows and ",
         ncol(d), " variables (", paste(names(d), collapse = ", "), ").")
}

tool_load <- tool(
  load_data,
  "Loads a CSV data file into the R session so it can be analysed. Do this before any table or model.",
  arguments = list(
    path = type_string("Path to the CSV file. Defaults to 'cohort.csv'.", required = FALSE)
  )
)

# ============================================================
# TOOL 2: make_table  (Table 1 with gtsummary, add_p when comparing)
# ============================================================
make_table <- function(compare_by = NULL) {
  ensure_package("gtsummary")
  suppressPackageStartupMessages(library(gtsummary))
  data <- get_data()

  if (is.null(compare_by) || !nzchar(compare_by)) {
    # Simple descriptive table
    tbl <- tbl_summary(data)
    title <- "Descriptive table (Table 1)"
  } else {
    if (!compare_by %in% names(data)) {
      stop("Variable '", compare_by, "' does not exist. Variables: ",
           paste(names(data), collapse = ", "))
    }
    # Comparative table: by = group + p-values (add_p)
    tbl <- tbl_summary(data, by = all_of(compare_by)) |> add_p()
    title <- paste0("Comparative table by '", compare_by, "' (with p-values)")
  }

  # Save an HTML version (if gt is available)
  tryCatch({
    ensure_package("gt")
    gt::gtsave(as_gt(tbl), "table.html")
  }, error = function(e) invisible(NULL))

  # Return the table as text so the model can read and interpret it
  text <- tbl |> as_tibble() |> knitr::kable(format = "pipe") |> paste(collapse = "\n")
  paste0(title, " (saved to table.html):\n\n", text)
}

tool_table <- tool(
  make_table,
  paste(
    "Creates a descriptive table (Table 1) of the loaded dataset using gtsummary.",
    "If 'compare_by' is given, it builds a COMPARATIVE table across the levels of that",
    "variable and adds p-values (add_p). Installs gtsummary if it is not installed."
  ),
  arguments = list(
    compare_by = type_string(
      "Name of the variable to compare by (e.g. 'treatment' or 'died'). Omit for a simple descriptive table.",
      required = FALSE
    )
  )
)

# ============================================================
# TOOL 3: fit_model  (logistic regression -> Odds Ratios)
# ============================================================
fit_model <- function(outcome = "died", predictors = NULL) {
  ensure_package("gtsummary")
  suppressPackageStartupMessages(library(gtsummary))
  data <- get_data()
  if (!outcome %in% names(data)) {
    stop("Outcome '", outcome, "' does not exist. Variables: ",
         paste(names(data), collapse = ", "))
  }
  if (is.null(predictors) || !nzchar(predictors)) {
    preds <- setdiff(names(data), outcome)
  } else {
    preds <- trimws(strsplit(predictors, ",")[[1]])
  }
  f <- as.formula(paste(outcome, "~", paste(preds, collapse = " + ")))
  m <- glm(f, data = data, family = binomial)

  # Regression table with gtsummary: Odds Ratios + 95% CI + p-values
  tbl <- tbl_regression(m, exponentiate = TRUE)

  # Save an HTML version (if gt is available)
  tryCatch({
    ensure_package("gt")
    gt::gtsave(as_gt(tbl), "regression_table.html")
  }, error = function(e) invisible(NULL))

  text <- tbl |> as_tibble() |> knitr::kable(format = "pipe") |> paste(collapse = "\n")
  paste0("Logistic regression ", deparse(f),
         " as a gtsummary table (OR > 1 = more risk, OR < 1 = less risk), saved to regression_table.html:\n\n",
         text)
}

tool_model <- tool(
  fit_model,
  paste(
    "Fits a logistic regression (binomial glm) on the loaded dataset and returns a",
    "gtsummary regression table with Odds Ratios, 95% CIs and p-values. Use it to estimate",
    "risk associations (e.g. which variables are associated with higher or lower mortality)."
  ),
  arguments = list(
    outcome = type_string("Binary outcome variable (0/1). Defaults to 'died'.", required = FALSE),
    predictors = type_string("Predictors separated by commas (e.g. 'age, treatment, comorbidities'). Omit to use all.", required = FALSE)
  )
)

# ============================================================
# Final registration: all the agent's tools
# ============================================================
TOOLS <- list(
  tool_load,
  tool_table,
  tool_model
)
