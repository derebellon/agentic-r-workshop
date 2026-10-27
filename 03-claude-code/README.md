# 03 - The same agent in Claude Code CLI

Here the **Rho** agent runs inside **Claude Code** (Anthropic's CLI), not in the
home-made harness. Same concept, but the loop, the tools and a far more capable
model come "out of the box".

```
CLAUDE.md                         <- the "soul" (project system prompt)
.claude/skills/make-table/        <- a "skill" = a documented tool
data/cohort.csv                   <- the same data
```

## Mapping to the home-made harness

| Harness (01-02)        | Claude Code (03)                         |
|------------------------|------------------------------------------|
| `soul.md`              | `CLAUDE.md`                              |
| `tools.R`              | `.claude/skills/` + native Bash/Read/Write |
| `agent.R` (the loop)   | shipped with Claude Code                 |
| local model            | Claude (cloud)                           |

## Run it

Requirements: [Claude Code](https://claude.com/claude-code) installed and signed in,
and R available.

```bash
cd 03-claude-code
claude
```

Then ask, for example:
- "Give me Table 1 comparing by treatment, with p-values."
- "Which variables are associated with higher mortality? Fit a logistic regression."

Claude Code will read `CLAUDE.md`, use the `make-table` skill, write a reproducible
R script in `R/`, run it, and show you (and interpret) the result.

## Why it feels more powerful
Claude reads your repo, writes and runs code, fixes itself if something fails, and
chains several steps without you programming the loop. That is what, with much more
effort, we reproduce in miniature with the local harness in folders 01-02.
