# 02 — Vote entre critères de validation

**Source** : Rapport de synthèse, § 8.2 (Perspectives de recherche)

## Idée

Plutôt que s'appuyer sur un seul critère, faire **voter** plusieurs critères pour élire le meilleur \((k, \alpha, \omega)\). Un critère qui se trompe (ex. silhouette sur \(\omega\)) sera corrigé par les autres.

## Critères à combiner

| Critère | Mesure | Référence |
|---------|--------|-----------|
| Silhouette | Compacité / séparation géométrique | — |
| Gap statistic | Écart d'inertie vs référence uniforme | Tibshirani et al. 2001 |
| Prediction strength | Reproductibilité par validation croisée | Tibshirani & Walther 2005 |
| Stabilité | Bootstrap (cf. 01_stabilite) | — |
| Calinski-Harabasz | Rapport variance inter / intra | Calinski & Harabasz 1974 |
| Davies-Bouldin | Ratio dispersion intra / séparation inter | Davies & Bouldin 1979 |

## Règles de vote

1. **Vote majoritaire** : triplet arrivant en tête du plus grand nombre de critères.
2. **Score de Borda** : chaque critère attribue un rang ; somme des rangs ; triplet avec somme minimale gagne.
3. **Vote pondéré** : pondérer les critères par fiabilité estimée sur datasets labellisés.

## Protocole

1. Pour chaque triplet \((k, \alpha, \omega)\), calculer les \(M\) critères.
2. Chaque critère produit un classement des triplets.
3. Agrégation par règle de vote (majorité, Borda, ou pondéré).
4. Retenir le triplet élu.

## Hypothèse à tester

Le vote agrège-t-il un signal plus fiable que chaque critère seul ?

## Dépendances

- Nécessite l'implémentation de la stabilité (01) pour inclure ce critère dans le vote.
- Gap statistic et Prediction strength : vérifier disponibilité R (cluster, fpc, etc.).

## Statut

- [ ] Critères disponibles identifiés
- [ ] Implémentation des critères manquants
- [ ] Implémentation du vote
- [ ] Résultats
