# ============================================================================
# ÉTAPE 0 : PRÉPARATION — TECATOR (spectrométrie de viande)
# ============================================================================
#
# 215 échantillons de viande hachée
#   - X(λ) : spectre d'absorbance NIR (100 longueurs d'onde, 850-1050 nm)
#   - Z    : (Water, Protein) — 2 variables vectorielles
#   - Vérité terrain : 3 classes basées sur Fat (gras < 15, 15-30, > 30)
#
# INTÉRÊT : les DÉRIVÉES des spectres sont très informatives en chimiométrie.
#   → α > 0 devrait être optimal (contrairement à Canadian Weather).
# ============================================================================

library(fda.usc)

cat("\n--- Étape 00 : Préparation des données (TECATOR) ---\n")

# --- 1. Chargement ---
data("tecator")

# --- 2. Données fonctionnelles : spectres d'absorbance ---
# Matrice 100 x 215 (points × individus) pour rester cohérent avec le pipeline
Y_brut <- t(tecator$absorp$data)  # transposer : 100 lignes (λ) x 215 colonnes (ind.)
t_jours <- tecator$absorp$argvals  # longueurs d'onde (850, 852, ..., 1050)
n <- ncol(Y_brut)      # 215 individus
N <- nrow(Y_brut)      # 100 points de mesure

# --- 3. Données vectorielles Z_i ---
# On utilise Water et Protein (pas Fat, car Fat sert à construire les classes)
Z <- data.frame(
  water   = tecator$y$Water,
  protein = tecator$y$Protein
)
rownames(Z) <- paste0("meat_", 1:n)

# --- 4. Vérité terrain ---
# 3 classes basées sur le contenu en graisse
fat <- tecator$y$Fat
classes_fat <- cut(fat, breaks = c(-Inf, 15, 30, Inf),
                   labels = c("Maigre", "Moyen", "Gras"))
regions <- factor(classes_fat)
noms_stations <- rownames(Z)

# --- 5. Métadonnées pour le pipeline générique ---
dataset_name <- "tecator"
rangeval <- range(t_jours)  # c(850, 1050)
nbasis_choix <- 30          # 100 points → 30 bases suffisent
xlab_courbe <- "Longueur d'onde (nm)"
ylab_courbe <- "Absorbance"

# --- Résumé ---
cat(sprintf("  Dataset : %s\n", dataset_name))
cat(sprintf("  %d échantillons, %d longueurs d'onde [%d-%d nm]\n",
            n, N, rangeval[1], rangeval[2]))
cat(sprintf("  Variables vectorielles Z : %s\n", paste(names(Z), collapse = ", ")))
cat(sprintf("  Classes (vérité terrain) : %s\n",
            paste(names(table(regions)), sprintf("(%d)", table(regions)), collapse = ", ")))
cat("  -> Prêt pour le lissage (étape 01).\n")
