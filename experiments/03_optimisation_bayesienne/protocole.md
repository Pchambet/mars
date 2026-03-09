# 03 — Optimisation bayésienne

**Source** : Rapport de synthèse, § 8.3 (Perspectives de recherche)

## Idée

Remplacer le grid search 3D coûteux par une **optimisation bayésienne** : évaluer peu de triplets (~30) au lieu de ~600, en utilisant un processus gaussien pour guider l'exploration.

## Protocole (rapport)

1. Évaluer un petit nombre de triplets initiaux (design latin hypercube, ~15 points).
2. Ajuster un **processus gaussien (GP)** sur la surface \(S(k, \alpha, \omega)\) (stabilité ou score de vote).
3. Choisir le prochain triplet par critère d'**acquisition** (Expected Improvement) : explorer là où le GP prédit gain potentiel ou forte incertitude.
4. Itérer jusqu'à convergence (~20–30 évaluations au total).

## Objectif

Réduire le coût : ~600 (grid complet) → ~30 évaluations.

## Outils R potentiels

- ` DiceOptim` (optimisation bayésienne)
- `mlrMBO`
- `rBayesianOptimization`

## Hypothèse à tester

L'optimisation bayésienne trouve-t-elle un triplet de qualité comparable au grid search complet en beaucoup moins d'évaluations ?

## Dépendances

- Nécessite un critère à maximiser (stabilité ou score de vote) — dépend de 01 et 02.
- Surface 3D : \((k, \alpha, \omega)\) — \(k\) discret, \(\alpha, \omega\) continus.

## Statut

- [ ] Bibliothèque R sélectionnée
- [ ] Intégration avec critère (stabilité ou vote)
- [ ] Tests sur un dataset
- [ ] Comparaison vs grid search
