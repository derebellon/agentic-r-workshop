# ============================================================
# generar_datos.R
# ------------------------------------------------------------
# Crea una cohorte SINTETICA y reproducible para el taller.
#
# Las asociaciones estan INCRUSTADAS a proposito (semilla fija),
# asi el agente, al analizar, "descubre" lo que ya sabemos que
# es verdad:
#   - Tener comorbilidades  -> MAYOR mortalidad
#   - Tratamiento 1 (trt1)  -> MENOR mortalidad (vs control)
#   - Tratamiento 2 (trt2)  -> MAYOR mortalidad (vs control)
#   - Mayor edad            -> MAYOR mortalidad
# El resto (sexo) no tiene efecto real.
#
# Uso:  Rscript generar_datos.R
# Salida: cohorte.csv  (en esta misma carpeta)
# ============================================================

set.seed(2026)                 # <- reproducible: siempre el mismo dataset
n <- 400

# ---- Variables predictoras ---------------------------------
edad <- round(pmin(pmax(rnorm(n, mean = 62, sd = 14), 18), 95))
sexo <- factor(sample(c("F", "M"), n, replace = TRUE))
tratamiento <- factor(
  sample(c("control", "trt1", "trt2"), n, replace = TRUE),
  levels = c("control", "trt1", "trt2")   # control = referencia
)
comorbilidades <- factor(
  sample(c("no", "si"), n, replace = TRUE, prob = c(0.6, 0.4)),
  levels = c("no", "si")
)

# ---- Modelo generador del desenlace (regresion logistica) --
# log-odds de fallecer = b0 + efectos verdaderos
b0        <- -1.6                                   # intercepto (fija ~25-30% mortalidad)
b_edad    <-  0.045 * (edad - 62)                   # edad: +riesgo
b_comorb  <-  1.05  * (comorbilidades == "si")       # comorbilidades: +riesgo
b_trt1    <- -0.95  * (tratamiento == "trt1")        # trt1: -riesgo
b_trt2    <-  0.85  * (tratamiento == "trt2")        # trt2: +riesgo

logit_p <- b0 + b_edad + b_comorb + b_trt1 + b_trt2
p <- 1 / (1 + exp(-logit_p))
fallecido <- rbinom(n, size = 1, prob = p)           # 1 = fallecio, 0 = vivo

# ---- Ensamblar y guardar -----------------------------------
cohorte <- data.frame(
  id = seq_len(n),
  edad = edad,
  sexo = sexo,
  tratamiento = tratamiento,
  comorbilidades = comorbilidades,
  fallecido = fallecido
)

out <- "cohorte.csv"   # se escribe en el directorio actual (corre desde la carpeta data/)
write.csv(cohorte, out, row.names = FALSE)

cat("Dataset generado:", out, "\n")
cat("Filas:", nrow(cohorte), "| Mortalidad global:",
    round(100 * mean(cohorte$fallecido), 1), "%\n\n")

# ---- Verificacion rapida (se ve al generar) ----------------
cat("Comprobacion de las asociaciones incrustadas (OR):\n")
m <- glm(fallecido ~ edad + sexo + tratamiento + comorbilidades,
         data = cohorte, family = binomial)
print(round(exp(cbind(OR = coef(m), confint.default(m))), 2))
