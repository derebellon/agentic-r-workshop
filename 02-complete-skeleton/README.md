# 02 - Complete skeleton (working)

The same harness as in `01`, but with the **soul filled in** and **three real tools**
that analyse the synthetic cohort (`cohort.csv`).

```
agent.R      <- the loop (identical to 01's)
soul.md      <- Rho, an epidemiology assistant in R (filled in)
tools.R      <- load_data, make_table (gtsummary + add_p), fit_model (glm)
cohort.csv   <- example data (400 patients)
```

## Run it (local model with Ollama)

Requirements: R, `ellmer`, and Ollama with a model (see `docs/tutorial.html`).
Defaults to `qwen2.5:3b` (fast and light).

**Inside R / RStudio:**
```r
source("agent.R")
ask("Give me Table 1 comparing by treatment, with p-values")
ask("Which variables are associated with higher mortality?")
```

**In the terminal (chat mode):**
```bash
Rscript agent.R
```

## What to expect
- `make_table(compare_by = "treatment")` -> comparative Table 1 with gtsummary
  and p-values (`add_p`). Saved to `table.html`.
- `fit_model()` -> logistic regression with Odds Ratios. It should show that
  **comorbidities** and **trt2** raise mortality, and **trt1** lowers it
  (these associations are baked into the dataset on purpose).

If a library (e.g. `gtsummary`) is not installed, the tool installs it itself.

## The lesson
Going from `01` to `02` is JUST filling in `soul.md` and `tools.R`. The engine
(`agent.R`) does not change. That is how you "customise" an agent to work with
YOUR libraries and functions.

## Switch model
```bash
AGENT_MODEL=qwen3:4b Rscript agent.R       # local, reasons better, slower
AGENT_MODEL=gpt-oss:20b Rscript agent.R    # local, more capable, ~16 GB RAM
AGENT_ENGINE=claude AGENT_MODEL=claude-sonnet-5 Rscript agent.R   # Claude (cloud)
```
