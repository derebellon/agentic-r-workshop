# 02 — The working agent (START HERE)

This is the agent **Rho**, ready to run. Full step-by-step is in the
[main README](../README.md) (section 5). Quick version:

**In RStudio:**
1. **Session menu → Set Working Directory → Choose Directory…** → pick **this** folder.
2. In the R console:
   ```r
   source("agent.R")
   ask("Give me Table 1 comparing by treatment, with p-values")
   ask("Which variables are associated with higher mortality?")
   ask("Make a boxplot of age by treatment")
   ```

The agent builds a Table 1 with `gtsummary`, fits a logistic regression (gtsummary
regression table of Odds Ratios), and draws plots with `ggplot2`, all on your computer with
a free local model.

## How this folder is organised

```
02-complete-skeleton/
├─ agent.R        <- the engine (the loop). Run this: source("agent.R"). Don't edit it.
├─ agent/
│  ├─ soul.md     <- who the agent is and its rules (the system prompt)
│  └─ tools.R     <- the agent's tools: load_data, make_table, fit_model, make_plot
├─ data/
│  └─ cohort.csv  <- the example data
├─ tables/        <- the agent saves .html tables here
├─ figures/       <- the agent saves .png figures here  (ggplot2, theme_classic)
└─ scripts/       <- the agent saves the reproducible .R script for every output here
```

That last part is the point: the agent leaves behind **ordered outputs and the code that
produced them**, because that's written into its instructions and enforced by its tools.
Going from the empty folder `01` to this one is just filling in `soul.md` and `tools.R`.

**Want to teach the agent a new skill?** See [ADDING-A-TOOL.md](ADDING-A-TOOL.md), a
line-by-line, hands-on walkthrough of adding your own tool.

**Requirements:** R, RStudio, the `ellmer` package, and Ollama with a model
(`ollama pull qwen2.5:3b`). `gtsummary` and `ggplot2` install automatically on first use.
See the main README, sections 1 and 3.
