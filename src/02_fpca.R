# ============================================================================
# ÉTAPE 2 : ACP FONCTIONNELLE (FPCA)
# ============================================================================
#
# THÉORIE : Analogue de l'ACP classique, mais dans L²(T) au lieu de Rᵖ.
#
#   1. Moyenne fonctionnelle : μ(t) = (1/n) Σ_i X_i(t)
#   2. Surface de covariance : C(s,t) = (1/n) Σ_i [X_i(s)-μ(s)][X_i(t)-μ(t)]
#   3. Équation aux fonctions propres : ∫ C(s,t) φ_k(s) ds = λ_k φ_k(t)
#   4. Scores : ξ_ik = ∫ [X_i(t) - μ(t)] φ_k(t) dt
#
# RÉSULTAT : chaque individu passe de "courbe dans L²" à un vecteur de K scores.
# Ces scores serviront au clustering (stratégie A = FPCA + concaténation avec Z).
# ============================================================================

library(fda)

cat("\n--- Étape 02 : ACP fonctionnelle (FPCA) ---\n")

if (!exists("X_hat")) source("src/01_lissage.R")

# ─── 1. Moyenne et covariance fonctionnelles ───
mu_t <- mean.fd(X_hat)
cov_st <- var.fd(X_hat)

# ─── 2. FPCA : résolution de l'équation aux fonctions propres ───
# On demande nharm composantes (on prend le max raisonnable, on choisira K après)
nharm_max <- min(n - 1, 10)
res_pca <- pca.fd(fdobj = X_hat, nharm = nharm_max)

# ─── 3. Choix de K par variance expliquée cumulée ───
# Critère : on garde les K premières composantes qui expliquent ≥ seuil de variance.
seuil_variance <- 0.95
var_expliquee <- res_pca$varprop
var_cumulee <- cumsum(var_expliquee)
K <- which(var_cumulee >= seuil_variance)[1]

cat("  Variance expliquée par composante :\n")
for (k in 1:nharm_max) {
  barre <- paste(rep("█", round(var_expliquee[k] * 50)), collapse = "")
  cat(sprintf("    PC%d : %5.1f%%  %s  (cum: %5.1f%%)\n",
              k, var_expliquee[k] * 100, barre, var_cumulee[k] * 100))
}
cat(sprintf("  -> K = %d composantes retenues (seuil = %.0f%%)\n", K, seuil_variance * 100))

# ─── 4. Extraction des résultats ───
# Fonctions propres φ_k(t) — les "modes de variation"
phi_k <- res_pca$harmonics

# Scores ξ_ik — le résumé vectoriel de chaque courbe
# On ne garde que les K premières colonnes
scores_fpca <- res_pca$scores[, 1:K, drop = FALSE]
colnames(scores_fpca) <- paste0("PC", 1:K)
rownames(scores_fpca) <- noms_stations

# Valeurs propres (variance)
valeurs_propres <- res_pca$values[1:K]

cat(sprintf("  Dimension réduite : %d individus × %d scores\n", nrow(scores_fpca), K))
cat("  -> Prêt pour les distances (étape 03).\n")
