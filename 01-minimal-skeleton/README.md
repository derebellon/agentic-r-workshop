# 01 — The empty skeleton (to learn and customise)

The same program as `02`, but **empty**, so you can see how simple an agent is and build your
own. Full guide in the [main README](../README.md#5-build-your-own-agent--folder-01).

Three files:
- `soul.md` — who the agent is and its rules. **Edit this.**
- `tools.R` — the R functions it can run (ships with one example: the time). **Add yours.**
- `agent.R` — the engine. **Don't touch it.**

**Try it (in RStudio):**
1. **Session → Set Working Directory → Choose Directory…** → pick this folder.
2. In the R console:
   ```r
   source("agent.R")
   ask("What time is it?")
   ```
3. Open `soul.md` and `tools.R`, edit and save, then `source("agent.R")` again to reload.
   Compare with `02-complete-skeleton` to see where you're headed.
