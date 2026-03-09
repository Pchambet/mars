# ============================================================================
# ÉTAPE 0 : PRÉPARATION — GROWTH (croissance Berkeley)
# ============================================================================
#
# 93 enfants (39 garçons + 54 filles)
#   - X(t) : courbes de taille (cm) de 1 à 18 ans, 31 points de mesure
#   - Z    : (taille_finale, vitesse_pic) — variables scalaires dérivées
#   - Vérité terrain : 2 classes (garçons / filles)
#
# INTÉRÊT : La VITESSE de croissance (dérivée) distingue filles/garçons
#   (pic de croissance pubertaire plus tôt chez les filles).
#   → D1 (dérivées) devrait être très discriminante → α > 0 optimal.
# ============================================================================

library(fda)

cat("\n--- Étape 00 : Préparation des données (GROWTH) ---\n")

# --- 1. Chargement ---
data("growth")

# --- 2. Données fonctionnelles : courbes de taille ---
# Combiner garçons et filles en une seule matrice 31 x 93
Y_brut <- cbind(growth$hgtm, growth$hgtf)  # 31 x 93
t_jours <- growth$age                       # 31 âges de mesure
n <- ncol(Y_brut)      # 93 individus
N <- nrow(Y_brut)      # 31 points de mesure

# --- 3. Données vectorielles Z_i ---
# Taille finale (à 18 ans) et vitesse de croissance moyenne
taille_finale <- Y_brut[N, ]  # dernière mesure

# Vitesse de croissance approximée (croissance totale / durée)
croiss_totale <- Y_brut[N, ] - Y_brut[1, ]

Z <- data.frame(
  taille_finale = taille_finale,
  croissance_totale = croiss_totale
)
noms <- c(paste0("boy_", 1:39), paste0("girl_", 1:54))
rownames(Z) <- noms

# --- 4. Vérité terrain ---
regions <- factor(c(rep("Garcon", 39), rep("Fille", 54)))
noms_stations <- noms

# --- 5. Métadonnées pour le pipeline générique ---
dataset_name <- "growth"
rangeval <- range(t_jours)  # c(1, 18)
xlab_courbe <- "Âge (années)"
ylab_courbe <- "Taille (cm)"

# --- Résumé ---
cat(sprintf("  Dataset : %s\n", dataset_name))
cat(sprintf("  %d enfants, %d points de mesure [%.0f-%.0f ans]\n",
            n, N, rangeval[1], rangeval[2]))
cat(sprintf("  Variables vectorielles Z : %s\n", paste(names(Z), collapse = ", ")))
cat(sprintf("  Classes (vérité terrain) : %s\n",
            paste(names(table(regions)), sprintf("(%d)", table(regions)), collapse = ", ")))
cat("  -> Prêt pour le lissage (étape 01).\n")
