# 03 - El mismo agente en Claude Code CLI

Aqui el agente **Rho** corre dentro de **Claude Code** (el CLI de Anthropic),
no en el harness casero. Mismo concepto, pero el loop, las tools y un modelo
mucho mas capaz vienen "de fabrica".

```
CLAUDE.md                         <- el "alma" (system prompt del proyecto)
.claude/skills/crear-tabla/       <- una "skill" = una tool documentada
data/cohorte.csv                  <- los mismos datos
```

## Mapeo con el harness casero

| Harness (01-02)        | Claude Code (03)                         |
|------------------------|------------------------------------------|
| `alma.md`              | `CLAUDE.md`                              |
| `tools.R`              | `.claude/skills/` + Bash/Read/Write nativas |
| `agente.R` (el loop)   | lo trae Claude Code                      |
| modelo local           | Claude (nube)                            |

## Correr

Requisitos: [Claude Code](https://claude.com/claude-code) instalado y con sesion
iniciada, y R disponible.

```bash
cd 03-claude-code
claude
```

Y pidele, por ejemplo:
- "Hazme la tabla 1 comparando por tratamiento, con valores p."
- "Que variables se asocian con mayor mortalidad? Ajusta una regresion logistica."

Claude Code leera `CLAUDE.md`, usara la skill `crear-tabla`, escribira un script
R reproducible en `R/`, lo correra y te mostrara (e interpretara) el resultado.

## Por que se siente mas potente
Claude lee tu repo, escribe y ejecuta codigo, se corrige solo si algo falla, y
encadena varios pasos sin que tengas que programar el loop. Eso es lo que, con
mucho mas esfuerzo, replicamos en pequeno con el harness local de las carpetas 01-02.
