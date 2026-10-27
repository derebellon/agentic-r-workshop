# ============================================================
# agent.R  -  The HARNESS (the agent's "engine")
# ------------------------------------------------------------
# An agent = MODEL (LLM) + TOOLS + a LOOP.
# This file is the LOOP. It barely changes between projects.
#
# What YOU customise lives in two other files:
#   - soul.md   : who the agent is and its rules  (the "system prompt")
#   - tools.R   : the R functions the agent can run
#
# You switch the ENGINE in a single line (local or online). See below.
#
# How to run it:
#   A) In RStudio / an R session:
#        source("agent.R")
#        ask("Load the data and give me Table 1 by treatment")
#   B) In the terminal (chat mode):
#        AGENT_ENGINE=ollama AGENT_MODEL=qwen2.5:3b Rscript agent.R
# ============================================================

suppressPackageStartupMessages({
  if (!requireNamespace("ellmer", quietly = TRUE)) {
    install.packages("ellmer", repos = "https://cloud.r-project.org")
  }
  library(ellmer)
})

# ---- 1. CHOOSE THE ENGINE ----------------------------------
# "ollama" = a LOCAL model on your machine (private, free, offline)
# "claude" = Claude in the cloud (needs ANTHROPIC_API_KEY, more capable)
#
# Default local model: qwen2.5:3b -> fast and light, good tool calling.
# Other local options: "qwen3:4b" (reasons better, slower) or
# "gpt-oss:20b" (more capable, needs ~16 GB RAM). Set it with AGENT_MODEL.
ENGINE <- Sys.getenv("AGENT_ENGINE", "ollama")
MODEL  <- Sys.getenv("AGENT_MODEL",
                     if (ENGINE == "claude") "claude-sonnet-5" else "qwen2.5:3b")

# ---- 2. THE SOUL (system prompt) ---------------------------
soul <- paste(readLines("agent/soul.md", warn = FALSE), collapse = "\n")

# ---- 3. CREATE THE CHAT with the chosen engine -------------
# This is the ONLY difference between running LOCAL and in the CLOUD:
make_chat <- function() {
  if (ENGINE == "ollama") {
    chat_ollama(model = MODEL, system_prompt = soul)
  } else if (ENGINE == "claude") {
    chat_anthropic(model = MODEL, system_prompt = soul)
  } else {
    stop("Unknown ENGINE: '", ENGINE, "'. Use 'ollama' or 'claude'.")
  }
}
chat <- make_chat()

# ---- 4. LOAD AND REGISTER THE TOOLS ------------------------
source("agent/tools.R")        # defines the list TOOLS
for (t in TOOLS) chat$register_tool(t)

# ---- 5. TALK TO THE AGENT ----------------------------------
# Handy function to use inside R / RStudio:
ask <- function(text) {
  invisible(chat$chat(text))
}

cat("====================================================\n")
cat(" Agent 'Rho' ready.\n")
cat("   Engine:", ENGINE, "\n")
cat("   Model :", MODEL, "\n")
cat("   Tools :", length(TOOLS), "tools registered\n")
cat("====================================================\n")

# Terminal mode (REPL): only when run with Rscript, not in RStudio
if (!interactive()) {
  cat("Type your message. 'quit' to exit.\n\n")
  con <- file("stdin")
  repeat {
    cat("> ")
    line <- readLines(con, n = 1)
    if (length(line) == 0) break
    line <- trimws(line)
    if (tolower(line) %in% c("quit", "exit", "q")) break
    if (line == "") next
    chat$chat(line)
    cat("\n")
  }
  close(con)
} else {
  cat("Use:  ask(\"your message\")\n")
  cat("E.g.: ask(\"Load the data and give me Table 1 comparing by treatment\")\n\n")
}
