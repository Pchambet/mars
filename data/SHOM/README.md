## Données SHOM (projet ACP hybride)

Ce dossier contient les fichiers de données réelles fournis par le SHOM
pour l'application non supervisée sur des profils de célérité du son.

- `data_f_SHOM_1000_maxL.rds`  
  Tableau (ou liste) de courbes fonctionnelles pour **1000 profils**,
  tous ramenés à la même longueur maximale (`maxL`). Les lignes
  correspondent aux individus, les colonnes aux profondeurs auxquelles
  les courbes sont observées.

- `data_v_SHOM_1000_maxL.rds`  
  Tableau des **variables vectorielles** associées à chaque profil :
  - `csurf` : célérité en surface,
  - `cfond` : célérité au fond,
  - `nbMin` : nombre de minima locaux,
  - `nbMax` : nombre de maxima locaux.

Les deux fichiers peuvent être lus en R via :

```r
f_SHOM <- readRDS(\"data/SHOM/data_f_SHOM_1000_maxL.rds\")
v_SHOM <- readRDS(\"data/SHOM/data_v_SHOM_1000_maxL.rds\")
```

Ils sont utilisés dans les scripts d'expérience du dossier
`experiments/07_application_non_labelisees/` pour :

- construire des objets mixtes (partie fonctionnelle + partie vectorielle),
- appliquer le pipeline RS-PCA / noyaux hybrides décrit dans le rapport de
  synthèse et dans le plan de stage,
- étudier le clustering non supervisé des profils SHOM.

