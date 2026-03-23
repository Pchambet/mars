#!/usr/bin/env Rscript
# Génère docs/generated/benchmark_ari_by_scenario.tex depuis les CSV du benchmark
# simulé (expérience 03). À relancer après tout nouveau run de
# experiments/03_simulated_hybride/benchmark_all_methods_simulated.R
#
# Usage (depuis la racine du dépôt) :
#   Rscript scripts/generate_rapport_stage_benchmark_tex.R

find_repo_root <- function() {
  d <- normalizePath(getwd(), winslash = "/")
  cand <- c(
    d,
    normalizePath(file.path(d, ".."), winslash = "/"),
    normalizePath(file.path(d, "..", ".."), winslash = "/")
  )
  for (r in cand) {
    p <- file.path(r, "experiments/03_simulated_hybride/results/metrics_summary_by_scenario_method.csv")
    if (file.exists(p)) return(r)
  }
  stop("Exécuter ce script depuis la racine du dépôt (ou docs/), ou définir MARS_ROOT.")
}
root <- Sys.getenv("MARS_ROOT", unset = "")
if (!nzchar(root)) root <- find_repo_root()

summary_path <- file.path(
  root, "experiments/03_simulated_hybride/results/metrics_summary_by_scenario_method.csv"
)
global_path <- file.path(
  root, "experiments/03_simulated_hybride/results/metrics_global_average_by_method.csv"
)
out_path <- file.path(root, "docs/generated/benchmark_ari_by_scenario.tex")
dir.create(dirname(out_path), recursive = TRUE, showWarnings = FALSE)

stopifnot(file.exists(summary_path), file.exists(global_path))

fmt_fr <- function(x) {
  s <- sprintf("%.3f", as.numeric(x))
  parts <- strsplit(s, ".", fixed = TRUE)[[1L]]
  paste0(parts[[1L]], "{,}", parts[[2L]])
}

summ <- read.csv(summary_path, stringsAsFactors = FALSE)
glob <- read.csv(global_path, stringsAsFactors = FALSE)

scenarios <- c("S1", "S2", "S3", "S4")
methods_order <- c(
  "D0", "Ds", "A", "B_silopt", "C_DK_ancien", "D1", "Df_silopt", "DK_reconstruit"
)
labels <- c(
  "Baseline $D_0$",
  "Baseline $D_s$",
  "Stratégie A (FPCA$+Z$)",
  "Stratégie B ($\\Dw$, sil.)",
  "Stratégie C ($\\DK$ surface)",
  "Baseline $D_1$",
  "$D_f(\\alpha)$ (sil.)",
  "HFV $+$ $\\DK$ (reconstr.)"
)
names(labels) <- methods_order

wide <- list()
for (m in methods_order) {
  row_g <- glob[glob$method == m, , drop = FALSE]
  if (nrow(row_g) != 1L) stop("Méthode manquante dans global: ", m)
  cells <- character(length(scenarios))
  for (i in seq_along(scenarios)) {
    sc <- scenarios[i]
    sub <- summ[summ$scenario == sc & summ$method == m, "ari_mean", drop = TRUE]
    if (length(sub) != 1L) stop("Valeur manquante: ", sc, " / ", m)
    cells[i] <- fmt_fr(sub)
  }
  wide[[m]] <- list(
    label = labels[[m]],
    cells = cells,
    moy = fmt_fr(row_g$ari)
  )
}

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
  paste0("% Source : ", rel(summary_path)),
  paste0("%        + ", rel(global_path)),
  paste0("% Généré le : ", stamp),
  if (length(git_sha)) paste0("% Git : ", git_sha[1]) else "% Git : (non disponible)",
  "% Regénérer : Rscript scripts/generate_rapport_stage_benchmark_tex.R",
  "% ---------------------------------------------------------------------------"
)

lines <- c(lines, "", "\\begin{table}[H]", "\\centering", "\\renewcommand{\\arraystretch}{1.25}")

tab <- c(
  "\\begin{tabular}{lcccc|c}",
  "  \\toprule",
  "  \\textbf{Méthode} & \\textbf{S1} & \\textbf{S2} & \\textbf{S3} & \\textbf{S4} & \\textbf{Moy. glob.} \\\\",
  "  \\midrule"
)

for (m in methods_order) {
  w <- wide[[m]]
  tab <- c(
    tab,
    paste0(
      "  ", w$label, " & ",
      paste(w$cells, collapse = " & "), " & ", w$moy, " \\\\"
    )
  )
}

tab <- c(
  tab,
  "  \\bottomrule",
  "\\end{tabular}"
)

lines <- c(lines, tab)

lines <- c(
  lines,
  "\\caption{ARI moyen par scénario et par méthode ($50$ répétitions par scénario,",
  "  $n=300$, $K=3$, $p=20$). Grille $\\alpha$ (et $(\\alpha,\\omega)$ pour la stratégie~B)",
  "  : $21$ valeurs sur $[0,1]$ (pas $0{,}05$, soit $21\\times 21$ couples pour~B).",
  "  Hyperparamètres choisis par silhouette (stratégies B, C, $D_f(\\alpha)$)~;",
  "  l'ARI sert uniquement à l'évaluation.",
  "  \\emph{Moy. glob.}~: moyenne sur l'ensemble des $200$ runs ($4\\times 50$), fichier",
  "  \\texttt{metrics\\_global\\_average\\_by\\_method.csv}.}",
  "\\label{tab:ari_scenarios}"
)

lines <- c(lines, "\\end{table}", "")

writeLines(lines, out_path, useBytes = FALSE)
message("Écrit : ", out_path)
