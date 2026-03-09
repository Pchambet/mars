# 06 — Consensus clustering (agrégation Dw + DK)

**Source** : Rapport de synthèse, § 8.5 (Enrichissement de l'architecture)

## Idée

\(\Dw\) (somme pondérée) et \(\DK\) (produit de noyaux) produisent des partitions **différentes**. Explorer des stratégies d'**ensemble** qui agrègent les partitions issues de plusieurs distances → **consensus clustering**.

## Principe

1. Générer plusieurs partitions avec différentes distances / paramètres :
   - PAM sur \(\Dw(\alpha_1, \omega_1)\), \(\Dw(\alpha_2, \omega_2)\), …
   - PAM sur \(\DK(\alpha_1)\), \(\DK(\alpha_2)\), …
2. Agréger ces partitions (matrice de co-association, consensus, etc.).
3. Obtenir une partition finale plus robuste.

## Méthodes d'agrégation

- **Matrice de co-association** : pour chaque paire \((i,j)\), proportion de partitions où \(i\) et \(j\) sont dans le même cluster.
- **Clustering sur la matrice de co-association** (CAH ou PAM).
- **CSPA, MCLA, HGPA** (algorithmes de consensus, Strehl & Ghosh 2002).

## Protocole

1. Choisir un ensemble de partitions (grille réduite de \((\alpha, \omega)\) pour Dw et DK).
2. Construire la matrice de co-association.
3. Produire la partition consensus.
4. Évaluer (ARI si labellisé) : le consensus est-il meilleur que chaque partition individuelle ?

## Hypothèse à tester

L'agrégation de partitions hétérogènes (Dw vs DK, différents paramètres) produit-elle des clusters plus robustes ou de meilleure qualité ?

## Statut

- [ ] Choix des partitions à agréger
- [ ] Implémentation co-association / consensus
- [ ] Tests sur les 4 datasets
