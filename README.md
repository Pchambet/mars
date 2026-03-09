# Classification non-supervisée de données mixtes — Application en océanographie

> **Auteur** : Pierre  
> **Stage** : Mars 2026

## Objectif

Comparer trois stratégies de clustering pour des données mixtes (fonctionnelles + vectorielles) :

- **Stratégie A** : FPCA → scores + variables Z → k-means
- **Stratégie B** : Distance pondérée Dω (fonctionnel + vectoriel) → PAM
- **Stratégie C** : Distance à noyaux DK → PAM

## Structure

```
src/
├── 00_preprocess.R         Canadian Weather
├── 00_preprocess_aemet.R   AEMET (73 stations espagnoles)
├── 00_preprocess_growth.R  Growth (93 enfants, M/F)
├── 00_preprocess_tecator.R Tecator (215 spectres NIR)
├── 01_lissage.R            Lissage B-splines pénalisées + GCV
├── 02_fpca.R               ACP fonctionnelle (K par variance cumulée ≥ 95%)
├── 03_distances.R          D0, D1, Dp, Ds, Dw, DK (opérations matricielles)
├── 04_clustering.R         3 stratégies + baselines, ARI + silhouette
├── 05_visualisation.R      8 figures dans figures/<dataset>/
└── main.R                  Pipeline complet

docs/
├── resume_donnees_fonctionnelles.tex  Théorie FDA, FPCA, clustering
├── rapport_distances.tex             Architecture des distances
├── rapport_canadian_weather.tex      Pipeline + diagnostic complet
└── rapport_synthese.tex              Résultats multi-dataset, perspectives

data/
└── shom_celerite_2018.csv  Données SHOM (à télécharger, non versionnées)

figures/
├── canadian_weather/      8 figures
├── aemet/                 8 figures
├── growth/                8 figures
└── tecator/               8 figures

experiments/               Perspectives de recherche (rapport § 8)
├── 01_stabilite/         Sélection par stabilité
├── 02_vote_criteres/      Vote entre critères
├── 03_optimisation_bayesienne/
├── 04_meta_calibration/
├── 05_derivees_D2/        Dérivées d'ordre supérieur
├── 06_consensus_clustering/
├── 07_application_non_labelisees/
└── README.md              Inventaire et conventions
```

## Démarrage rapide

### 1. Vérifier l'environnement

```r
source("setup.R")
```

Installe les packages manquants et affiche les versions pour la reproductibilité.

### 2. Lancer le pipeline (Canadian Weather)

```r
source("src/main.R")
```

Génère 8 figures dans `figures/canadian_weather/` et affiche le tableau comparatif.

### 3. Changer de dataset

```r
DATASET <- "aemet"   # ou "growth", "tecator", "canadian"
source("src/main.R")
```

## Documentation

- **Théorie** : `docs/resume_donnees_fonctionnelles.pdf` — données fonctionnelles, lissage, FPCA
- **Architecture** : `docs/rapport_distances.pdf` — toutes les distances, définitions, propriétés
- **Résultats** : `docs/rapport_canadian_weather.pdf` — pipeline complet + diagnostic
- **Synthèse** : `docs/rapport_synthese.pdf` — résultats multi-dataset, perspectives

### Compilation des rapports LaTeX

Depuis le dossier `docs/` :

```bash
cd docs && make
```

Ou manuellement : `pdflatex rapport_synthese.tex` (deux fois si références croisées).

### Reproductibilité

Exécuter `source("setup.R")` avant le pipeline pour afficher les versions de R et des packages. Le script enregistre automatiquement `sessionInfo()` dans `docs/session_info.txt` pour traçabilité.
