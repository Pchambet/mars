# Rapport de stage (15–20 p.) — périmètre et plan rédigé

**Objectif** : fixer une **source canonique**, des **budgets de pages** et un **fil narratif** (hypothèse, paradoxe silhouette/ARI, règle sur l’ARI) alignés sur [`STATE_OF_PROJECT.md`](../STATE_OF_PROJECT.md).

---

## 1. Décision : source canonique

| Option | Rôle |
|--------|------|
| **Rapport de stage** | [`docs/rapport_stage.tex`](rapport_stage.tex) — squelette **structuré pour 15–20 pages**, avec renvois explicites vers les synthèses ; compilation : `make -C docs rapport_stage.pdf` ou `pdflatex rapport_stage.tex`. |
| [`docs/rapport_synthese.tex`](rapport_synthese.tex) | **Référence technique** : chiffres validés ([`revue_rapport_synthese.md`](revue_rapport_synthese.md)), figures, développements longs. Ne pas le recopier intégralement : risque de dépasser la limite et de noyer le fil du stage. |
| [`experiments/03_simulated_hybride/RAPPORT_DETAILLE_EXPERIENCE_03.md`](../experiments/03_simulated_hybride/RAPPORT_DETAILLE_EXPERIENCE_03.md) + [`results/SYNTHESE_BENCHMARK_SIMULE.md`](../experiments/03_simulated_hybride/results/SYNTHESE_BENCHMARK_SIMULE.md) | **Source de vérité** pour le protocole simulé et les messages quantitatifs associés. |
| [`experiments/01_instabilite/rapport_instabilite.tex`](../experiments/01_instabilite/rapport_instabilite.tex) | **Annexe ou section courte** (instabilité / critères) si le jury exige la traçabilité ; pas le cœur du rapport si l’espace est limité. |

**Synthèse** : le rapport de stage est un **document dérivé et ciblé**, pas un duplicata du monolithe `rapport_synthese.tex`.

---

## 2. Budgets indicatifs (total 15–20 p.)

| Section | Pages cible | Contenu minimal |
|---------|-------------|-----------------|
| Introduction / problème / objectifs | 1,5–2 | Données mixtes, question A/B/C, sélection des paramètres **sans** vérité terrain ; évaluation **avec** vérité terrain quand disponible. |
| Cadre théorique (ACP hybride HFV, D_w, noyaux) | 3–4 | Définitions, chaîne 02b → 03b ; **ω** vs **r** (tableau `STATE_OF_PROJECT`). |
| Périmètre du stage et chemins explorés | 2–3 | Distances, stratégies A/B/C, impasses (ex. RS-PCA) : **bref**, justifié par l’hypothèse centrale. |
| Comparatif des méthodes et enjeu | 1,5–2 | Pourquoi ce dispositif ; **paradoxe silhouette vs ARI** ; implication données non labellisées. |
| Données simulées (quoi / pourquoi / comment) | 2–3 | Cas2_deriv, reproductibilité, renvoi `PROTOCOLE_SORTIES.md`. |
| Résultats simulés | 2–3 | Messages, pas seulement des tableaux ; synthèse benchmark. |
| Trois jeux réels | 3–4 | Protocole commun, lecture alignée sur `revue_rapport_synthese.md`. |
| Conclusion / limites / perspectives | 1–1,5 | Calibration (silhouette), SHOM, suites HFV si pertinent. |

Ajuster selon les contraintes de la formation ; l’important est de **garder le paradoxe et la règle ARI visibles** sans dilution.

---

## 3. Plan détaillé avec fil narratif obligatoire

### Fil rouge (à répéter en intro et conclusion)

1. **Hypothèse** : comparer les stratégies A, B, C sur données mixtes ; paramètres (α, ω) choisis par un critère **sans** étiquettes (ex. silhouette sur grille), pas par maximisation de l’ARI.
2. **Paradoxe** : une fois les partitions obtenues, l’**évaluation** par ARI (lorsque les labels existent) peut montrer que des dérivées ou des α élevés sont informatifs, alors que le couple **sélectionné** par silhouette peut favoriser α = 0 — écart entre « ce qui est bon au sens ARI sur la grille » et « ce que le pipeline opérationnel retient ».
3. **Règle rédactionnelle et scientifique** : l’**ARI ne tune pas** (α, ω) dans le code ni dans le benchmark simulé ; toute mention d’« α ARI-optimal » est une **lecture a posteriori** pour illustration, pas le protocole de production.

### Squelette de sections (aligné sur ton plan initial)

0. **Introduction** — Ce qu’on cherche : classification non supervisée robuste pour données fonctionnelles + vectorielles ; question des stratégies et des paramètres.
1. **Théorie** — ACP hybride (HFV), distances pondérées D_w(α, ω), distances à noyaux sur reconstructions (02b → 03b).
2. **Travaux et explorations connexes** — Distances, stratégies A/B/C, instabilité (option exp. 01) : narratif de **cheminement**, pas d’excès de pages.
3. **Différences entre méthodes et motivation** — Tableau conceptuel A vs B vs C ; **paradoxe** et pourquoi les benchmarks simulés et réels sont nécessaires.
4. **Données simulées** — Définition du générateur, paramètres, absence de « grille oracle ARI » ; traçabilité (`PROTOCOLE_SORTIES`, CSV dans `results/`).
5. **Tests sur données simulées** — Synthèse des enseignements ([`SYNTHESE_BENCHMARK_SIMULE.md`](../experiments/03_simulated_hybride/results/SYNTHESE_BENCHMARK_SIMULE.md)).
6. **Tests sur trois jeux réels** — Canadian, Growth, Tecator ; valeurs de référence : [`revue_rapport_synthese.md`](revue_rapport_synthese.md).
7. **Conclusion** — Limites (silhouette), perspectives (SHOM, etc.).

---

## 4. Liens code (pour cadrage du rapport)

- Pipeline principal : [`src/main.R`](../src/main.R) → 01–05 (pas de 02b/03b par défaut).
- Chaîne hybride + noyaux : [`src/02b_pca_hybride_reconstruction.R`](../src/02b_pca_hybride_reconstruction.R) → [`src/03b_distances_noyaux_hybrides.R`](../src/03b_distances_noyaux_hybrides.R) ; expérience [`experiments/03_simulated_hybride/`](../experiments/03_simulated_hybride/).
- Nomenclature **ω** / **r** : [`experiments/03_simulated_hybride/NOTE_RS_PCA_VS_HFV_PCA.md`](../experiments/03_simulated_hybride/NOTE_RS_PCA_VS_HFV_PCA.md).

Détail d’inventaire et de flux : [`AUDIT_PROJET.md`](AUDIT_PROJET.md).
