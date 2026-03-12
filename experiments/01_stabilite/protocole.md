# 01 — Sélection par stabilité du clustering

**Source** : Rapport de synthèse, § 8.1 (Perspectives de recherche)

## Idée

Le bon triplet \((k, \alpha, \omega)\) est celui qui produit des clusters **reproductibles** lorsqu'on perturbe les données. On mesure la stabilité par bootstrap.

## Protocole (rapport)

Pour chaque triplet \((k, \alpha, \omega)\) dans la grille :

1. Calculer la partition \(\mathcal{C}\) sur les \(n\) individus complets (PAM avec \(\Dw(\alpha, \omega)\)).
2. Répéter \(B\) fois (\(B \approx 50\)) :
   - Sous-échantillonner 80 % des individus aléatoirement.
   - Recalculer la distance et la partition \(\mathcal{C}_b^*\) sur ce sous-échantillon.
   - Mesurer l'ARI entre \(\mathcal{C}\) (restreinte aux individus présents) et \(\mathcal{C}_b^*\).
3. Stabilité = \(\frac{1}{B}\sum_{b=1}^{B} \text{ARI}(\mathcal{C}, \mathcal{C}_b^*)\).

Le triplet avec stabilité maximale est retenu.

## Hypothèse à tester

La stabilité sélectionne-t-elle des \((\alpha, \omega)\) plus proches de l'ARI-optimal que la silhouette ?

## Grille (pour prototype rapide)

- \(\alpha, \omega \in \{0, 0.5, 1\}\) ou grille fine \(\{0, 0.1, \ldots, 1\}\)
- \(k \in \{2, 3, 4, 5, 6\}\)
- \(B = 10\) (prototype) → 50 (final)

## Critères de succès

- Sur Canadian Weather : stabilité choisit \((\alpha, \omega)\) proche de \((0.6, 0.8)\) ?
- ARI obtenu avec le triplet stabilité-optimal \(\geq\) ARI silhouette-optimal ?

## Structure des scripts

- **`run_stabilite.R`** : exécute la stabilité pour un dataset (DATASET défini avant `source()`).
- **`run_all_stability.R`** : lance les 4 datasets avec les paramètres globaux.
- **`analyse_stabilite.R`** : charge les CSV, affiche les meilleurs triplets, génère les heatmaps dans `figures/`.
- **`generate_confusion.R`** : recalcule les partitions stabilité-optimales et sauvegarde les matrices de confusion dans `results/`.
- **`rapport_stabilite.tex`** : rapport LaTeX résumant protocole, résultats, matrices de confusion et interprétations. Compilation : `make` depuis ce dossier.

Paramètres modifiables dans `run_all_stability.R` : ALPHAS, OMEGAS, K_VALUES, B, SUBSAMPLE_FRAC.

## Choix du sous-échantillonnage (SUBSAMPLE_FRAC)

| Valeur | Effet | Usage typique |
|--------|-------|---------------|
| **80 %** | Compromis standard : perturbation suffisante pour tester la stabilité, assez de données pour garder la structure | Recommandé par défaut |
| 90 % | Moins de perturbation, ARI plus élevés en moyenne, moins discriminatif entre triplets | Données très bruitées ou petits échantillons |
| 63 % | ≈ 1−1/e (fraction attendue dans un bootstrap) ; plus de variabilité | Certaines méthodes de stabilité |
| 50 % | Valeur par défaut de `clusterboot` (fpc) ; forte perturbation | Détecter l'instabilité, mais peut sur-pénaliser les grands k quand n est petit |

Avec n petit (ex. Canadian n=35), garder au moins ~80 % évite des sous-échantillons trop petits pour PAM à k=4 ou 6.

## Statut

- [x] Protocole validé
- [x] Implémentation (`run_stabilite.R`)
- [x] Exécution multi-datasets (`run_all_stability.R`)
- [x] Résultats sur les 4 datasets (grille α,ω ∈ {0, 0.25, 0.5, 0.75, 1}, B=15)
- [x] Analyse et heatmaps (`analyse_stabilite.R`)
- [x] Grille fine (α, ω ∈ {0, 0.1, …, 1}, 11×11) + B=50
