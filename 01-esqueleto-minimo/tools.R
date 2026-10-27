# ============================================================
# tools.R  -  Las HERRAMIENTAS del agente (ESQUELETO / plantilla)
# ------------------------------------------------------------
# Una herramienta = una funcion R + una descripcion para el modelo.
# El modelo nunca ve tu codigo, solo la descripcion: por eso la
# descripcion importa tanto como la funcion.
#
# Pasos para crear una tool:
#   1. Escribe una funcion R normal.
#   2. Envuelvela con tool(funcion, "descripcion", arguments = list(...)).
#   3. Agregala a la lista TOOLS al final.
#
# Este esqueleto trae UNA tool de ejemplo para que el agente corra ya.
# Tu trabajo en el taller: agregar las tuyas (ver 02-esqueleto-completo).
# ============================================================

library(ellmer)

# ---- Tool de ejemplo: la hora actual -----------------------
hora_actual <- function() {
  format(Sys.time(), "%Y-%m-%d %H:%M:%S")
}

tool_hora <- tool(
  hora_actual,
  "Devuelve la fecha y la hora actuales del sistema.",
  arguments = list()        # esta funcion no recibe argumentos
)

# ============================================================
# TODO: agrega aqui tus propias herramientas.
#
# Idea (lo que construimos en 02-esqueleto-completo):
#   cargar_datos(ruta)        -> leer un CSV
#   crear_tabla(comparar_por) -> Tabla 1 con gtsummary (+ add_p)
#   ajustar_modelo(...)       -> regresion logistica (Odds Ratios)
#
# Molde para una tool nueva:
#
#   mi_funcion <- function(x) {
#     # ...tu codigo R...
#   }
#   tool_mia <- tool(
#     mi_funcion,
#     "Describe que hace y cuando usarla.",
#     arguments = list(
#       x = type_string("Que es x.")
#     )
#   )
# ============================================================

# ---- Registra TODAS tus tools en esta lista ----------------
TOOLS <- list(
  tool_hora
  # , tool_cargar, tool_tabla, tool_modelo   # <- agrega las tuyas aqui
)
