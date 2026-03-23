#!/usr/bin/env Rscript
# Génère docs/generated/paradox_silhouette_ari.tex — stratégie B (Dw), grille 21×21,
# à k fixé (nombre de classes de vérité terrain). Compare le couple (α,ω) qui
# maximise la silhouette à celui qui maximiserait l'ARI sur la même grille
# (lecture d'évaluation uniquement).
#
# Usage (depuis la racine du dépôt) :
#   Rscript scripts/generate_rapport_stage_paradox_tex.R
#
# Prérequis : packages comme setup.R (fda, fda.usc, cluster, mclust).

find_repo_root <- function() {
  d <- normalizePath(getwd(), winslash = "/")
  cand <- c(
    d,
    normalizePath(file.path(d, ".."), winslash = "/"),
    normalizePath(file.path(d, "..", ".."), winslash = "/")
  )
  for (r in cand) {
    if (file.exists(file.path(r, "src/main.R"))) return(r)
  }
  stop("Exécuter ce script depuis la racine du dépôt (ou docs/), ou définir MARS_ROOT.")
}

root <- Sys.getenv("MARS_ROOT", unset = "")
if (!nzchar(root)) root <- find_repo_root()
owd <- setwd(root)
on.exit(setwd(owd), add = TRUE)

if (!requireNamespace("cluster", quietly = TRUE)) stop("Package 'cluster' requis.")
if (!requireNamespace("mclust", quietly = TRUE)) stop("Package 'mclust' requis.")

source("setup.R", local = TRUE)

quiet_source <- function(path) {
  tf <- tempfile(fileext = ".log")
  con <- file(tf, open = "wt")
  sink(con)
  on.exit({
    sink()
    close(con)
    unlink(tf)
  }, add = TRUE)
  source(path, local = FALSE)
}

fmt_fr <- function(x, digits = 3L) {
  s <- sprintf(paste0("%.", digits, "f"), as.numeric(x))
  parts <- strsplit(s, ".", fixed = TRUE)[[1L]]
  paste0(parts[[1L]], "{,}", parts[[2L]])
}

fmt_pair <- function(a, w) {
  paste0("$(", fmt_fr(a, 2L), ",", fmt_fr(w, 2L), ")$")
}

datasets <- c("canadian", "aemet", "growth", "tecator")

libelle_jeu <- function(ds) {
  switch(ds,
    "canadian" = "Canadian Weather",
    "aemet"    = "AEMET",
    "growth"   = "Growth",
    "tecator"  = "Tecator",
    stop("dataset inconnu : ", ds)
  )
}

preprocess_of <- function(ds) {
  switch(ds,
    "canadian" = "src/00_preprocess.R",
    "tecator"  = "src/00_preprocess_tecator.R",
    "aemet"    = "src/00_preprocess_aemet.R",
    "growth"   = "src/00_preprocess_growth.R",
    stop("dataset inconnu")
  )
}

rows_tex <- character()

for (i in seq_along(datasets)) {
  DATASET <- datasets[i]
  set.seed(42)
  quiet_source(preprocess_of(DATASET))
  quiet_source("src/01_lissage.R")
  quiet_source("src/02_fpca.R")
  quiet_source("src/03_distances.R")

  n_clusters <- length(levels(regions))
  labels_vrai <- as.integer(regions)

  alphas <- seq(0, 1, by = 0.05)
  omegas <- seq(0, 1, by = 0.05)
  grille_B <- expand.grid(alpha = alphas, omega = omegas)
  grille_B$silhouette <- NA_real_
  grille_B$ari <- NA_real_

  for (idx in seq_len(nrow(grille_B))) {
    a <- grille_B$alpha[idx]
    w <- grille_B$omega[idx]
    Dp_temp <- compute_Dp(D0_norm, D1_norm, alpha = a)
    Dw_temp <- compute_Dw(Dp_temp, Ds_norm, omega = w)
    pam_temp <- cluster::pam(as.dist(Dw_temp), k = n_clusters, diss = TRUE)
    grille_B$silhouette[idx] <- pam_temp$silinfo$avg.width
    grille_B$ari[idx] <- mclust::adjustedRandIndex(pam_temp$clustering, labels_vrai)
  }

  idx_sil <- which.max(grille_B$silhouette)
  idx_ari <- which.max(grille_B$ari)
  rs <- grille_B[idx_sil, ]
  ra <- grille_B[idx_ari, ]

  gap_ari <- as.numeric(ra$ari - rs$ari)

  rows_tex <- c(rows_tex, paste0(
    "  ", libelle_jeu(DATASET), " & ", n_clusters, " & ",
    fmt_pair(rs$alpha, rs$omega), " & ",
    fmt_fr(rs$silhouette), " & ", fmt_fr(rs$ari), " & ",
    fmt_pair(ra$alpha, ra$omega), " & ",
    fmt_fr(ra$silhouette), " & ", fmt_fr(ra$ari), " & ",
    fmt_fr(gap_ari), " \\\\"
  ))
}

out_path <- file.path(root, "docs/generated/paradox_silhouette_ari.tex")
dir.create(dirname(out_path), recursive = TRUE, showWarnings = FALSE)

git_sha <- tryCatch(
  system2("git", c("-C", root, "rev-parse", "--short", "HEAD"), stdout = TRUE, stderr = FALSE),
  error = function(e) character(0)
)
stamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")

rel <- function(abs_path) {
  sub(paste0("^", gsub("([][])","\\\\\\1", root), "/"), "", abs_path, perl = FALSE)
}

lines <- c(
  "% ---------------------------------------------------------------------------",
  "% Fichier généré — NE PAS ÉDITER À LA MAIN",
  paste0("% Généré le : ", stamp),
  if (length(git_sha)) paste0("% Git : ", git_sha[1]) else "% Git : (non disponible)",
  "% Regénérer : Rscript scripts/generate_rapport_stage_paradox_tex.R",
  "% ---------------------------------------------------------------------------",
  "",
  "\\begin{table}[H]",
  "  \\centering",
  "  \\small",
  "  \\renewcommand{\\arraystretch}{1.2}",
  "  \\begin{tabular}{llccccccc}",
  "    \\toprule",
  "    \\textbf{Jeu} & $K$",
  "    & \\multicolumn{3}{c}{\\textbf{Choix par silhouette} ($\\Dw$, PAM)}",
  "    & \\multicolumn{3}{c}{\\textbf{Maximum d'ARI sur la grille} (éval.)}",
  "    & $\\Delta$\\,ARI \\\\",
  "    \\cmidrule(lr){3-5}\\cmidrule(lr){6-8}",
  "    & & $(\\alpha,\\omega)$ & $\\bar s$ & ARI & $(\\alpha,\\omega)$ & $\\bar s$ & ARI & \\\\",
  "    \\midrule",
  rows_tex,
  "    \\bottomrule",
  "  \\end{tabular}",
  "  \\caption{Paradoxe silhouette\\,/\\,ARI sur la stratégie~B ($\\Dw$, grille $21\\times 21$, pas $0{,}05$, $k=K$ fixé à la vérité terrain pour l'évaluation).",
  "  Le bloc central droit (maximum d'ARI sur la grille) est un \\emph{contrefactuel}~:",
  "  il suppose que l'on pourrait optimiser $(\\alpha,\\omega)$ pour l'ARI, ce qui exige des étiquettes et ne correspond pas au réglage non supervisé.",
  "  La dernière colonne donne $\\Delta\\mathrm{ARI} = \\mathrm{ARI}_{\\max} - \\mathrm{ARI}_{\\mathrm{sil}}$ (toujours $\\ge 0$).}",
  "  \\label{tab:paradox_silhouette_ari}",
  "\\end{table}",
  ""
)

writeLines(lines, out_path, useBytes = FALSE)
message("Écrit : ", out_path)
