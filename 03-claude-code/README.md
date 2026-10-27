# 03 — The same agent with Claude Code

Here **Rho** runs inside **Claude Code** (Anthropic's CLI), a ready-made external agent that
uses Claude in the cloud. Same idea as folders 01–02, more power out of the box.
Full guide in the [main README](../README.md) (section 7).

**Run it:**
1. Install Claude Code (you'll need a Claude account). Pick your terminal:
   ```bash
   # macOS / Linux
   curl -fsSL https://claude.ai/install.sh | bash
   # Windows PowerShell
   irm https://claude.ai/install.ps1 | iex
   # Windows CMD
   curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd
   # or, any system with Node.js
   npm install -g @anthropic-ai/claude-code
   ```
   On Windows, if `claude` is "not recognized" afterwards, see the PATH fix in the
   [main README](../README.md) (section 4), or just run `setup.R` which does it for you.
2. Open the **Terminal**, go into this folder (`cd ` then drag the folder in, press Enter),
   and type:
   ```bash
   claude
   ```
3. Then just type your request in plain English:
   ```
   Give me Table 1 comparing by treatment, with p-values
   ```

Claude Code reads `CLAUDE.md` (the agent's instructions) and the skill in
`.claude/skills/make-table/`, writes an R script, runs it, and shows you the result.

**The mapping:** `soul.md` → `CLAUDE.md` · `tools.R` → `.claude/skills/` · the loop →
built into Claude Code · local model → Claude (cloud).
