# ============================================================================
# Pipeline principal — Classification non-supervisée de données mixtes
# ============================================================================
#
# Datasets disponibles :
#   "canadian"  → Canadian Weather (35 stations, 365 jours, 4 régions)
#   "tecator"   → Tecator (215 spectres NIR, 100 λ, 3 classes de gras)
#   "aemet"     → AEMET (73 stations espagnoles, 365 jours, 4 zones)
#   "growth"    → Growth (93 enfants, 31 âges, 2 classes M/F)
#
# Usage :
#   DATASET <- "tecator"   # choisir ici
#   source("src/main.R")
#
# Pipeline :
#   00. Préparation   → Y_brut (fonctionnel) + Z (vectoriel) + régions (vérité)
#   01. Lissage       → X̂_i(t) dans L²  (B-splines + GCV)
#   02. FPCA          → scores ξ_ik      (choix K par variance cumulée)
#   03. Distances     → D0, D1, Dp, Ds, Dw, DK
#   04. Clustering    → A, B, C + baselines + chaîne HFV (02b→03b) + DK reconstruit
#   05. Visualisation → figures dans figures/<dataset>/
#
# ============================================================================

# --- Choix du dataset (modifiable avant source) ---
if (!exists("DATASET")) DATASET <- "canadian"

cat(sprintf("=== Pipeline FDA — Données mixtes (%s) ===\n\n", DATASET))

# Reproductibilité
set.seed(42)

# --- Chargement des données (étape 00 spécifique au dataset) ---
preprocess_file <- switch(DATASET,
  "canadian" = "src/00_preprocess.R",
  "tecator"  = "src/00_preprocess_tecator.R",
  "aemet"    = "src/00_preprocess_aemet.R",
  "growth"   = "src/00_preprocess_growth.R",
  stop(sprintf("Dataset inconnu : '%s'. Choix : canadian, tecator, aemet, growth", DATASET))
)
source(preprocess_file)

# --- Pipeline générique (étapes 01-05) ---
source("src/01_lissage.R")
source("src/02_fpca.R")
source("src/03_distances.R")
source("src/04_clustering.R")
source("src/05_visualisation.R")
