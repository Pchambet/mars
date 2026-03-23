# Résultats — expérience 01 (instabilité / nselectboot)

## Fichiers maintenus par le pipeline actuel

- `nselectboot_*.csv` — grille 21×21, \(B=150\), un fichier par dataset.
- `confusion_nselectboot_*.csv` — matrices de confusion (règle : voir `generate_confusion_nselectboot.R`).

Les heatmaps correspondantes sont dans `../figures/` du dépôt d’expérience (`experiments/01_instabilite/figures/`, fichiers `nselectboot_heatmap_<dataset>.png`). Régénération : `Rscript -e 'source("experiments/01_instabilite/analyse_nselectboot.R")'` depuis la racine du dépôt. Elles sont incluses dans le mémoire `docs/rapport_stage.tex` (chapitre~4) pour comparaison entre jeux réels ; le volet simulé utilise `nselectboot_heatmap_sim_*.png` dans le même dossier.

## Fichiers `stabilite_*` et `confusion_stabilite_*`

Ces sorties correspondaient à l’ancien protocole « stabilité » (hors pipeline depuis le recalibrage). **Ils ne sont plus régénérés.**  
Tu peux les supprimer du dossier ou les garder comme archive locale ; ils ne sont plus documentés dans le rapport PDF de l’exp. 1.

## Autres

- `clest_prototype_canadian.csv` : prototype séparé (non inclus dans `run_all_complete.R`).
