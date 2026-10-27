# ============================================================
# setup.R  -  One-command setup for the Agentic R workshop
# ------------------------------------------------------------
# WHAT IT DOES: installs the R package 'ellmer', installs Ollama
# (if missing), downloads the local model, and checks everything.
#
# HOW TO RUN IT:
#   Open this repo's folder in RStudio, then in the R CONSOLE type:
#       source("setup.R")
#   (Run it from the R console, NOT the Terminal. The script picks the
#    right commands for your operating system automatically, so you do
#    not need to know PowerShell vs bash.)
# ============================================================

cat("\n================ Agentic R setup ================\n\n")

os <- Sys.info()[["sysname"]]          # "Windows", "Darwin" (Mac), or "Linux"
have <- function(cmd) nzchar(Sys.which(cmd))   # is a program on the PATH?

# --- 1. ellmer (the R package that talks to AI models) ------
if (!requireNamespace("ellmer", quietly = TRUE)) {
  cat("[1/4] Installing the 'ellmer' R package...\n")
  install.packages("ellmer", repos = "https://cloud.r-project.org")
} else {
  cat("[1/4] ellmer R package: already installed.\n")
}

# --- 2. Ollama (runs AI models locally, free) ---------------
if (!have("ollama")) {
  cat("[2/4] Ollama not found. Installing it...\n")
  tryCatch({
    if (os == "Windows") {
      system('powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://ollama.com/install.ps1 | iex"')
    } else {
      system("curl -fsSL https://ollama.com/install.sh | sh")
    }
  }, error = function(e) cat("   (automatic install failed:", conditionMessage(e), ")\n"))

  if (!have("ollama")) {
    cat("\n   >> Ollama is installed but this R session can't see it yet,\n")
    cat("   >> OR it needs admin rights. Do ONE of these, then run source(\"setup.R\") again:\n")
    cat("      - Restart RStudio (Session menu -> Restart R), or\n")
    if (os == "Windows")
      cat("      - Run in a terminal:  irm https://ollama.com/install.ps1 | iex\n")
    else
      cat("      - Run in a terminal:  curl -fsSL https://ollama.com/install.sh | sh\n")
  }
} else {
  cat("[2/4] Ollama: already installed.\n")
}

# --- 3. Download the model (first time only, ~2 GB) ---------
if (have("ollama")) {
  cat("[3/4] Downloading the model qwen2.5:3b (first time only, be patient)...\n")
  system("ollama pull qwen2.5:3b")
} else {
  cat("[3/4] Skipping the model download until Ollama is available.\n")
}

# --- 4. Claude Code (OPTIONAL, only for folder 03) ----------
# Set to TRUE if you want this script to install Claude Code too.
INSTALL_CLAUDE <- FALSE
if (INSTALL_CLAUDE && !have("claude")) {
  cat("[4/4] Installing Claude Code...\n")
  if (have("npm")) {
    system("npm install -g @anthropic-ai/claude-code")
  } else if (os != "Windows") {
    system("curl -fsSL https://claude.ai/install.sh | bash")
  } else {
    system('powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://claude.ai/install.ps1 | iex"')
  }
} else {
  cat("[4/4] Claude Code: skipped (optional, only needed for folder 03).\n")
}

# --- Final check --------------------------------------------
cat("\n==================== Check ======================\n")
ok_ellmer <- requireNamespace("ellmer", quietly = TRUE)
ok_ollama <- have("ollama")
ok_model  <- tryCatch(any(grepl("qwen2.5:3b", system("ollama list", intern = TRUE, ignore.stderr = TRUE))),
                      error = function(e) FALSE)
cat(" ellmer R package :", if (ok_ellmer) "OK" else "MISSING", "\n")
cat(" ollama installed :", if (ok_ollama) "OK" else "MISSING", "\n")
cat(" model qwen2.5:3b :", if (isTRUE(ok_model)) "OK" else "not downloaded yet", "\n")

if (ok_ellmer && ok_ollama && isTRUE(ok_model)) {
  cat("\n All set! Next: set your working directory to 02-complete-skeleton and run:\n")
  cat("    source(\"agent.R\")\n")
  cat("    ask(\"Give me Table 1 comparing by treatment, with p-values\")\n")
} else {
  cat("\n Not quite ready, follow the notes above and run source(\"setup.R\") again.\n")
}
cat("=================================================\n\n")
