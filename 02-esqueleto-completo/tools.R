# ============================================================
# tools.R  -  Las HERRAMIENTAS del agente (version completa)
# ------------------------------------------------------------
# Cada herramienta = una funcion R normal + una descripcion
# que le explica al modelo QUE hace y CUANDO usarla.
# El modelo nunca ve tu codigo; solo la descripcion. Por eso
# la descripcion importa tanto como la funcion.
#
# Al final registramos todas en la lista TOOLS, que agente.R lee.
# ============================================================

library(ellmer)

# ---- Estado compartido entre herramientas ------------------
# (aqui guardamos el dataset una vez cargado, para que las
#  demas herramientas puedan usarlo sin recargarlo)
.estado <- new.env()

# ---- Utilidad: instalar un paquete si falta ----------------
asegurar_paquete <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    message("Instalando el paquete '", pkg, "' (no estaba en tu sesion de R)...")
    install.packages(pkg, repos = "https://cloud.r-project.org")
  }
}

obtener_datos <- function() {
  # Defensivo: si el agente olvido cargar los datos, los cargamos solos.
  # (Buena practica: una tool robusta no se rompe si el modelo se salta un paso.)
  if (is.null(.estado$datos)) {
    message("(los datos no estaban cargados; cargando 'cohorte.csv' automaticamente)")
    cargar_datos()
  }
  .estado$datos
}

# ============================================================
# TOOL 1: cargar_datos
# ============================================================
cargar_datos <- function(ruta = "cohorte.csv") {
  if (!file.exists(ruta)) {
    for (alt in c(ruta, file.path("..", "data", basename(ruta)), basename(ruta))) {
      if (file.exists(alt)) { ruta <- alt; break }
    }
  }
  d <- read.csv(ruta, stringsAsFactors = TRUE)
  d$id <- NULL                      # el id no se analiza
  .estado$datos <- d
  paste0("Datos cargados desde '", ruta, "': ", nrow(d), " filas y ",
         ncol(d), " variables (", paste(names(d), collapse = ", "), ").")
}

tool_cargar <- tool(
  cargar_datos,
  "Carga un archivo CSV de datos en la sesion de R para poder analizarlo. Hazlo antes de cualquier tabla o modelo.",
  arguments = list(
    ruta = type_string("Ruta al archivo CSV. Por defecto 'cohorte.csv'.", required = FALSE)
  )
)

# ============================================================
# TOOL 2: crear_tabla  (Tabla 1 con gtsummary, add_p si se compara)
# ============================================================
crear_tabla <- function(comparar_por = NULL) {
  asegurar_paquete("gtsummary")
  suppressPackageStartupMessages(library(gtsummary))
  datos <- obtener_datos()

  if (is.null(comparar_por) || !nzchar(comparar_por)) {
    # Tabla descriptiva simple
    tbl <- tbl_summary(datos)
    titulo <- "Tabla descriptiva (Tabla 1)"
  } else {
    if (!comparar_por %in% names(datos)) {
      stop("La variable '", comparar_por, "' no existe. Variables: ",
           paste(names(datos), collapse = ", "))
    }
    # Tabla comparativa: by = grupo + valores p (add_p)
    tbl <- tbl_summary(datos, by = all_of(comparar_por)) |> add_p()
    titulo <- paste0("Tabla comparativa por '", comparar_por, "' (con valores p)")
  }

  # Guardar una version en HTML (si gt esta disponible)
  tryCatch({
    asegurar_paquete("gt")
    gt::gtsave(as_gt(tbl), "tabla.html")
  }, error = function(e) invisible(NULL))

  # Devolver la tabla como texto para que el modelo la lea e interprete
  texto <- tbl |> as_tibble() |> knitr::kable(format = "pipe") |> paste(collapse = "\n")
  paste0(titulo, " (guardada en tabla.html):\n\n", texto)
}

tool_tabla <- tool(
  crear_tabla,
  paste(
    "Crea una tabla descriptiva (Tabla 1) del dataset cargado usando gtsummary.",
    "Si se indica 'comparar_por', genera una tabla COMPARATIVA entre los niveles de esa",
    "variable y agrega valores p (add_p). Instala gtsummary si no esta instalado."
  ),
  arguments = list(
    comparar_por = type_string(
      "Nombre de la variable por la que comparar (p.ej. 'tratamiento' o 'fallecido'). Omitir para una tabla descriptiva simple.",
      required = FALSE
    )
  )
)

# ============================================================
# TOOL 3: ajustar_modelo  (regresion logistica -> Odds Ratios)
# ============================================================
ajustar_modelo <- function(desenlace = "fallecido", predictores = NULL) {
  datos <- obtener_datos()
  if (!desenlace %in% names(datos)) {
    stop("El desenlace '", desenlace, "' no existe. Variables: ",
         paste(names(datos), collapse = ", "))
  }
  if (is.null(predictores) || !nzchar(predictores)) {
    preds <- setdiff(names(datos), desenlace)
  } else {
    preds <- trimws(strsplit(predictores, ",")[[1]])
  }
  f <- as.formula(paste(desenlace, "~", paste(preds, collapse = " + ")))
  m <- glm(f, data = datos, family = binomial)
  or <- exp(cbind(OR = coef(m), confint.default(m)))
  colnames(or) <- c("OR", "IC2.5", "IC97.5")
  or <- round(or, 3)
  texto <- knitr::kable(or, format = "pipe") |> paste(collapse = "\n")
  paste0("Regresion logistica: ", deparse(f), "\n(OR > 1 = mas riesgo; OR < 1 = menos riesgo)\n\n", texto)
}

tool_modelo <- tool(
  ajustar_modelo,
  paste(
    "Ajusta una regresion logistica (glm binomial) sobre el dataset cargado y devuelve",
    "los Odds Ratios con intervalo de confianza. Usala para estimar asociaciones de riesgo",
    "(p.ej. que variables se asocian con mayor o menor mortalidad)."
  ),
  arguments = list(
    desenlace = type_string("Variable desenlace binaria (0/1). Por defecto 'fallecido'.", required = FALSE),
    predictores = type_string("Predictores separados por coma (p.ej. 'edad, tratamiento, comorbilidades'). Omitir para usar todas.", required = FALSE)
  )
)

# ============================================================
# Registro final: todas las herramientas del agente
# ============================================================
TOOLS <- list(
  tool_cargar,
  tool_tabla,
  tool_modelo
)
