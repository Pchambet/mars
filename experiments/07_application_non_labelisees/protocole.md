# 07 — Application aux données non labellisées (SHOM)

**Source** : Rapport de synthèse, § 8.6 (Perspectives de recherche)

## Idée

Test final de l'architecture sur des données **réelles non labellisées** : profils de célérité du son du SHOM. Enjeu triple :

1. Déterminer automatiquement le nombre de clusters \(k\).
2. Sélectionner \((\alpha, \omega)\) sans vérité terrain.
3. Valider la pertinence des clusters par **expertise métier**.

## Méthode

Utiliser les pistes 01–04 (stabilité, vote, optimisation bayésienne, méta-calibration) pour résoudre (1) et (2). Pour (3) : collaboration avec experts SHOM pour interpréter les clusters obtenus.

## Données

- Fichier : `data/shom_celerite_2018.csv` (à intégrer).
- Préprocesseur : `00_preprocess_shom.R` (à créer quand les données seront intégrées).

## Protocole

1. **Quand les données SHOM sont intégrées** :
   - Créer `src/00_preprocess_shom.R` (format : \(Y_{\text{brut}}\), \(Z\), pas de `regions`).
   - Lancer le pipeline avec méthode de sélection non supervisée (stabilité ou vote).
   - Produire les clusters et les visualiser.
2. **Validation** : faire valider les clusters par expertise métier (interprétation physique des profils).

## Dépendances

- Intégration des données SHOM (reportée à plus tard, cf. audit).
- Les méthodes 01–04 doivent être opérationnelles.

## Statut

- [ ] Données SHOM intégrées
- [ ] Preprocesseur créé
- [ ] Sélection \((k, \alpha, \omega)\) par méthode non supervisée
- [ ] Validation expertise métier
