# Experiments — Perspectives de recherche

Ce dossier contient les expériences liées à la section **Perspectives de recherche** du rapport de synthèse. Chaque sous-dossier correspond à une idée distincte et suit la même structure.

## Inventaire des idées (section 8 du rapport)

| # | Dossier | Idée | Source (rapport) |
|---|---------|------|------------------|
| 1 | `01_stabilite` | Sélection par stabilité du clustering | § 8.1 |
| 2 | `02_vote_criteres` | Vote entre critères de validation | § 8.2 |
| 3 | `03_optimisation_bayesienne` | Optimisation bayésienne (GP, acquisition) | § 8.3 |
| 4 | `04_meta_calibration` | Méta-calibration sur données labellisées | § 8.4 |
| 5 | `05_derivees_D2` | Dérivées d'ordre supérieur (\(D_2\)) | § 8.5 |
| 6 | `06_consensus_clustering` | Consensus clustering (agrégation Dw + DK) | § 8.5 |
| 7 | `07_application_non_labelisees` | Application aux données non labellisées (SHOM) | § 8.6 |

## Structure de chaque sous-dossier

```
XX_nom/
├── protocole.md    # Description de l'idée, hypothèse, protocole reproductible
├── run_xxx.R       # Script d'expérience (optionnel au démarrage)
├── results/        # Sorties (tables CSV, figures PNG)
└── notes.md        # Journal de bord, pistes, blocages (optionnel)
```

## Conventions

- **Ne pas modifier** le pipeline validé dans `src/` — le code d'expérience s'appuie sur lui.
- **Reproductibilité** : `set.seed(42)` (ou graine documentée) dans chaque script.
- **Protocole avant code** : rédiger `protocole.md` avant d'implémenter.
- **Traçabilité** : nommer les fichiers de résultats avec dataset + méthode + date si pertinent.

## Verrou central (rapport § 8)

En non supervisé pur, il faut résoudre **simultanément** :
1. Choisir \(k\) (nombre de clusters)
2. Choisir \((\alpha, \omega)\) (paramètres de distance)

L'ARI n'est pas disponible. Les idées 1–4 visent à résoudre ce verrou. Les idées 5–6 enrichissent l'architecture. L'idée 7 est le test final sur données réelles.
