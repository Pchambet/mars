# ============================================================================
# ÉTAPE 0 : PRÉPARATION — AEMET (météo espagnole)
# ============================================================================
#
# 73 stations météo espagnoles (moyennes 1980-2009)
#   - X(t) : courbes de température moyenne journalière (365 jours)
#   - Z    : (altitude, latitude, longitude) — 3 variables vectorielles
#   - Vérité terrain : 4 zones climatiques construites à partir de la géographie
#     (Atlantique Nord, Méditerranée, Continental intérieur, Sud/Subtropical)
#
# INTÉRÊT : L'altitude affecte le NIVEAU ET la FORME des températures.
#   Les stations côtières vs intérieures ont des dynamiques très différentes
#   (amplitude saisonnière), ce qui devrait rendre D1 (dérivées) informative.
# ============================================================================

library(fda.usc)

cat("\n--- Étape 00 : Préparation des données (AEMET) ---\n")

# --- 1. Chargement ---
data("aemet")

# --- 2. Données fonctionnelles : températures journalières ---
Y_brut <- t(aemet$temp$data)  # 365 x 73
t_jours <- aemet$temp$argvals  # 0.5, 1.5, ..., 364.5
n <- ncol(Y_brut)      # 73 stations
N <- nrow(Y_brut)      # 365 jours

# --- 3. Données vectorielles Z_i ---
Z <- data.frame(
  altitude  = aemet$df$altitude,
  latitude  = aemet$df$latitude,
  longitude = aemet$df$longitude
)
rownames(Z) <- aemet$df$name

# --- 4. Vérité terrain ---
# On construit 4 zones climatiques à partir de la géographie espagnole :
#   - Atlantique : nord, lat > 42.5
#   - Méditerranée : est, lon > -2 ET lat < 42
#   - Continental : centre, lon ∈ [-5, -1] ET lat ∈ [38, 42]
#   - Sud : lat < 38
lat <- Z$latitude
lon <- Z$longitude

zone <- rep("Continental", n)
zone[lat > 42.5] <- "Atlantique"
zone[lon > -2 & lat < 42] <- "Mediterranee"
zone[lat < 38] <- "Sud"

regions <- factor(zone)
noms_stations <- aemet$df$name

# --- 5. Métadonnées pour le pipeline générique ---
dataset_name <- "aemet"
rangeval <- range(t_jours)
nbasis_choix <- 65
xlab_courbe <- "Jour de l'année"
ylab_courbe <- "Température (°C)"

# --- Résumé ---
cat(sprintf("  Dataset : %s\n", dataset_name))
cat(sprintf("  %d stations, %d jours de mesure\n", n, N))
cat(sprintf("  Variables vectorielles Z : %s\n", paste(names(Z), collapse = ", ")))
cat(sprintf("  Classes (vérité terrain) : %s\n",
            paste(names(table(regions)), sprintf("(%d)", table(regions)), collapse = ", ")))
cat("  -> Prêt pour le lissage (étape 01).\n")
