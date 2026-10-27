# Agentic R — esqueleto mínimo de un agente para análisis en R

Material del taller **"Agentic R: using agentic systems to efficiently write, review
and produce reproducible code"** (R Users Group).

La idea es simple: un **agente** no es magia, son **tres piezas**.

```
AGENTE = MODELO (un LLM)  +  HERRAMIENTAS (funciones tuyas)  +  un LOOP
```

Este repo te da ese esqueleto, listo para correr en tu laptop (incluso **sin
internet**, con un modelo **local**), y te enseña a personalizarlo con las
librerías de R que tú quieras.

---

## Qué hay aquí

| Carpeta | Qué es |
|---|---|
| **`data/`** | Una cohorte sintética reproducible (`cohorte.csv`, 400 pacientes) y el script que la crea. |
| **`01-esqueleto-minimo/`** | El agente más pequeño que corre: loop + alma (plantilla) + 1 tool de ejemplo. Para entender las piezas. |
| **`02-esqueleto-completo/`** | El mismo agente, ya lleno: habla con tus datos, hace una Tabla 1 con `gtsummary` y ajusta una regresión logística. |
| **`03-claude-code/`** | El MISMO agente, pero corriendo en Claude Code CLI. Para comparar local vs. nube. |
| **`docs/tutorial.html`** | Tutorial paso a paso: instalar Ollama, correr modelos locales, y usar todo esto. **Ábrelo en tu navegador.** |

---

## Arranque rápido (modelo local, gratis y privado)

**1. Instala las piezas** (detalle en `docs/tutorial.html`):
- [R](https://cran.r-project.org/) y, si quieres, [RStudio](https://posit.co/download/rstudio-desktop/).
- El paquete `ellmer`:  `install.packages("ellmer")`
- [Ollama](https://ollama.com/download) (para correr modelos locales).

**2. Descarga un modelo local:**
```bash
ollama pull qwen2.5:3b     # ligero y rápido, corre en casi cualquier laptop
```

**3. Corre el agente:**
```r
# dentro de R / RStudio, en la carpeta 02-esqueleto-completo
source("agente.R")
preguntar("Hazme la tabla 1 comparando por tratamiento, con valores p")
preguntar("¿Qué variables se asocian con mayor mortalidad?")
```

Eso es todo. El agente carga los datos, llama a tus funciones de R, y te
interpreta el resultado.

---

## El dataset (y la "respuesta correcta")

`data/cohorte.csv` es **sintético y reproducible** (semilla fija). Tiene asociaciones
incrustadas a propósito, para que el agente "descubra" lo que ya sabemos que es verdad:

- **Comorbilidades** → mayor mortalidad (OR ≈ 3.8)
- **Tratamiento 1** → menor mortalidad (OR ≈ 0.26)
- **Tratamiento 2** → mayor mortalidad (OR ≈ 2.0)
- **Edad** → mayor mortalidad (OR ≈ 1.05 por año)
- **Sexo** → sin efecto real

Para regenerarlo:  `cd data && Rscript generar_datos.R`

---

## Modelos locales (elige según tu laptop)

| Modelo | Tamaño | Para qué |
|---|---|---|
| `qwen2.5:3b` | ~2 GB | **Default.** Rápido, buen tool calling, casi cualquier PC. |
| `qwen3:4b` | ~2.6 GB | Razona mejor, un poco más lento. |
| `gpt-oss:20b` | ~13 GB | El más capaz. Necesita ~16 GB de RAM. |

Cambia el modelo con una variable, sin tocar el código:
```bash
AGENTE_MODELO=qwen3:4b Rscript agente.R
```

---

## Personalizar tu propio agente

Pasar del esqueleto vacío (`01`) al que funciona (`02`) es **solo llenar dos archivos**:

- **`alma.md`** → quién es el agente y sus reglas (el *system prompt*).
- **`tools.R`** → las funciones de R que puede ejecutar (tus librerías, tu flujo).

El motor (`agente.R`) **no cambia**. Ese es el punto: una vez tienes el harness,
personalizar un agente es describir quién es y darle herramientas.

---

*Taller preparado por David Rebellón Sánchez.*
