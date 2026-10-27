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
    old <- options(install.packages.compile.from.source = "never")  # use binaries, don't ask
    on.exit(options(old))
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
load_data <- function(path = "data/cohort.csv") {
  # If data is already loaded, don't reload: that would wipe any changes made in
  # this session (e.g. a relabel the agent just did). Keep what we have.
  if (!is.null(.state$data)) {
    return(paste0("Data is already loaded (", nrow(.state$data), " rows, ",
                  ncol(.state$data), " variables); keeping any changes already made."))
  }
  if (!file.exists(path)) {
    for (alt in c(path, file.path("data", basename(path)),
                  file.path("..", "data", basename(path)), basename(path))) {
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
make_table <- function(compare_by = NULL, variable = NULL, predictors = NULL) {
  # `variable` and `predictors` are accepted but ignored: small models sometimes
  # invent them. The Table 1 always includes every variable, so we just drop them.
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

  dir.create("tables", showWarnings = FALSE); dir.create("scripts", showWarnings = FALSE)
  # Save an HTML version (if gt is available)
  tryCatch({
    ensure_package("gt")
    suppressWarnings(gt::gtsave(as_gt(tbl), "tables/table.html"))
  }, error = function(e) invisible(NULL))

  # Save the reproducible R script that produces this table
  tryCatch({
    line_tbl <- if (is.null(compare_by) || !nzchar(compare_by))
      "tbl <- tbl_summary(data)"
    else
      paste0("tbl <- tbl_summary(data, by = ", compare_by, ") |> add_p()")
    writeLines(c(
      "# Reproducible script for this table (written by the agent's make_table tool).",
      "# Run it from the folder root (where agent.R is).",
      "library(gtsummary)",
      'data <- read.csv("data/cohort.csv", stringsAsFactors = TRUE)',
      "data$id <- NULL",
      line_tbl,
      'gtsummary::as_gt(tbl) |> gt::gtsave("tables/table.html")',
      "tbl"
    ), "scripts/table.R")
  }, error = function(e) invisible(NULL))

  # Return the table as text so the model can read and interpret it
  text <- suppressWarnings(tbl |> as_tibble() |> knitr::kable(format = "pipe") |> paste(collapse = "\n"))
  paste0(title, " (table saved to tables/table.html, script to scripts/table.R):\n\n", text)
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
    ),
    variable   = type_string("Not needed and ignored; the table always includes all variables.", required = FALSE),
    predictors = type_string("Not needed and ignored.", required = FALSE)
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

  dir.create("tables", showWarnings = FALSE); dir.create("scripts", showWarnings = FALSE)
  # Save an HTML version (if gt is available)
  tryCatch({
    ensure_package("gt")
    suppressWarnings(gt::gtsave(as_gt(tbl), "tables/regression_table.html"))
  }, error = function(e) invisible(NULL))

  # Save the reproducible R script that produces this regression table
  tryCatch({
    writeLines(c(
      "# Reproducible script for this regression table (written by the agent's fit_model tool).",
      "# Run it from the folder root (where agent.R is).",
      "library(gtsummary)",
      'data <- read.csv("data/cohort.csv", stringsAsFactors = TRUE)',
      "data$id <- NULL",
      paste0("m <- glm(", deparse(f), ", data = data, family = binomial)"),
      "tbl <- tbl_regression(m, exponentiate = TRUE)",
      'gtsummary::as_gt(tbl) |> gt::gtsave("tables/regression_table.html")',
      "tbl"
    ), "scripts/regression_table.R")
  }, error = function(e) invisible(NULL))

  text <- suppressWarnings(tbl |> as_tibble() |> knitr::kable(format = "pipe") |> paste(collapse = "\n"))
  paste0("Logistic regression ", deparse(f),
         " as a gtsummary table (OR > 1 = more risk, OR < 1 = less risk), saved to tables/regression_table.html",
         " and the script to scripts/regression_table.R:\n\n", text)
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
# TOOL 4: make_plot  (bar chart or boxplot with ggplot2)
# ============================================================
make_plot <- function(type = "boxplot", x = NULL, y = NULL, fill = NULL) {
  ensure_package("ggplot2")
  suppressPackageStartupMessages(library(ggplot2))
  data <- get_data()
  # Palette from the hemogram paper (SLATE, ROSE) + harmonious muted tones.
  PAL <- c("#2D3A47", "#B46A72", "#6E8B74", "#C9A66B", "#9A8CA6")
  type <- tolower(if (is.null(type) || !nzchar(type)) "boxplot" else type)
  if (is.null(x) || !nzchar(x) || !x %in% names(data))
    stop("Please give an existing 'x' variable. Variables: ", paste(names(data), collapse = ", "))

  if (type %in% c("box", "boxplot")) {
    if (is.null(y) || !nzchar(y) || !y %in% names(data))
      stop("A boxplot needs a numeric 'y' variable, e.g. y = 'age'.")
    data[[x]] <- as.factor(data[[x]])                      # groups must be categorical
    code_setup <- paste0("data$", x, " <- as.factor(data$", x, ")")
    p <- ggplot(data, aes(x = .data[[x]], y = .data[[y]], fill = .data[[x]])) +
      geom_boxplot(alpha = 0.9, outlier.alpha = 0.4) +
      scale_fill_manual(values = PAL) + labs(x = x, y = y) +
      theme_classic(base_size = 13) + theme(legend.position = "none")
    fname <- paste0("boxplot_", y, "_by_", x, ".png")
    code_plot <- paste0("ggplot(data, aes(x = ", x, ", y = ", y, ", fill = ", x, ")) +\n",
      "  geom_boxplot(alpha = 0.9, outlier.alpha = 0.4) +\n",
      "  scale_fill_manual(values = PAL) + labs(x = \"", x, "\", y = \"", y, "\") +\n",
      "  theme_classic(base_size = 13) + theme(legend.position = \"none\")")
  } else {
    fillvar <- if (!is.null(fill) && nzchar(fill) && fill %in% names(data)) fill else x
    data[[x]] <- as.factor(data[[x]]); data[[fillvar]] <- as.factor(data[[fillvar]])
    code_setup <- paste0("data$", x, " <- as.factor(data$", x, "); data$", fillvar, " <- as.factor(data$", fillvar, ")")
    p <- ggplot(data, aes(x = .data[[x]], fill = .data[[fillvar]])) +
      geom_bar(position = "dodge", alpha = 0.9) +
      scale_fill_manual(values = PAL) + labs(x = x, y = "Count", fill = fillvar) +
      theme_classic(base_size = 13)
    fname <- paste0("barplot_", x, ".png")
    code_plot <- paste0("ggplot(data, aes(x = ", x, ", fill = ", fillvar, ")) +\n",
      "  geom_bar(position = \"dodge\", alpha = 0.9) +\n",
      "  scale_fill_manual(values = PAL) + labs(x = \"", x, "\", y = \"Count\") +\n",
      "  theme_classic(base_size = 13)")
  }

  dir.create("figures", showWarnings = FALSE); dir.create("scripts", showWarnings = FALSE)
  suppressMessages(suppressWarnings(ggsave(file.path("figures", fname), p, width = 6, height = 4, dpi = 150)))

  # Save the reproducible R script for this figure
  tryCatch({
    writeLines(c(
      "# Reproducible script for this figure (written by the agent's make_plot tool).",
      "# Run it from the folder root (where agent.R is).",
      "library(ggplot2)",
      'data <- read.csv("data/cohort.csv", stringsAsFactors = TRUE)',
      "data$id <- NULL",
      'PAL <- c("#2D3A47", "#B46A72", "#6E8B74", "#C9A66B", "#9A8CA6")',
      code_setup,
      paste0("p <- ", code_plot),
      paste0('ggsave("figures/', fname, '", p, width = 6, height = 4, dpi = 150)'),
      "p"
    ), file.path("scripts", sub("\\.png$", ".R", fname)))
  }, error = function(e) invisible(NULL))

  paste0("Saved a ", type, " to figures/", fname,
         " and the script to scripts/", sub("\\.png$", ".R", fname), ".")
}

tool_plot <- tool(
  make_plot,
  paste(
    "Makes a pretty plot with ggplot2 (theme_classic, clinical colours) and saves it as a PNG.",
    "Use type='boxplot' for a numeric variable across groups (needs x = group and y = numeric),",
    "or type='bar' for counts of a categorical variable (needs x; optional fill)."
  ),
  arguments = list(
    type = type_string("'boxplot' or 'bar'. Defaults to boxplot.", required = FALSE),
    x    = type_string("The variable on the x axis / grouping, e.g. 'treatment'."),
    y    = type_string("For a boxplot, the numeric variable, e.g. 'age'. Not needed for a bar chart.", required = FALSE),
    fill = type_string("Optional: a second variable to colour bars by, e.g. 'died'.", required = FALSE)
  )
)

# ============================================================
# Final registration: all the agent's tools
# ============================================================
TOOLS <- list(
  tool_load,
  tool_table,
  tool_model,
  tool_plot
)
