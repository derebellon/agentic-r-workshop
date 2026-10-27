# ============================================================
# agente.R  -  El HARNESS (el "motor" del agente)
# ------------------------------------------------------------
# Un agente = MODELO (LLM) + HERRAMIENTAS (tools) + un LOOP.
# Este archivo es el LOOP. Casi no cambia entre proyectos.
#
# Lo que TU personalizas vive en otros dos archivos:
#   - alma.md   : quien es el agente y sus reglas  (el "system prompt")
#   - tools.R   : las funciones R que el agente puede ejecutar
#
# Cambias el MOTOR en una sola linea (local u online). Ver abajo.
#
# Como correrlo:
#   A) En RStudio / sesion de R:
#        source("agente.R")
#        preguntar("Cargame los datos y hazme la Tabla 1 por tratamiento")
#   B) En la terminal (modo chat):
#        AGENTE_MOTOR=ollama AGENTE_MODELO=qwen3:4b Rscript agente.R
# ============================================================

suppressPackageStartupMessages({
  if (!requireNamespace("ellmer", quietly = TRUE)) {
    install.packages("ellmer", repos = "https://cloud.r-project.org")
  }
  library(ellmer)
})

# ---- 1. ELIGE EL MOTOR -------------------------------------
# "ollama" = modelo LOCAL en tu maquina (privado, gratis, offline)
# "claude" = Claude en la nube (requiere ANTHROPIC_API_KEY, mas potente)
# Modelo por defecto (local): qwen2.5:3b -> rapido y liviano, buen tool calling.
# Alternativas locales: "qwen3:4b" (razona mejor, mas lento) o "gpt-oss:20b" (mas
# capaz, necesita ~16 GB de RAM). Cambialo con la variable AGENTE_MODELO.
MOTOR  <- Sys.getenv("AGENTE_MOTOR", "ollama")
MODELO <- Sys.getenv("AGENTE_MODELO",
                     if (MOTOR == "claude") "claude-sonnet-5" else "qwen2.5:3b")

# ---- 2. EL ALMA (system prompt) ----------------------------
alma <- paste(readLines("alma.md", warn = FALSE), collapse = "\n")

# ---- 3. CREAR EL CHAT con el motor elegido -----------------
# Esta es la unica diferencia entre correr LOCAL y en la NUBE:
crear_chat <- function() {
  if (MOTOR == "ollama") {
    chat_ollama(model = MODELO, system_prompt = alma)
  } else if (MOTOR == "claude") {
    chat_anthropic(model = MODELO, system_prompt = alma)
  } else {
    stop("MOTOR desconocido: '", MOTOR, "'. Usa 'ollama' o 'claude'.")
  }
}
chat <- crear_chat()

# ---- 4. CARGAR Y REGISTRAR LAS HERRAMIENTAS ----------------
source("tools.R")              # define la lista TOOLS
for (t in TOOLS) chat$register_tool(t)

# ---- 5. HABLAR CON EL AGENTE -------------------------------
# Funcion comoda para usar dentro de R / RStudio:
preguntar <- function(texto) {
  invisible(chat$chat(texto))
}

cat("====================================================\n")
cat(" Agente 'Rho' listo.\n")
cat("   Motor :", MOTOR, "\n")
cat("   Modelo:", MODELO, "\n")
cat("   Tools :", length(TOOLS), "herramientas registradas\n")
cat("====================================================\n")

# Modo terminal (REPL): solo si se corre con Rscript, no en RStudio
if (!interactive()) {
  cat("Escribe tu mensaje. 'salir' para terminar.\n\n")
  con <- file("stdin")
  repeat {
    cat("> ")
    linea <- readLines(con, n = 1)
    if (length(linea) == 0) break
    linea <- trimws(linea)
    if (tolower(linea) %in% c("salir", "exit", "quit")) break
    if (linea == "") next
    chat$chat(linea)
    cat("\n")
  }
  close(con)
} else {
  cat("Usa:  preguntar(\"tu mensaje\")\n")
  cat("Ej.:  preguntar(\"Carga los datos y hazme la Tabla 1 comparando por tratamiento\")\n\n")
}
