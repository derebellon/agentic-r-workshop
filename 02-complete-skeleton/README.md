# 02 — The working agent (START HERE)

This is the agent **Rho**, ready to run. Full step-by-step is in the [main README](../README.md) (section 5). Quick version:

**In RStudio:**
1. **Session menu → Set Working Directory → Choose Directory…** → pick this folder.
2. In the R console:
   ```r
   source("agent.R")
   ask("Give me Table 1 comparing by treatment, with p-values")
   ask("Which variables are associated with higher mortality?")
   ```

It builds the table with `gtsummary` (saved to `table.html`) and fits a logistic regression,
all on your computer with a free local model.

It builds the Table 1 with `gtsummary` (`table.html`) and fits a logistic regression shown as
a `gtsummary` regression table (`regression_table.html`), all on your computer with a free
local model.

The files: `soul.md` (who the agent is) · `tools.R` (its R functions: `load_data`,
`make_table`, `fit_model`) · `agent.R` (the engine) · `cohort.csv` (the example data). Going
from the empty folder `01` to this one is just filling in `soul.md` and `tools.R`.

**Want to teach the agent a new skill?** See [ADDING-A-TOOL.md](ADDING-A-TOOL.md), a
line-by-line, hands-on walkthrough of adding your own tool.

**Requirements:** R, RStudio, the `ellmer` package, and Ollama with a model
(`ollama pull qwen2.5:3b`). See the main README, sections 1 and 3.
