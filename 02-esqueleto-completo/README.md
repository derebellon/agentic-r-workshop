# 02 - Esqueleto completo (funcionando)

El mismo harness que en `01`, pero con el **alma llena** y **tres herramientas reales**
que analizan la cohorte sintetica (`cohorte.csv`).

```
agente.R     <- el loop (identico al de 01)
alma.md      <- Rho, asistente de epidemiologia en R (lleno)
tools.R      <- cargar_datos, crear_tabla (gtsummary + add_p), ajustar_modelo (glm)
cohorte.csv  <- datos de ejemplo (400 pacientes)
```

## Correr (modelo local con Ollama)

Requisitos: R, `ellmer`, y Ollama con un modelo (ver `docs/tutorial.html`).
Por defecto usa `qwen2.5:3b` (rapido y liviano).

**Dentro de R / RStudio:**
```r
source("agente.R")
preguntar("Hazme la tabla 1 comparando por tratamiento, con valores p")
preguntar("Que variables se asocian con mayor mortalidad?")
```

**En la terminal (modo chat):**
```bash
Rscript agente.R
```

## Que esperar
- `crear_tabla(comparar_por = "tratamiento")` -> Tabla 1 comparativa con gtsummary
  y valores p (`add_p`). Se guarda en `tabla.html`.
- `ajustar_modelo()` -> regresion logistica con Odds Ratios. Deberia mostrar que
  **comorbilidades** y **trt2** suben la mortalidad, y **trt1** la baja
  (son asociaciones incrustadas a proposito en el dataset).

Si una libreria (p.ej. `gtsummary`) no esta instalada, la herramienta la instala sola.

## La leccion
Pasar de `01` a `02` es SOLO llenar `alma.md` y `tools.R`. El motor (`agente.R`)
no cambia. Asi se "personaliza" un agente para que trabaje con TUS librerias y funciones.

## Cambiar de modelo
```bash
AGENTE_MODELO=qwen3:4b Rscript agente.R       # local, razona mejor, mas lento
AGENTE_MODELO=gpt-oss:20b Rscript agente.R    # local, mas capaz, ~16 GB RAM
AGENTE_MOTOR=claude AGENTE_MODELO=claude-sonnet-5 Rscript agente.R   # Claude (nube)
```
