# ============================================================
# tools.R  -  The agent's TOOLS (SKELETON / template)
# ------------------------------------------------------------
# A tool = an R function + a description for the model.
# The model never sees your code, only the description: so the
# description matters as much as the function.
#
# Steps to create a tool:
#   1. Write a normal R function.
#   2. Wrap it with tool(function, "description", arguments = list(...)).
#   3. Add it to the TOOLS list at the end.
#
# This skeleton ships with ONE example tool so the agent runs already.
# Your job in the workshop: add your own (see 02-complete-skeleton).
# ============================================================

library(ellmer)

# ---- Example tool: the current time ------------------------
current_time <- function() {
  format(Sys.time(), "%Y-%m-%d %H:%M:%S")
}

tool_time <- tool(
  current_time,
  "Returns the current system date and time.",
  arguments = list()        # this function takes no arguments
)

# ============================================================
# TODO: add your own tools here.
#
# Idea (what we build in 02-complete-skeleton):
#   load_data(path)          -> read a CSV
#   make_table(compare_by)   -> Table 1 with gtsummary (+ add_p)
#   fit_model(...)           -> logistic regression (Odds Ratios)
#
# Template for a new tool:
#
#   my_function <- function(x) {
#     # ...your R code...
#   }
#   tool_mine <- tool(
#     my_function,
#     "Describe what it does and when to use it.",
#     arguments = list(
#       x = type_string("What x is.")
#     )
#   )
# ============================================================

# ---- Register ALL your tools in this list ------------------
TOOLS <- list(
  tool_time
  # , tool_load, tool_table, tool_model   # <- add yours here
)
