# ============================================================================
# ÉTAPE 1 : LISSAGE — Du discret Y_ij au fonctionnel X̂_i(t)
# ============================================================================
#
# THÉORIE : On cherche X̂_i(t) = Σ_k θ̂_ik · ψ_k(t) qui minimise :
#   Σ_j (Y_ij - X̂_i(t_j))² + λ ∫ [X̂_i''(t)]² dt
#
# Le premier terme = fidélité aux données
# Le second terme  = pénalité de régularité (pas trop de zigzags)
# λ contrôle le compromis : petit = suit le bruit, grand = trop lisse
#
# CHOIX DE λ : Validation Croisée Généralisée (GCV)
# CHOIX DE LA BASE : B-splines d'ordre 4 (cubiques), nbasis "large" (65)
#   → On met beaucoup de bases et on laisse λ contrôler la régularité
# ============================================================================

library(fda)

cat("\n--- Étape 01 : Lissage B-splines pénalisées ---\n")

if (!exists("Y_brut")) {
  if (!exists("DATASET")) DATASET <- "canadian"
  preprocess_file <- switch(DATASET,
    "canadian" = "src/00_preprocess.R",
    "tecator"  = "src/00_preprocess_tecator.R",
    "growth"   = "src/00_preprocess_growth.R",
    "src/00_preprocess.R"
  )
  source(preprocess_file)
}

# ─── 1. Définition de la base B-spline ───
# Formule équitable pour tous les datasets : nbasis = min(65, max(15, N %/% 3))
# La base a la CAPACITÉ de faire des zigzags, mais λ (GCV) contrôle la régularité.
if (!exists("rangeval")) rangeval <- c(1, N)
nbasis_choix <- min(65, max(15, N %/% 3))
nbasis <- nbasis_choix
base_bspline <- create.bspline.basis(rangeval = rangeval, nbasis = nbasis, norder = 4)

# ─── 2. Recherche de λ optimal par GCV ───
# Grille large [-4, 8] pour couvrir courbes peu/moyennement lissées (growth, tecator)
# jusqu'aux très lissées (météo). Longueur identique pour tous les datasets.
log_lambdas <- seq(-4, 8, length.out = 80)
lambdas_grille <- 10^log_lambdas
gcv_scores <- numeric(length(lambdas_grille))

cat("  Recherche de λ par GCV sur", length(lambdas_grille), "valeurs...\n")
for (i in seq_along(lambdas_grille)) {
  fdPar_test <- fdPar(fdobj = base_bspline, Lfdobj = 2, lambda = lambdas_grille[i])
  smooth_test <- smooth.basis(argvals = t_jours, y = Y_brut, fdParobj = fdPar_test)
  gcv_scores[i] <- sum(smooth_test$gcv)
}

idx_opt <- which.min(gcv_scores)
lambda_gcv <- lambdas_grille[idx_opt]
cat(sprintf("  λ_GCV = %.2f (log10 = %.1f)\n", lambda_gcv, log10(lambda_gcv)))

# ─── 3. Diagnostic : le GCV est-il fiable ? ───
# Pour des données très autocorrélées (météo), le GCV peut sous-estimer λ.
# On affiche un avertissement si le minimum est au bord de la grille.
if (idx_opt <= 2 || idx_opt >= length(lambdas_grille) - 1) {
  cat("  ⚠ ATTENTION : minimum GCV au bord de la grille ! Élargir la recherche.\n")
}

# On utilise le λ GCV. Si dans un contexte particulier il faut forcer un λ
# plus grand (ex: données très autocorrélées), on le fait explicitement ici :
lambda_opt <- lambda_gcv
# lambda_opt <- 1e4  # décommenter pour forcer (ex: saisonnalité pure)
cat(sprintf("  λ retenu = %.2f\n", lambda_opt))

# ─── 4. Lissage définitif ───
fdPar_opt <- fdPar(fdobj = base_bspline, Lfdobj = 2, lambda = lambda_opt)
smooth_result <- smooth.basis(argvals = t_jours, y = Y_brut, fdParobj = fdPar_opt)
X_hat <- smooth_result$fd   # objet fd : les n courbes lissées

cat(sprintf("  Résultat : %d courbes fonctionnelles dans L²([%.0f,%.0f])\n",
            ncol(X_hat$coefs), rangeval[1], rangeval[2]))

# ─── 5. Sauvegarde des objets pour les étapes suivantes ───
# On garde aussi les paramètres pour la traçabilité
lissage_params <- list(
  nbasis     = nbasis,
  norder     = 4,
  lambda_gcv = lambda_gcv,
  lambda_opt = lambda_opt,
  gcv_scores = gcv_scores,
  lambdas_grille = lambdas_grille
)

cat("  -> Prêt pour la FPCA (étape 02).\n")
