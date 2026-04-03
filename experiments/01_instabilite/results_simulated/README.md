# Sorties — nselectboot sur données simulées (exp. 1 enrichie)

### Données simulées (générateur)

Alignement sur l’expérience 03 (`benchmark_all_methods_simulated.R`) : mêmes scénarios **S1–S4**, mêmes paramètres `NC_SIM`, `DELTA_SIM`, `SIGMA2_SIM`, `TAU2_SIM`, `P_Z_SIM` (défaut 20). Les scripts de l’exp. 3 ne sont **pas** modifiés.

### nselectboot — même précision que les 3 jeux réels

Pour une **comparaison** avec Canadian, Growth et Tecator (périmètre aligné sur le mémoire), le volet simulé utilise **exactement** les mêmes réglages que `run_nselectboot.R` :

| Paramètre | Valeur |
|-----------|--------|
| `B_NSELECT` | 150 |
| `ALPHAS_NB`, `OMEGAS_NB` | `seq(0, 1, by = 0.05)` → **21×21** couples |
| `K_RANGE` | `2:6` |

Toute déviation doit passer par **`NSELECTBOOT_SIM_RELAXED <- TRUE`** (hors protocole de comparaison).

Le script **`run_simulated_instabilite_only.R`** applique par défaut un **mode rapide** (grille **6×6**, **B = 60**) pour un ordre de grandeur **~15–25 minutes** ; pour l’alignement strict avec les jeux réels, lancer avec **`--full`** (très coûteux).

## Fichiers

| Fichier | Contenu |
|--------|---------|
| `nselectboot_simulated_all_runs.csv` | Long format : `scenario`, `seed`, `k_vrai`, `alpha`, `omega`, `k_opt`, `instability_min`, `stabk` |
| `nselectboot_simulated_summary_by_run.csv` | Une ligne par (scénario, seed) : `prop_grid_k_match`, `median_k_opt`, `mode_k_opt` |
| `nselectboot_simulated_S*_seed<ref>.csv` | Grille pour heatmaps ; **`<ref>` = premier élément de `SEEDS_SIM`** par défaut (`REFERENCE_SEED`), pas le seed 42 si celui-ci n’est pas dans `SEEDS_SIM`. |

## Coût CPU et échelle

- Une grille **21×21** × **B = 150** × plusieurs **seeds** est coûteuse (plusieurs heures selon machine).
- Par défaut : `SEEDS_SIM <- 1L` dans `run_nselectboot_simulated.R` ; pour reproduire le design exp. 3 : `SEEDS_SIM <- 1:50` avant `source()`.
- `run_all_nselectboot.R` : le volet simulé est **désactivé** par défaut (`RUN_NSELECTBOOT_SIMULATED <- FALSE`) pour garder un run rapide sur les 3 jeux réels. `run_all_complete.R` définit `RUN_NSELECTBOOT_SIMULATED <- TRUE` pour enchaîner le simulé après ces jeux.

## Figures

Générées par `analyse_nselectboot_simulated.R` : `figures/nselectboot_heatmap_sim_*.png`.
