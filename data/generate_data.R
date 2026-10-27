# ============================================================
# generate_data.R
# ------------------------------------------------------------
# Creates a SYNTHETIC, reproducible cohort for the workshop.
#
# The associations are baked in ON PURPOSE (fixed seed), so that
# when the agent analyses the data it "discovers" what we already
# know to be true:
#   - Having comorbidities  -> HIGHER mortality
#   - Treatment 1 (trt1)    -> LOWER mortality (vs control)
#   - Treatment 2 (trt2)    -> HIGHER mortality (vs control)
#   - Older age             -> HIGHER mortality
# Everything else (sex) has no real effect.
#
# Usage:  Rscript generate_data.R
# Output: cohort.csv  (in this same folder)
# ============================================================

set.seed(2026)                 # <- reproducible: always the same dataset
n <- 400

# ---- Predictor variables -----------------------------------
age <- round(pmin(pmax(rnorm(n, mean = 62, sd = 14), 18), 95))
sex <- factor(sample(c("F", "M"), n, replace = TRUE))
treatment <- factor(
  sample(c("control", "trt1", "trt2"), n, replace = TRUE),
  levels = c("control", "trt1", "trt2")   # control = reference
)
comorbidities <- factor(
  sample(c("no", "yes"), n, replace = TRUE, prob = c(0.6, 0.4)),
  levels = c("no", "yes")
)

# ---- Outcome-generating model (logistic regression) --------
# log-odds of dying = b0 + true effects
b0        <- -1.6                                   # intercept (sets ~25-30% mortality)
b_age     <-  0.045 * (age - 62)                    # age: +risk
b_comorb  <-  1.05  * (comorbidities == "yes")       # comorbidities: +risk
b_trt1    <- -0.95  * (treatment == "trt1")          # trt1: -risk
b_trt2    <-  0.85  * (treatment == "trt2")          # trt2: +risk

logit_p <- b0 + b_age + b_comorb + b_trt1 + b_trt2
p <- 1 / (1 + exp(-logit_p))
died <- rbinom(n, size = 1, prob = p)                # 1 = died, 0 = alive

# ---- Assemble and save -------------------------------------
cohort <- data.frame(
  id = seq_len(n),
  age = age,
  sex = sex,
  treatment = treatment,
  comorbidities = comorbidities,
  died = died
)

out <- "cohort.csv"   # written to the current directory (run from the data/ folder)
write.csv(cohort, out, row.names = FALSE)

cat("Dataset generated:", out, "\n")
cat("Rows:", nrow(cohort), "| Overall mortality:",
    round(100 * mean(cohort$died), 1), "%\n\n")

# ---- Quick check (printed on generation) -------------------
cat("Check of the baked-in associations (OR):\n")
m <- glm(died ~ age + sex + treatment + comorbidities,
         data = cohort, family = binomial)
print(round(exp(cbind(OR = coef(m), confint.default(m))), 2))
