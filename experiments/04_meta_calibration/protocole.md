# 04 — Méta-calibration sur données labellisées

**Source** : Rapport de synthèse, § 8.4 (Perspectives de recherche)

## Idée

Les résultats montrent \(\alpha_{\text{optimal}} \geq 0.6\) sur les 4 datasets. Ce pattern pourrait permettre de **fixer** \(\alpha\) à une valeur méta-calibrée (ex. 0.7 ou 0.8), réduisant le problème 3D \((k, \alpha, \omega)\) à un problème 2D \((k, \omega)\).

## Protocole

1. Fixer \(\alpha = 0.7\) (ou valeur à calibrer).
2. Grid search 2D sur \((k, \omega)\) uniquement.
3. Évaluer sur les 4 datasets : perte d'ARI par rapport au 3D complet ?
4. Tester d'autres valeurs fixes (\(\alpha = 0.6\), 0.8) pour sensibilité.

## Hypothèse à tester

Fixer \(\alpha\) à 0.6–0.8 préserve-t-il une qualité de clustering proche de l'optimal, tout en réduisant la complexité ?

## Validation de robustesse

Idéalement valider sur 15–20 jeux de données fonctionnels labellisés. En pratique : commencer sur les 4 disponibles.

## Avantage

Réduction du coût : grille 3D → grille 2D (factoriel ~5–10 selon la finesse).

## Statut

- [ ] Valeur de \(\alpha\) fixe choisie
- [ ] Expérience sur les 4 datasets
- [ ] Comparaison ARI (2D vs 3D optimal)
