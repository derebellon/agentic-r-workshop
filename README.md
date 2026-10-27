# Agentic R — a minimal skeleton of an agent for analysis in R

Material for the workshop **"Agentic R: using agentic systems to efficiently write,
review and produce reproducible code"** (R Users Group).

The idea is simple: an **agent** is not magic. It is **three pieces**.

```
AGENT = MODEL (an LLM)  +  TOOLS (your functions)  +  a LOOP
```

This repo gives you that skeleton, ready to run on your laptop (even **offline**,
with a **local** model), and teaches you to customise it with the R libraries you want.

---

## What's here

| Folder | What it is |
|---|---|
| **`data/`** | A reproducible synthetic cohort (`cohort.csv`, 400 patients) and the script that builds it. |
| **`01-minimal-skeleton/`** | The smallest agent that runs: loop + soul (template) + 1 example tool. To understand the pieces. |
| **`02-complete-skeleton/`** | The same agent, filled in: it talks to your data, builds a Table 1 with `gtsummary` and fits a logistic regression. |
| **`03-claude-code/`** | The SAME agent, running in Claude Code CLI. To compare local vs. cloud. |
| **`docs/tutorial.html`** | Step-by-step tutorial: install Ollama, run local models, and use all of this. **Open it in your browser.** |

---

## Quick start (local model, free and private)

**1. Install the pieces** (details in `docs/tutorial.html`):
- [R](https://cran.r-project.org/) and, if you like, [RStudio](https://posit.co/download/rstudio-desktop/).
- The `ellmer` package:  `install.packages("ellmer")`
- [Ollama](https://ollama.com/download) (to run local models).

**2. Download a local model:**
```bash
ollama pull qwen2.5:3b     # light and fast, runs on almost any laptop
```

**3. Run the agent:**
```r
# inside R / RStudio, in the 02-complete-skeleton folder
source("agent.R")
ask("Give me Table 1 comparing by treatment, with p-values")
ask("Which variables are associated with higher mortality?")
```

That's it. The agent loads the data, calls your R functions, and interprets the result.

---

## The dataset (and the "right answer")

`data/cohort.csv` is **synthetic and reproducible** (fixed seed). It has associations
baked in on purpose, so the agent "discovers" what we already know to be true:

- **Comorbidities** → higher mortality (OR ≈ 3.8)
- **Treatment 1** → lower mortality (OR ≈ 0.26)
- **Treatment 2** → higher mortality (OR ≈ 2.0)
- **Age** → higher mortality (OR ≈ 1.05 per year)
- **Sex** → no real effect

To regenerate it:  `cd data && Rscript generate_data.R`

---

## Local models (pick one for your laptop)

| Model | Size | For what |
|---|---|---|
| `qwen2.5:3b` | ~2 GB | **Default.** Fast, good tool calling, almost any PC. |
| `qwen3:4b` | ~2.6 GB | Reasons better, a bit slower. |
| `gpt-oss:20b` | ~13 GB | The most capable. Needs ~16 GB RAM. |

Switch the model with a variable, without touching the code:
```bash
AGENT_MODEL=qwen3:4b Rscript agent.R
```

---

## Customise your own agent

Going from the empty skeleton (`01`) to the working one (`02`) is **just filling in
two files**:

- **`soul.md`** → who the agent is and its rules (the *system prompt*).
- **`tools.R`** → the R functions it can run (your libraries, your workflow).

The engine (`agent.R`) **does not change**. That is the point: once you have the
harness, customising an agent is describing who it is and giving it tools.

---

*Workshop prepared by David Rebellón Sánchez.*
