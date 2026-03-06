# Guide complet — Pipeline sur Canadian Weather

> **Objectif** : s'entraîner sur un jeu de données simple et connu avant de passer aux données SHOM.  
> Ce document explique **pourquoi** on fait chaque étape, **ce qu'on en tire**, et renvoie aux sections du résumé théorique LaTeX (`docs/resume_donnees_fonctionnelles.tex`).

---

## 1. Pourquoi Canadian Weather ?

On a besoin d'un cas d'entraînement qui possède **trois ingrédients** :

| Ingrédient | Dans Canadian Weather | Dans le stage (SHOM) |
|---|---|---|
| **Données fonctionnelles X** | Température quotidienne (365 jours × 35 stations) | Profils de célérité du son (48 profondeurs × ~11 000 points) |
| **Données vectorielles Z** | Latitude, longitude, précipitation moyenne | Fréquence de coupure, pertes de propagation, etc. |
| **Vérité terrain** | 4 régions climatiques (Arctic, Atlantic, Continental, Pacific) | Inconnue — c'est le but du clustering |

La vérité terrain est cruciale pour **évaluer objectivement** si nos algorithmes fonctionnent. Sur les données SHOM, on n'aura pas cette chance : il faudra se fier uniquement à des critères intrinsèques (silhouette) et à l'interprétation physique. D'où l'importance de d'abord **valider la méthode** sur un cas où on connaît la bonne réponse.

---

## 2. Le pipeline, étape par étape

### Étape 00 — Préparation (`src/00_preprocess.R`)

**Ce qu'on fait.** On charge et on organise les données brutes en deux blocs distincts :

- **Y_brut** : matrice 365 × 35 de températures. Ce sont les observations discrètes $Y_{ij}$ du modèle $Y_{ij} = X_i(t_j) + \varepsilon_{ij}$.  
  → *Voir LaTeX, Section 1 (définition d'une donnée fonctionnelle) et Section 4 (modèle d'observation).*

- **Z** : matrice 35 × 3 contenant latitude, longitude et précipitation moyenne. Ce sont les **variables vectorielles classiques**, qui vivent dans $\mathbb{R}^p$.  
  → *Voir LaTeX, Section « Le cas mixte : données fonctionnelles + vectorielles ».*

- **regions** : les 4 régions climatiques — notre **vérité terrain** pour évaluer le clustering.

**Pourquoi.** Le problème du stage est un problème **mixte** : on a à la fois des courbes (dimension infinie) et des nombres (dimension finie). On ne peut pas les empiler dans la même matrice. Dès la préparation, on sépare proprement les deux sources.

---

### Étape 01 — Lissage (`src/01_lissage.R`)

**Ce qu'on fait.** On transforme les 35 colonnes de nombres discrets en 35 **vrais objets fonctionnels** : des courbes continues, évaluables en tout point de [1, 365], dérivables.

→ *Voir LaTeX, Section 5 (« Le pré-traitement : du discret au fonctionnel par lissage »).*

**Comment.** Moindres carrés pénalisés avec B-splines :

$$\min_{\theta} \sum_{j=1}^{N} \left(Y_{ij} - \sum_{k=1}^{d} \theta_{ik}\psi_k(t_j)\right)^2 + \lambda \int \left[\hat{X}_i''(t)\right]^2 dt$$

- **Base** : 65 B-splines d'ordre 4 (cubiques). On met volontairement "trop" de fonctions de base. C'est la pénalité λ qui contrôle la régularité, pas le nombre de bases.
- **λ** : choisi automatiquement par GCV (Generalized Cross-Validation). Le GCV trouve λ ≈ 8.15 pour les données canadiennes.

**Résultat.** L'objet `X_hat` est un objet `fd` contenant les 35 courbes lissées dans $L^2([1, 365])$.

**Figure associée** : `fig01_gcv.png` — la courbe GCV montrant le minimum.

---

### Étape 02 — ACP fonctionnelle (`src/02_fpca.R`)

**Ce qu'on fait.** On résout l'équation aux fonctions propres dans $L^2$ :

$$\int_{\mathcal{T}} C(s,t)\,\varphi_k(s)\,ds = \lambda_k\,\varphi_k(t)$$

→ *Voir LaTeX, Partie II complète (« ACP fonctionnelle »), en particulier les Sections 7 à 11.*

**Résultat concret.** Chaque station passe d'une **courbe** (365 valeurs, ou plutôt une fonction continue) à **K = 2 nombres** (les scores $\xi_{i1}$ et $\xi_{i2}$).

- PC1 (88.5%) : capte le **niveau moyen** de température. Les stations arctiques ont un score PC1 très négatif (froides toute l'année), les stations du Pacifique un score très positif (douces).
- PC2 (8.5%) : capte le **contraste saisonnier**. Les stations continentales (Winnipeg, Regina) ont des hivers glaciaux et des étés chauds → score PC2 élevé. Les stations maritimes (Vancouver, Victoria) ont un climat tempéré → score PC2 faible.

→ *Voir LaTeX, Section 8 (interprétation des fonctions propres) et Section 9 (les scores).*

**Pourquoi K = 2.** On retient les composantes nécessaires pour expliquer ≥ 95% de la variance. Ici, PC1 + PC2 = 97.0%. C'est le passage essentiel :

> On passe de la dimension infinie ($L^2$) à la dimension finie ($\mathbb{R}^2$).

**Figures associées** :  
- `fig03_fonctions_propres.png` — les modes de variation φ₁(t) et φ₂(t)  
- `fig04_scores_fpca.png` — les 35 stations dans le plan (ξ₁, ξ₂), colorées par région

---

### Étape 03 — Distances (`src/03_distances.R`)

**Ce qu'on fait.** On construit les **matrices de distances** nécessaires aux 3 stratégies de clustering.

→ *Voir LaTeX, Sections « Distance $L^2$ directe entre courbes » et « Le cas mixte ».*

#### Distances fonctionnelles (sur les courbes X)

| Distance | Formule | Ce qu'elle mesure |
|---|---|---|
| **D0** | $\sqrt{\int [X_i(t) - X_j(t)]^2\,dt}$ | Proximité globale (niveau) |
| **D1** | $\sqrt{\int [X_i'(t) - X_j'(t)]^2\,dt}$ | Proximité de dynamique (pente) |
| **Dp** | $\sqrt{(1-\omega)D_0^2 + \omega D_1^2}$ | Combinaison niveau + forme |

#### Distance vectorielle (sur Z)

| Distance | Formule | Ce qu'elle mesure |
|---|---|---|
| **Ds** | Distance euclidienne sur Z standardisé | Proximité géographique + climatique |

#### Distances mixtes (X + Z)

| Distance | Formule | Ce qu'elle mesure |
|---|---|---|
| **Dw** | $\sqrt{\omega \cdot D_f^2 + (1-\omega) \cdot D_s^2}$ | Combinaison pondérée fonctionnel + vectoriel |
| **DK** | $\sqrt{K(i,i) + K(j,j) - 2K(i,j)}$ avec $K = K_f \cdot K_s$ | Combinaison par noyaux (pas de ω) |

→ *Voir LaTeX, Sections « Approche par distance pondérée $D_\omega$ » et « Approche par noyaux ($D_K$) ».*

**Point important : la normalisation.** D0 et Ds n'ont pas la même échelle (D0 est en milliers, Ds en unités). Avant de les combiner dans Dw, on normalise chaque matrice par son maximum. Sans ça, l'une écrase l'autre.

---

### Étape 04 — Clustering (`src/04_clustering.R`)

**Ce qu'on fait.** On applique les **3 stratégies** décrites dans le LaTeX (Section « Synthèse : les trois stratégies comparées ») et on les évalue.

#### Les 3 stratégies

| Stratégie | Principe | Algorithme |
|---|---|---|
| **A** | FPCA → scores ξ concaténés avec Z → clustering classique | k-means sur W = [ξ₁, ξ₂, lat, lon, précip] |
| **B** | Distance mixte Dw → clustering basé distances | PAM sur Dw, grid search sur ω |
| **C** | Distance à noyaux DK → clustering basé distances | PAM sur DK |

#### Les baselines (pour comparer)

| Baseline | Ce que ça teste |
|---|---|
| **D0 seul** | Les courbes seules suffisent-elles ? |
| **Ds seul** | Les variables Z seules suffisent-elles ? |

---

## 3. L'ARI — Comment on évalue le clustering

### Le problème

On a des clusters prédits (par notre algorithme) et des clusters vrais (les 4 régions). Comment mesurer si la prédiction est bonne ?

On ne peut **pas** simplement comparer les numéros de clusters. Si l'algorithme met toutes les stations arctiques dans le cluster 3 et toutes les atlantiques dans le cluster 1, c'est parfait — même si les numéros ne correspondent pas aux numéros des régions. Ce qui compte, c'est que **les mêmes stations soient regroupées ensemble**.

### L'ARI (Adjusted Rand Index)

L'ARI mesure la **concordance** entre deux partitions, corrigée du hasard.

**Idée.** On regarde toutes les paires possibles de stations (il y en a $\binom{35}{2} = 595$). Pour chaque paire, il y a 4 cas possibles :

| | Même cluster prédit | Clusters prédits différents |
|---|---|---|
| **Même région vraie** | ✅ Accord positif (a) | ❌ Désaccord |
| **Régions vraies différentes** | ❌ Désaccord | ✅ Accord négatif (b) |

L'indice de Rand brut serait $(a + b) / \text{total}$, mais il est biaisé vers le haut (même un clustering aléatoire donne un score élevé). L'ARI corrige ce biais :

$$\text{ARI} = \frac{\text{Rand observé} - \text{Rand espéré sous le hasard}}{\text{Rand maximum} - \text{Rand espéré sous le hasard}}$$

**Interprétation :**

| ARI | Signification |
|---|---|
| 1.0 | Partition parfaite (identique à la vérité terrain) |
| 0.0 | Partition aléatoire (pas mieux que le hasard) |
| < 0 | Pire que le hasard |
| > 0.65 | Généralement considéré bon |
| > 0.80 | Très bon |

### Pourquoi l'ARI et pas autre chose ?

- **Pas besoin de correspondance des labels.** L'ARI ne regarde pas les numéros de clusters, juste les regroupements.
- **Corrigé du hasard.** Contrairement au Rand Index brut ou au taux de bonne classification.
- **Standard en clustering.** C'est la métrique la plus utilisée dans la littérature quand on a une vérité terrain.

### La silhouette — critère intrinsèque

L'ARI nécessite une vérité terrain. Sur les données SHOM, on n'en aura pas. On utilise alors la **silhouette moyenne**, qui mesure la **qualité intrinsèque** des clusters :

Pour chaque individu $i$ dans le cluster $C_k$ :

$$s(i) = \frac{b(i) - a(i)}{\max(a(i), b(i))}$$

- $a(i)$ = distance moyenne de $i$ aux autres membres de son cluster
- $b(i)$ = distance moyenne de $i$ aux membres du cluster le plus proche

$s(i) \in [-1, 1]$ : proche de 1 = bien classé, proche de -1 = mal classé.

---

## 4. Résultats sur Canadian Weather

| Stratégie | Silhouette | ARI | Commentaire |
|---|---|---|---|
| D0 seul (baseline) | 0.285 | 0.229 | Les courbes L² brutes ne suffisent pas |
| Ds seul (baseline) | 0.448 | 0.616 | La géographie seule est déjà informative |
| **A : FPCA + Z** | **0.395** | **0.748** | **Meilleur ARI** — la FPCA apporte de l'info que Z seul n'a pas |
| B : Dw (ω=0.0) | 0.448 | 0.616 | ω=0 → ignore les courbes, retombe sur Ds |
| C : DK (noyaux) | 0.329 | 0.686 | Intermédiaire — combine bien sans paramètre |

### Ce qu'on apprend

1. **D0 seul est mauvais (ARI=0.229).** La distance L² brute entre les courbes de température ne retrouve pas bien les 4 régions. Pourquoi ? Parce que D0 est dominée par le **niveau moyen** de température. Or deux stations peuvent avoir le même niveau moyen mais des saisonnalités très différentes (ex : Vancouver vs Halifax).

2. **Z seul est déjà bon (ARI=0.616).** La latitude et la longitude structurent naturellement les régions climatiques. C'est logique : au Canada, la géographie détermine largement le climat.

3. **La stratégie A (FPCA + Z) est la meilleure (ARI=0.748).** Quand on combine les scores FPCA (qui capturent le niveau moyen ET le contraste saisonnier) avec les variables géographiques, on fait mieux que chaque source seule. C'est la preuve que **l'approche mixte apporte quelque chose**.

4. **ω=0 pour la stratégie B** signifie que D0 brut "gêne" la classification quand on le combine avec Ds. C'est un résultat spécifique à Canadian Weather — sur les données SHOM, les profils de célérité portent beaucoup plus d'information discriminante.

5. **DK donne un bon ARI (0.686)** sans aucun paramètre ω à régler. C'est son avantage principal : la combinaison est automatique via le noyau produit.

---

## 5. Lien avec les données SHOM

Ce pipeline Canadian Weather est un **prototype complet** qui se transpose directement :

| Étape | Canadian Weather | SHOM |
|---|---|---|
| Données X | Température (365 jours) | Célérité du son (48 profondeurs) |
| Données Z | Latitude, longitude, précip | Variables acoustiques (freq. coupure, pertes...) |
| Lissage | B-splines + GCV uniforme | B-splines + nœuds quantiles (profondeurs non-uniformes) |
| FPCA | K=2 (97% variance) | K à déterminer |
| Distances | D0, Ds, Dw, DK | Idem |
| Vérité terrain | 4 régions → ARI | Pas de vérité → silhouette + interprétation physique |
| Algorithme | k-means (strat. A), PAM (B, C) | Idem, + possiblement CAH |

Le passage aux données SHOM impliquera :
- Utiliser `preprocess_shom()` et les nœuds quantiles pour le lissage
- Paralléliser les calculs de distances (11 000 profils vs 35 stations)
- Se passer de l'ARI (pas de vérité terrain) et s'appuyer sur la silhouette et la validation physique (cartes géographiques des clusters)

---

## 6. Structure du dépôt

```
src/
├── 00_preprocess.R      Chargement et séparation X / Z / vérité
├── 01_lissage.R         B-splines + GCV → courbes L²
├── 02_fpca.R            ACP fonctionnelle, choix K par variance cumulative
├── 03_distances.R       D0, D1, Dp, Ds, Dw, DK
├── 04_clustering.R      3 stratégies + baselines, ARI + silhouette
├── 05_visualisation.R   7 figures
└── main.R               Pipeline complet (source ce fichier pour tout lancer)
```

Pour exécuter : `source("src/main.R")`
