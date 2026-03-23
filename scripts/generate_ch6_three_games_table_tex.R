#!/usr/bin/env Rscript
# Lit docs/exports/comparaison_{canadian_weather,growth,tecator}.csv
# (produits par MARS_EXPORT_COMPARAISON=1 + src/main.R) et génère
# docs/generated/ch6_real_three_games_table.tex

find_repo_root <- function() {
  d <- normalizePath(getwd(), winslash = "/")
  for (r in c(d, normalizePath(file.path(d, ".."), winslash = "/"))) {
    if (file.exists(file.path(r, "src/main.R"))) return(r)
  }
  stop("Exécuter depuis la racine du dépôt.")
}

root <- Sys.getenv("MARS_ROOT", unset = "")
if (!nzchar(root)) root <- find_repo_root()

fmt_fr <- function(x, digits = 3L) {
  s <- sprintf(paste0("%.", digits, "f"), as.numeric(x))
  parts <- strsplit(s, ".", fixed = TRUE)[[1L]]
  paste0(parts[[1L]], "{,}", parts[[2L]])
}

pick <- function(df, pattern) {
  i <- grep(pattern, df$Strategie, fixed = TRUE)
  if (length(i) != 1L) stop("Ligne introuvable : ", pattern)
  df[i, ]
}

files <- list(
  Canadian = file.path(root, "docs/exports/comparaison_canadian_weather.csv"),
  Growth   = file.path(root, "docs/exports/comparaison_growth.csv"),
  Tecator  = file.path(root, "docs/exports/comparaison_tecator.csv")
)
for (nm in names(files)) {
  if (!file.exists(files[[nm]])) {
    stop("Fichier manquant : ", files[[nm]],
         "\nLancer : MARS_EXPORT_COMPARAISON=1 avec DATASET pour chaque jeu.")
  }
}

meta <- data.frame(
  key = c("Canadian", "Growth", "Tecator"),
  label = c("Canadian Weather", "Growth", "Tecator"),
  nk = c("35 / 4", "93 / 2", "215 / 3"),
  stringsAsFactors = FALSE
)

lines_row <- character()
for (r in seq_len(nrow(meta))) {
  k <- meta$key[r]
  df <- read.csv(files[[k]], stringsAsFactors = FALSE)
  d0 <- pick(df, "Baseline D0")
  ds <- pick(df, "Baseline Ds")
  sa <- pick(df, "A (FPCA+Z)")
  # B et C : premier match
  sb <- df[grepl("^B \\(", df$Strategie), ][1, ]
  sc <- df[grepl("^C \\(DK", df$Strategie), ][1, ]
  sh <- pick(df, "HFV + DK (reconstr.)")

  aris <- c(d0$ARI, ds$ARI, sa$ARI, sb$ARI, sc$ARI, sh$ARI)
  ib <- which.max(aris)

  cell <- function(sil, ari, idx, j) {
    ari_tex <- fmt_fr(ari)
    if (j == ib) ari_tex <- paste0("\\textbf{", ari_tex, "}")
    paste(fmt_fr(sil), "&", ari_tex)
  }

  parts <- c(
    cell(d0$Silhouette, d0$ARI, ib, 1),
    cell(ds$Silhouette, ds$ARI, ib, 2),
    cell(sa$Silhouette, sa$ARI, ib, 3),
    cell(sb$Silhouette, sb$ARI, ib, 4),
    cell(sc$Silhouette, sc$ARI, ib, 5),
    cell(sh$Silhouette, sh$ARI, ib, 6)
  )
  lines_row <- c(lines_row, paste0(
    "  ", meta$label[r], " & ", meta$nk[r], " & ",
    paste(parts, collapse = " & "), " \\\\"
  ))
}

git_sha <- tryCatch(
  system2("git", c("-C", root, "rev-parse", "--short", "HEAD"), stdout = TRUE, stderr = FALSE),
  error = function(e) character(0)
)
stamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")

out_path <- file.path(root, "docs/generated/ch6_real_three_games_table.tex")
dir.create(dirname(out_path), recursive = TRUE, showWarnings = FALSE)

hdr <- c(
  "% ---------------------------------------------------------------------------",
  "% Fichier généré — NE PAS ÉDITER À LA MAIN",
  paste0("% Généré le : ", stamp),
  if (length(git_sha)) paste0("% Git : ", git_sha[1]) else "% Git : (non disponible)",
  "% Source : docs/exports/comparaison_*.csv (MARS_EXPORT_COMPARAISON=1 + src/main.R)",
  "% Regénérer : MARS_EXPORT_COMPARAISON=1 pour canadian, growth, tecator puis",
  "%             Rscript scripts/generate_ch6_three_games_table_tex.R",
  "% ---------------------------------------------------------------------------",
  "",
  "\\begin{table}[H]",
  "  \\centering",
  "  \\small",
  "  \\renewcommand{\\arraystretch}{1.25}",
  "  \\resizebox{\\textwidth}{!}{%",
  "  \\begin{tabular}{ll cc cc cc cc cc cc}",
  "    \\toprule",
  "    & & \\multicolumn{2}{c}{$D_0$} & \\multicolumn{2}{c}{$D_s$}",
  "    & \\multicolumn{2}{c}{A} & \\multicolumn{2}{c}{B ($\\Dw$)} & \\multicolumn{2}{c}{C ($\\DK$)}",
  "    & \\multicolumn{2}{c}{HFV$+\\DK$} \\\\",
  "    \\cmidrule(lr){3-4}\\cmidrule(lr){5-6}\\cmidrule(lr){7-8}\\cmidrule(lr){9-10}\\cmidrule(lr){11-12}\\cmidrule(lr){13-14}",
  "    \\textbf{Jeu} & $n$ / $k$ & Sil. & ARI & Sil. & ARI & Sil. & ARI & Sil. & ARI & Sil. & ARI & Sil. & ARI \\\\",
  "    \\midrule"
)

ftr <- c(
  "    \\bottomrule",
  "  \\end{tabular}",
  "  }",
  "  \\caption{Résultats sur trois jeux publics (même protocole, graine $42$).",
  "  Stratégies B et C~: $(\\alpha,\\omega)$ ou $\\alpha$ choisis par silhouette.",
  "  Colonne \\emph{HFV$+\\DK$}~: reconstruction par ACP hybride (covariance croisée) puis distance à noyau sur courbes reconstruites et~$Z$ (chapitre~3).",
  "  \\textbf{Gras}~: meilleur ARI par ligne (évaluation à étiquettes).}",
  "  \\label{tab:resultats_reels}",
  "\\end{table}",
  ""
)

writeLines(c(hdr, lines_row, ftr), out_path, useBytes = FALSE)
message("Écrit : ", out_path)
