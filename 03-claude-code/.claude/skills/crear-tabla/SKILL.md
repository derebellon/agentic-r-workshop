---
name: crear-tabla
description: Crea una Tabla 1 (descriptiva o comparativa) en R con gtsummary. Usala cuando el usuario pida una tabla descriptiva, una tabla 1, o comparar variables entre grupos (por tratamiento, por desenlace, etc.). Si se compara entre grupos, agrega valores p con add_p().
---

# Skill: crear-tabla

Genera una Tabla 1 a partir de `data/cohorte.csv` usando **gtsummary**.

## Cuando usarla
- "hazme la tabla 1", "tabla descriptiva" -> tabla simple.
- "compara por tratamiento / por desenlace", "tabla comparativa con p" -> usa `by =` y `add_p()`.

## Como hacerlo

1. Asegurate de que `gtsummary` este instalado; si no, instalalo.
2. Escribe un script en `R/crear_tabla.R` con este patron y ejecutalo con `Rscript`.

```r
# R/crear_tabla.R
if (!requireNamespace("gtsummary", quietly = TRUE))
  install.packages("gtsummary", repos = "https://cloud.r-project.org")
library(gtsummary)

datos <- read.csv("data/cohorte.csv", stringsAsFactors = TRUE)
datos$id <- NULL

# --- Tabla descriptiva simple ---
tbl <- tbl_summary(datos)

# --- Tabla COMPARATIVA (descomenta y ajusta la variable de grupo) ---
# tbl <- tbl_summary(datos, by = tratamiento) |> add_p()

# Guardar en HTML y mostrar en consola
gtsummary::as_gt(tbl) |> gt::gtsave("tabla.html")
print(as_tibble(tbl), n = 100)
```

3. Para una tabla comparativa, cambia `by = tratamiento` por la variable pedida
   (p.ej. `by = fallecido`) y manten `|> add_p()` para los valores p.
4. Reporta la tabla y da una interpretacion breve.

## Notas
- `add_p()` elige la prueba automaticamente (chi-cuadrado, Wilcoxon, etc.).
- La tabla queda guardada en `tabla.html` para abrirla en el navegador.
