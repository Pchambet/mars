# ============================================================================
# Expérience 01 — nselectboot sur les 3 datasets réels
# ============================================================================
#
# Usage : source("experiments/01_instabilite/run_all_nselectboot.R")
#
# Volet simulé (aligné exp. 3) : après les 3 jeux réels, optionnel (coûteux).
#   RUN_NSELECTBOOT_SIMULATED <- TRUE   # avant source, pour enrichir l’exp. 1
#
# ============================================================================

if (!exists("RUN_NSELECTBOOT_SIMULATED")) RUN_NSELECTBOOT_SIMULATED <- FALSE

cat("\n")
cat("══════════════════════════════════════════════════════════════════════\n")
cat("  EXPÉRIENCE 01 — NSELECTBOOT (Fang-Wang) sur 3 datasets réels\n")
cat("══════════════════════════════════════════════════════════════════════\n\n")

# Grille 21×21, B=150 — référence unique pour les 3 jeux réels ET le volet simulé
DATASETS <- c("canadian", "growth", "tecator")
B_NSELECT <- 150L
ALPHAS_NB <- seq(0, 1, by = 0.05)
OMEGAS_NB <- seq(0, 1, by = 0.05)
K_RANGE <- 2:6

cat(sprintf("  B = %d, k ∈ {%s}\n", B_NSELECT, paste(K_RANGE, collapse = ",")))
cat(sprintf("  Grille (α, ω) : pas 0.05, 21×21 (même précision pour le simulé)\n\n"))

set.seed(42)

for (d in DATASETS) {
  DATASET <- d
  source("experiments/01_instabilite/run_nselectboot.R", local = FALSE)
}

if (RUN_NSELECTBOOT_SIMULATED) {
  cat("\n")
  cat(">>> Volet enrichi : données simulées (même B, même grille 21×21 que ci-dessus)\n")
  # Verrou explicite : le simulé doit utiliser exactement les mêmes paramètres nselectboot
  B_NSELECT <- 150L
  ALPHAS_NB <- seq(0, 1, by = 0.05)
  OMEGAS_NB <- seq(0, 1, by = 0.05)
  K_RANGE <- 2:6
  source("experiments/01_instabilite/run_nselectboot_simulated.R", local = FALSE)
} else {
  cat("\n  (Volet simulé non lancé — définir RUN_NSELECTBOOT_SIMULATED <- TRUE pour l’activer.)\n")
}

cat("\n══════════════════════════════════════════════════════════════════════\n")
cat("  nselectboot terminé.\n")
cat("  Jeux réels : experiments/01_instabilite/results/\n")
cat("  Simulé     : experiments/01_instabilite/results_simulated/\n")
cat("══════════════════════════════════════════════════════════════════════\n\n")
