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

# Use pre-built binaries and NEVER pause to ask about compiling from source
# (compiling would need extra tools like Rtools on Windows, and isn't necessary).
options(install.packages.compile.from.source = "never")

cat("\n================ Agentic R setup ================\n\n")
flush.console()

os <- Sys.info()[["sysname"]]          # "Windows", "Darwin" (Mac), or "Linux"
have <- function(cmd) nzchar(Sys.which(cmd))   # is a program on the PATH?

# --- 1. ellmer (the R package that talks to AI models) ------
pkgs <- c("ellmer", "gtsummary", "gt", "ggplot2")   # the agent + what its tools use
need <- pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)]
if (length(need)) {
  cat("[1/4] Installing R packages:", paste(need, collapse = ", "), "...\n")
  cat("      This downloads several packages and can take a few minutes. Please wait.\n")
  flush.console()
  install.packages(need, repos = "https://cloud.r-project.org")
} else {
  cat("[1/4] R packages (ellmer, gtsummary, gt, ggplot2): already installed.\n")
}

# --- 2. Ollama (runs AI models locally, free) ---------------
if (!have("ollama")) {
  cat("[2/4] Ollama not found. Installing it...\n")
  cat("      IMPORTANT: on Windows this can make the screen look FROZEN for 5-10 minutes\n")
  cat("      while Ollama installs in the background. It is NOT stuck. Please wait and do\n")
  cat("      not close RStudio. It will continue by itself when it finishes.\n")
  flush.console()
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
  cat("[3/4] Downloading the model qwen2.5:3b (~2 GB, first time only).\n")
  cat("      This can take several minutes. You'll see download progress below. Please wait.\n")
  flush.console()
  # Make sure the Ollama background server is up before we pull (harmless if already running).
  try(system("ollama serve", wait = FALSE, ignore.stdout = TRUE, ignore.stderr = TRUE), silent = TRUE)
  Sys.sleep(2)
  system("ollama pull qwen2.5:3b")
} else {
  cat("[3/4] Skipping the model download until Ollama is available.\n")
}

# --- 4. Claude Code (installed by default, for folder 03) ---
# Installed and added to your PATH automatically. Set to FALSE to skip.
INSTALL_CLAUDE <- TRUE
if (have("claude")) {
  cat("[4/4] Claude Code: already installed.\n")
} else if (INSTALL_CLAUDE) {
  cat("[4/4] Installing Claude Code (downloading, please wait)...\n")
  flush.console()
  tryCatch({
    if (os == "Windows") {
      system('powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://claude.ai/install.ps1 | iex"')
      # Add Claude to the user PATH so 'claude' is recognized (fixes the Windows
      # 'claude is not recognized' problem). Written to a temp .ps1 to avoid quoting issues.
      ps <- c(
        '$u = [Environment]::GetEnvironmentVariable("Path","User")',
        '$c = "$env:USERPROFILE\\.local\\bin"',
        'if (($u -split ";") -notcontains $c) { [Environment]::SetEnvironmentVariable("Path", "$u;$c", "User") }'
      )
      f <- tempfile(fileext = ".ps1"); writeLines(ps, f)
      system(paste0('powershell -NoProfile -ExecutionPolicy Bypass -File "', f, '"'))
      cat("   Added Claude to your user PATH. If 'claude' still isn't found, restart RStudio.\n")
    } else {
      system("curl -fsSL https://claude.ai/install.sh | bash")
    }
  }, error = function(e) cat("   (Claude install failed:", conditionMessage(e), ")\n"))
} else {
  cat("[4/4] Claude Code: skipped (set INSTALL_CLAUDE <- TRUE to install).\n")
}

# --- Final check --------------------------------------------
cat("\n==================== Check ======================\n")
ok_ellmer <- all(vapply(c("ellmer", "gtsummary", "gt", "ggplot2"),
                        requireNamespace, logical(1), quietly = TRUE))
ok_ollama <- have("ollama")
ok_model  <- tryCatch(any(grepl("qwen2.5:3b", system("ollama list", intern = TRUE, ignore.stderr = TRUE))),
                      error = function(e) FALSE)
cat(" R packages       :", if (ok_ellmer) "OK (ellmer, gtsummary, gt, ggplot2)" else "MISSING", "\n")
cat(" ollama installed :", if (ok_ollama) "OK" else "MISSING", "\n")
cat(" model qwen2.5:3b :", if (isTRUE(ok_model)) "OK" else "not downloaded yet", "\n")
cat(" claude (folder 03):", if (have("claude")) "OK" else "installed - restart RStudio if not found", "\n")

if (ok_ellmer && ok_ollama && isTRUE(ok_model)) {
  cat("\n All set! Next: set your working directory to 02-complete-skeleton and run:\n")
  cat("    source(\"agent.R\")\n")
  cat("    ask(\"Give me Table 1 comparing by treatment, with p-values\")\n")
} else {
  cat("\n Not quite ready, follow the notes above and run source(\"setup.R\") again.\n")
}
cat("=================================================\n\n")
