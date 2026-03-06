# ============================================================================
# ÉTAPE 3 : CALCUL DES MATRICES DE DISTANCES
# ============================================================================
#
# Architecture à deux niveaux :
#
#   NIVEAU 1 — Distance fonctionnelle Dp(α) :
#     D0 : L² entre courbes       = √∫ [X_i(t) - X_j(t)]² dt   (niveau)
#     D1 : L² entre dérivées      = √∫ [X'_i(t) - X'_j(t)]² dt (forme)
#     Dp(α) = √[(1-α)·D0² + α·D1²]    α ∈ [0,1]
#
#   NIVEAU 2 — Combinaison fonctionnel + vectoriel :
#     Ds : euclidienne sur Z standardisé
#     Dw(α,ω) = √[ω·Dp(α)² + (1-ω)·Ds²]          (stratégie B)
#     DK(α)   = √[K(i,i)+K(j,j)-2K(i,j)]          (stratégie C)
#               avec Kf = exp(-Dp(α)² / 2σ²)
#
# ============================================================================

library(fda)

cat("\n--- Étape 03 : Calcul des distances ---\n")

if (!exists("scores_fpca")) source("src/02_fpca.R")

# Grille fine pour l'évaluation des intégrales (somme de Riemann)
grille_fine <- seq(rangeval[1], rangeval[2], length.out = 1000)
delta <- (rangeval[2] - rangeval[1]) / (length(grille_fine) - 1)

# ═══════════════════════════════════════════════════════════════════════════
# A. DISTANCES FONCTIONNELLES
# ═══════════════════════════════════════════════════════════════════════════

# ─── D0 : distance L² entre courbes ───
# Mesure la proximité globale des profils de température
cat("  Calcul de D0 (L² entre courbes)...\n")
eval_X <- eval.fd(grille_fine, X_hat)  # matrice 1000 x 35

D0 <- matrix(0, n, n)
for (i in 1:(n - 1)) {
  for (j in (i + 1):n) {
    d <- sqrt(sum((eval_X[, i] - eval_X[, j])^2) * delta)
    D0[i, j] <- d
    D0[j, i] <- d
  }
}
rownames(D0) <- colnames(D0) <- noms_stations

# ─── D1 : distance L² entre dérivées ───
# Capture les différences de dynamique (vitesse de changement de température)
cat("  Calcul de D1 (L² entre dérivées)...\n")
eval_dX <- eval.fd(grille_fine, X_hat, Lfdobj = 1)  # dérivées premières

D1 <- matrix(0, n, n)
for (i in 1:(n - 1)) {
  for (j in (i + 1):n) {
    d <- sqrt(sum((eval_dX[, i] - eval_dX[, j])^2) * delta)
    D1[i, j] <- d
    D1[j, i] <- d
  }
}
rownames(D1) <- colnames(D1) <- noms_stations

# ─── Dp(α) : distance fonctionnelle combinée ───
# Dp(α) = √[(1-α)·(D0/max(D0))² + α·(D1/max(D1))²]
# α = 0 : seul le niveau compte (= D0)
# α = 1 : seule la forme compte (= D1)
# On normalise D0 et D1 par leur max pour les mettre sur la même échelle.
cat("  Calcul de Dp (D0 + D1 combinées par α)...\n")

D0_norm <- D0 / max(D0)
D1_norm <- D1 / max(D1)

compute_Dp <- function(D0_norm, D1_norm, alpha) {
  sqrt((1 - alpha) * D0_norm^2 + alpha * D1_norm^2)
}

# Grille de α à explorer
alphas <- seq(0, 1, by = 0.1)

# ═══════════════════════════════════════════════════════════════════════════
# B. DISTANCE VECTORIELLE (sur Z)
# ═══════════════════════════════════════════════════════════════════════════

cat("  Calcul de Ds (euclidienne sur Z standardisé)...\n")
Z_scaled <- scale(Z)
Ds <- as.matrix(dist(Z_scaled))
rownames(Ds) <- colnames(Ds) <- noms_stations

# ═══════════════════════════════════════════════════════════════════════════
# C. DISTANCES MIXTES (fonctionnel + vectoriel)
# ═══════════════════════════════════════════════════════════════════════════

# ─── Dw(α, ω) : distance mixte pondérée (stratégie B) ───
# Dw = √[ω·Dp(α)² + (1-ω)·(Ds/max(Ds))²]
#   α contrôle le mix niveau/forme DANS le fonctionnel
#   ω contrôle le mix fonctionnel/vectoriel
# ω → 1 : tout le poids aux courbes
# ω → 0 : tout le poids aux variables Z
cat("  Calcul de Dw (distance mixte, 2 paramètres α et ω)...\n")

Ds_norm <- Ds / max(Ds)

compute_Dw <- function(Dp, Ds_norm, omega) {
  sqrt(omega * Dp^2 + (1 - omega) * Ds_norm^2)
}

# Grilles pour le grid search 2D
omegas <- seq(0, 1, by = 0.1)

# ─── DK(α) : distance à noyaux (stratégie C, Ferreira & de Carvalho 2014) ───
# K = Kf · Ks (noyau produit)
# Kf = exp(-Dp(α)² / (2σf²))   noyau gaussien sur Dp (pas D0 brut !)
# Ks = exp(-Ds² / (2σs²))       noyau gaussien sur Z
# DK(i,j) = √[K(i,i) + K(j,j) - 2K(i,j)]
#
# On cherche le meilleur α par grid search au clustering (étape 04).
cat("  Calcul de DK (distance à noyaux, paramétré par α)...\n")

sigma_s <- median(Ds[Ds > 0])
Ks <- exp(-Ds^2 / (2 * sigma_s^2))

compute_DK <- function(Dp, Ks, sigma_f = NULL) {
  if (is.null(sigma_f)) sigma_f <- median(Dp[Dp > 0])
  Kf <- exp(-Dp^2 / (2 * sigma_f^2))
  K_prod <- Kf * Ks
  n <- nrow(K_prod)
  DK <- matrix(0, n, n)
  for (i in 1:(n - 1)) {
    for (j in (i + 1):n) {
      val <- K_prod[i, i] + K_prod[j, j] - 2 * K_prod[i, j]
      DK[i, j] <- sqrt(max(val, 0))
      DK[j, i] <- DK[i, j]
    }
  }
  rownames(DK) <- colnames(DK) <- rownames(Dp)
  return(list(DK = DK, K = K_prod, sigma_f = sigma_f))
}

# ─── Résumé ───
cat(sprintf("  D0  : rang [%.1f, %.1f]\n", min(D0[D0 > 0]), max(D0)))
cat(sprintf("  D1  : rang [%.2f, %.2f]\n", min(D1[D1 > 0]), max(D1)))
cat(sprintf("  Ds  : rang [%.2f, %.2f]\n", min(Ds[Ds > 0]), max(Ds)))
cat("  -> Distances prêtes (Dp, Dw, DK paramétrés par α et ω).\n")
cat("  -> Prêt pour le clustering (étape 04).\n")