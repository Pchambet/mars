# Fichiers générés pour le mémoire

- **`benchmark_ari_by_scenario.tex`** — tableau ARI du chapitre 5, produit par `scripts/generate_rapport_stage_benchmark_tex.R` à partir des CSV du benchmark simulé.

- **`paradox_silhouette_ari.tex`** — tableau paradoxe silhouette / ARI (stratégie B, quatre jeux réels), produit par `scripts/generate_rapport_stage_paradox_tex.R` (recalcule les grilles sur les données).

- **`ch6_real_three_games_table.tex`** — tableau des six familles de méthodes sur Canadian / Growth / Tecator, produit par `scripts/generate_ch6_three_games_table_tex.R` à partir de `docs/exports/comparaison_*.csv`.

Ne pas modifier les `.tex` à la main : régénérer après tout nouveau run du benchmark ou tout changement de grille / jeux pour le paradoxe (`make -C docs paradox-tex`). Pour le ch.6, exporter les CSV (`MARS_EXPORT_COMPARAISON=1` + `src/main.R` pour chaque jeu) puis `make -C docs ch6-real-tex`.
