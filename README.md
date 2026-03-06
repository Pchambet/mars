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
├── 00_preprocess.R      Chargement et séparation X (fonctionnel) / Z (vectoriel)
├── 01_lissage.R         Lissage B-splines pénalisées + GCV
├── 02_fpca.R            ACP fonctionnelle (choix K par variance cumulative ≥ 95%)
├── 03_distances.R       D0, D1, Dp, Ds, Dw, DK
├── 04_clustering.R      3 stratégies + baselines, évaluation ARI + silhouette
├── 05_visualisation.R   7 figures dans figures/
└── main.R               Pipeline complet

docs/
├── resume_donnees_fonctionnelles.tex   Résumé théorique (FDA, FPCA, clustering)
└── guide_canadian_weather.md           Guide explicatif du pipeline

data/
└── shom_celerite_2018.csv              Données SHOM (pour plus tard)
```

## Exécuter le pipeline (Canadian Weather)

```r
source("src/main.R")
```

Génère 7 figures dans `figures/` et affiche un tableau comparatif des 5 approches (3 stratégies + 2 baselines).

## Documentation

- **Théorie** : `docs/resume_donnees_fonctionnelles.tex` — données fonctionnelles, lissage, ACP fonctionnelle, distances, clustering
- **Pipeline** : `docs/guide_canadian_weather.md` — explication détaillée de chaque étape, de l'ARI, des résultats
