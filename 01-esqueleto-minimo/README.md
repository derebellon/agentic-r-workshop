# 01 - Esqueleto minimo

El agente mas pequeno que corre: harness + alma (casi vacia) + una tool de ejemplo.
Sirve para entender las 3 piezas antes de llenarlas.

```
agente.R    <- el loop (el "motor"). No lo tocas.
alma.md     <- quien es el agente (PLANTILLA: llenala)
tools.R     <- sus herramientas (trae 1 de ejemplo: la hora)
```

## Correr (modelo local con Ollama)

Requisitos: R, el paquete `ellmer`, y Ollama con un modelo descargado
(ver `docs/tutorial.html`). Por defecto usa `qwen2.5:3b`.

**Opcion A - dentro de R / RStudio:**
```r
source("agente.R")
preguntar("Que hora es?")
```

**Opcion B - en la terminal (modo chat):**
```bash
Rscript agente.R
```

## Tu tarea en el taller
1. Dale identidad al agente en `alma.md`.
2. Agrega tus propias herramientas en `tools.R`.
3. Compara con `02-esqueleto-completo/`, que ya trae todo lleno.

## Cambiar de modelo
```bash
AGENTE_MODELO=qwen3:4b Rscript agente.R      # local, razona mejor
AGENTE_MOTOR=claude Rscript agente.R          # Claude en la nube (necesita ANTHROPIC_API_KEY)
```
