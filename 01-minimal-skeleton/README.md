# 01 - Minimal skeleton

The smallest agent that runs: harness + soul (almost empty) + one example tool.
It exists to show the 3 pieces before you fill them in.

```
agent.R     <- the loop (the "engine"). You don't touch it.
soul.md     <- who the agent is (TEMPLATE: fill it in)
tools.R     <- its tools (ships with 1 example: the time)
```

## Run it (local model with Ollama)

Requirements: R, the `ellmer` package, and Ollama with a model downloaded
(see `docs/tutorial.html`). Defaults to `qwen2.5:3b`.

**Option A - inside R / RStudio:**
```r
source("agent.R")
ask("What time is it?")
```

**Option B - in the terminal (chat mode):**
```bash
Rscript agent.R
```

## Your task in the workshop
1. Give the agent an identity in `soul.md`.
2. Add your own tools in `tools.R`.
3. Compare with `02-complete-skeleton/`, which is already filled in.

## Switch model
```bash
AGENT_MODEL=qwen3:4b Rscript agent.R      # local, reasons better
AGENT_ENGINE=claude Rscript agent.R        # Claude in the cloud (needs ANTHROPIC_API_KEY)
```
