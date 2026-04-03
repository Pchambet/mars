# ============================================================================
# Expérience 01 — nselectboot sur données simulées (aligné exp. 3)
# ============================================================================
#
# Complément contrôlé : k_vrai et labels connus (Cas2_deriv).
# N’altère pas les scripts ni les sorties de experiments/03_simulated_hybride/.
#
# Paramètres nselectboot — PARITÉ avec les 3 jeux réels (run_nselectboot.R) :
#   B_NSELECT = 150, ALPHAS_NB = OMEGAS_NB = seq(0, 1, by = 0.05) [21×21], K_RANGE = 2:6
#   Toute autre grille / B doit être explicitement levée avec NSELECTBOOT_SIM_RELAXED <- TRUE
#   (usage réservé au débogage — pas comparable aux résultats réels).
#
# Autres paramètres :
#   P_Z_SIM — défaut 20 (comme benchmark exp. 3)
#   SEEDS_SIM — défaut 1L ; alignement exp. 3 complet : SEEDS_SIM <- 1:50
#   REFERENCE_SEED — défaut = premier élément de SEEDS_SIM (CSV référence pour heatmaps)
#
# Usage : depuis la racine du dépôt
#   source("experiments/01_instabilite/run_nselectboot_simulated.R")
#
# ============================================================================

library(cluster)
library(mclust)
library(fpc)

if (!exists("B_NSELECT")) B_NSELECT <- 150L
if (!exists("ALPHAS_NB")) ALPHAS_NB <- seq(0, 1, by = 0.05)
if (!exists("OMEGAS_NB")) OMEGAS_NB <- seq(0, 1, by = 0.05)
if (!exists("K_RANGE")) K_RANGE <- 2:6
if (!exists("P_Z_SIM")) P_Z_SIM <- 20L
# Par défaut : 1 seed ; alignement exp. 3 complet : SEEDS_SIM <- 1:50
if (!exists("SEEDS_SIM")) SEEDS_SIM <- 1L
if (!exists("REFERENCE_SEED")) REFERENCE_SEED <- as.integer(SEEDS_SIM[1L])

# --- Contrôle : mêmes paramètres nselectboot que run_nselectboot.R (comparaison avec données réelles) ---
if (!exists("NSELECTBOOT_SIM_RELAXED")) NSELECTBOOT_SIM_RELAXED <- FALSE
.ref_alph_omega <- seq(0, 1, by = 0.05)
.ref_krange <- 2:6
if (!isTRUE(NSELECTBOOT_SIM_RELAXED)) {
  if (length(B_NSELECT) != 1L || as.integer(B_NSELECT) != 150L) {
    stop("run_nselectboot_simulated : B_NSELECT doit être 150 (identique aux 3 jeux réels). ",
         "Débogage uniquement : NSELECTBOOT_SIM_RELAXED <- TRUE avant source().")
  }
  if (length(ALPHAS_NB) != 21L || length(OMEGAS_NB) != 21L) {
    stop("run_nselectboot_simulated : la grille (α,ω) doit être 21×21 (seq(0,1,0.05)). ",
         "Débogage : NSELECTBOOT_SIM_RELAXED <- TRUE.")
  }
  if (!isTRUE(all.equal(as.numeric(ALPHAS_NB), as.numeric(.ref_alph_omega))) ||
      !isTRUE(all.equal(as.numeric(OMEGAS_NB), as.numeric(.ref_alph_omega)))) {
    stop("run_nselectboot_simulated : ALPHAS_NB et OMEGAS_NB doivent être seq(0, 1, by = 0.05). ",
         "Débogage : NSELECTBOOT_SIM_RELAXED <- TRUE.")
  }
  if (!isTRUE(all.equal(as.integer(K_RANGE), as.integer(.ref_krange)))) {
    stop("run_nselectboot_simulated : K_RANGE doit être 2:6. Débogage : NSELECTBOOT_SIM_RELAXED <- TRUE.")
  }
}

scenario_grid <- list(
  S1 = c(1.0, 1.0, 1.0),
  S2 = c(1.0, 1.0, 0.5),
  S3 = c(0.5, 0.5, 1.0),
  S4 = c(0.5, 0.5, 0.5)
)

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

results_dir <- "experiments/01_instabilite/results_simulated"
dir.create(results_dir, showWarnings = FALSE, recursive = TRUE)

cat("\n")
cat("══════════════════════════════════════════════════════════════════════\n")
cat("  EXPÉRIENCE 01 — NSELECTBOOT (Fang-Wang) — DONNÉES SIMULÉES (exp. 3)\n")
cat("══════════════════════════════════════════════════════════════════════\n\n")
cat(sprintf("  B = %d, k ∈ {%s}\n", B_NSELECT, paste(K_RANGE, collapse = ",")))
cat(sprintf("  Grille (α, ω) : %d × %d points (identique run_nselectboot.R / 3 jeux réels)\n",
            length(ALPHAS_NB), length(OMEGAS_NB)))
if (isTRUE(NSELECTBOOT_SIM_RELAXED)) {
  cat("  *** NSELECTBOOT_SIM_RELAXED = TRUE : grille/B comparables aux jeux réels ? NON ***\n")
}
cat(sprintf("  P_Z_SIM = %d | seeds = {%s...} (n=%d)\n", P_Z_SIM, SEEDS_SIM[1], length(SEEDS_SIM)))
cat(sprintf("  Scénarios : %s\n\n", paste(names(scenario_grid), collapse = ", ")))

grille_nb_template <- expand.grid(alpha = ALPHAS_NB, omega = OMEGAS_NB)
all_runs <- list()
summary_rows <- list()
i_row <- 1L
i_sum <- 1L

for (sc_name in names(scenario_grid)) {
  DELTA_SC <- scenario_grid[[sc_name]]
  cat(sprintf("\n=== Scénario %s / delta=(%.1f, %.1f, %.1f) ===\n",
              sc_name, DELTA_SC[1], DELTA_SC[2], DELTA_SC[3]))

  for (seed in SEEDS_SIM) {
    SEED_SIM <- seed
    NC_SIM <- c(100, 100, 100)
    LEN_T_SIM <- 60
    DELTA_SIM <- DELTA_SC
    SIGMA2_SIM <- 0.2
    TAU2_SIM <- 0.2

    quiet_source("src/00_preprocess_simulated.R")
    quiet_source("src/01_lissage.R")
    quiet_source("src/02_fpca.R")
    quiet_source("src/03_distances.R")

    labels_vrai <- as.integer(regions)
    k_vrai <- length(unique(labels_vrai))

    grille_nb <- grille_nb_template
    grille_nb$k_opt <- NA
    grille_nb$instability_min <- NA
    grille_nb$stabk <- NA

    n_grid <- nrow(grille_nb)
    prog_step <- max(1L, as.integer(ceiling(n_grid / 15)))  # ~15 lignes de progression par scénario
    for (idx in seq_len(n_grid)) {
      if (idx == 1L || idx == n_grid || (idx %% prog_step == 0L)) {
        cat(sprintf("    grille nselectboot %d / %d\n", idx, n_grid))
      }
      a <- grille_nb$alpha[idx]
      w <- grille_nb$omega[idx]

      Dp <- sqrt((1 - a) * D0_norm^2 + a * D1_norm^2)
      Dw <- sqrt(w * Dp^2 + (1 - w) * Ds_norm^2)
      D_dist <- as.dist(Dw)

      res <- tryCatch({
        nselectboot(D_dist,
          B = B_NSELECT,
          distances = TRUE,
          clustermethod = claraCBI,
          usepam = TRUE,
          classification = "centroid",
          centroidname = NULL,
          krange = K_RANGE,
          count = FALSE
        )
      }, error = function(e) {
        warning(sprintf("nselectboot erreur (α=%.1f, ω=%.1f): %s", a, w, e$message))
        NULL
      })

      if (is.null(res)) {
        grille_nb$k_opt[idx] <- NA
        grille_nb$instability_min[idx] <- NA
        grille_nb$stabk[idx] <- NA
        next
      }

      grille_nb$k_opt[idx] <- res$kopt
      grille_nb$instability_min[idx] <- min(res$stabk)
      grille_nb$stabk[idx] <- paste(round(res$stabk, 4), collapse = ";")
    }

    # Ligne par run (scénario × seed)
    block <- data.frame(
      scenario = sc_name,
      seed = as.integer(seed),
      k_vrai = k_vrai,
      grille_nb,
      stringsAsFactors = FALSE
    )
    for (r in seq_len(nrow(block))) {
      all_runs[[i_row]] <- block[r, , drop = FALSE]
      i_row <- i_row + 1L
    }

    # Résumé
    ok <- !is.na(grille_nb$k_opt)
    prop_match <- if (any(ok)) mean(grille_nb$k_opt[ok] == k_vrai, na.rm = TRUE) else NA_real_
    kv <- grille_nb$k_opt[!is.na(grille_nb$k_opt)]
    mode_k <- if (length(kv)) as.integer(names(which.max(table(kv)))) else NA_integer_
    summary_rows[[i_sum]] <- data.frame(
      scenario = sc_name,
      seed = as.integer(seed),
      k_vrai = k_vrai,
      prop_grid_k_match = prop_match,
      median_k_opt = median(grille_nb$k_opt, na.rm = TRUE),
      mode_k_opt = mode_k,
      stringsAsFactors = FALSE
    )
    i_sum <- i_sum + 1L

    cat(sprintf("  seed %d : k_vrai=%d, P(k_opt=k_vrai) sur grille = %.3f\n",
                seed, k_vrai, prop_match))

    # Fichier « référence » pour heatmaps (même format que nselectboot_<dataset>.csv)
    if (as.integer(seed) == as.integer(REFERENCE_SEED)) {
      ref_path <- file.path(results_dir,
        sprintf("nselectboot_simulated_%s_seed%d.csv", sc_name, REFERENCE_SEED))
      write.csv(grille_nb, ref_path, row.names = FALSE)
      cat(sprintf("    → référence heatmap : %s\n", basename(ref_path)))
    }
  }
}

df_all <- do.call(rbind, all_runs)
df_summary <- do.call(rbind, summary_rows)

path_all <- file.path(results_dir, "nselectboot_simulated_all_runs.csv")
path_summary <- file.path(results_dir, "nselectboot_simulated_summary_by_run.csv")
write.csv(df_all, path_all, row.names = FALSE)
write.csv(df_summary, path_summary, row.names = FALSE)

cat("\n")
cat("══════════════════════════════════════════════════════════════════════\n")
cat(sprintf("  Sauvegardé : %s\n", path_all))
cat(sprintf("  Sauvegardé : %s\n", path_summary))
cat("  (Références par scénario : nselectboot_simulated_S*_seed*.csv)\n")
cat("══════════════════════════════════════════════════════════════════════\n\n")
