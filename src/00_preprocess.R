# ============================================================================
# ÉTAPE 0 : PRÉPARATION DES DONNÉES
# ============================================================================
#
# Données d'entraînement : Canadian Weather (35 stations, 365 jours)
#
# On prépare les DEUX types de données du problème mixte :
#   - Y_brut  : matrice (365 x 35) des températures discrètes → FONCTIONNEL
#   - Z       : matrice (35 x 3) latitude, longitude, précip  → VECTORIEL
#   - regions : vérité terrain (4 régions) pour évaluer le clustering (ARI)
#
# RAPPEL THÉORIQUE : en pratique on observe Y_ij = X_i(t_j) + ε_ij
# Le passage de Y_ij à X̂_i(t) se fait à l'étape 01 (lissage).
# ============================================================================

library(fda)

cat("\n--- Étape 00 : Préparation des données ---\n")

# --- 1. Chargement ---
data("CanadianWeather")

# --- 2. Données fonctionnelles : températures discrètes Y_ij ---
# Matrice 365 x 35 : chaque colonne = une station, chaque ligne = un jour
Y_brut <- CanadianWeather$dailyAv[, , "Temperature.C"]
t_jours <- 1:365
n <- ncol(Y_brut)      # 35 individus
N <- nrow(Y_brut)      # 365 points de mesure

# --- 3. Données vectorielles Z_i ---
# Pour chaque station, on a des variables numériques classiques.
# C'est la partie "vectorielle" du problème mixte.
Z <- data.frame(
  latitude  = CanadianWeather$coordinates[, "N.latitude"],
  longitude = CanadianWeather$coordinates[, "W.longitude"],
  precip    = colMeans(CanadianWeather$dailyAv[, , "Precipitation.mm"])
)
rownames(Z) <- CanadianWeather$place

# --- 4. Vérité terrain ---
# Les 4 régions climatiques servent de référence pour évaluer le clustering.
regions <- factor(CanadianWeather$region)
noms_stations <- CanadianWeather$place

# --- 5. Métadonnées pour le pipeline générique ---
dataset_name <- "canadian_weather"
rangeval <- c(1, 365)
xlab_courbe <- "Jour de l'année"
ylab_courbe <- "Température (°C)"

# --- Résumé ---
cat(sprintf("  Dataset : %s\n", dataset_name))
cat(sprintf("  %d individus, %d points de mesure\n", n, N))
cat(sprintf("  Variables vectorielles Z : %s\n", paste(names(Z), collapse = ", ")))
cat(sprintf("  Classes (vérité terrain) : %s\n",
            paste(names(table(regions)), sprintf("(%d)", table(regions)), collapse = ", ")))
cat("  -> Prêt pour le lissage (étape 01).\n")
