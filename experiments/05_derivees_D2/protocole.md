# 05 — Dérivées d'ordre supérieur (\(D_2\))

**Source** : Rapport de synthèse, § 8.5 (Enrichissement de l'architecture)

## Idée

Introduire \(D_2\) : distance \(L^2\) sur les **dérivées secondes** (accélération, courbure). \(D_2\) pourrait capturer des changements de courbure informatifs sur certains types de données (ex. pics, inflexions).

## Formule

\[
D_2(i,j) = \sqrt{\int_{\mathcal{T}} \bigl[\hat{X}_i''(t) - \hat{X}_j''(t)\bigr]^2 \, dt}
\]

## Extension de \(D_p\)

\[
D_p(\alpha, \beta) = \sqrt{(1-\alpha-\beta)\,\tilde{D}_0^2 + \alpha\,\tilde{D}_1^2 + \beta\,\tilde{D}_2^2}
\]

ou une paramétrisation à 2 paramètres (niveau / forme / courbure).

## Protocole

1. Implémenter \(D_2\) dans le pipeline (extension de `03_distances.R` ou script dédié).
2. Tester sur Growth (courbes de taille : accélération pubertaire potentiellement informative) et Tecator (spectres : courbure des pics).
3. Comparer : \(D_p\) avec \(D_2\) améliore-t-il l'ARI sur certains datasets ?

## Hypothèse à tester

\(D_2\) apporte-t-il un gain sur des données où la courbure est discriminante ?

## Statut

- [ ] Implémentation \(D_2\)
- [ ] Intégration dans \(D_p\)
- [ ] Tests sur Growth, Tecator (et autres si pertinent)
