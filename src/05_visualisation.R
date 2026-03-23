# ============================================================================
# ÉTAPE 5 : VISUALISATION COMPLÈTE
# ============================================================================
#
# Figures générées :
#   1. Courbe GCV (choix de λ)
#   2. Courbes lissées colorées par région
#   3. Fonctions propres φ_k(t) — modes de variation
#   4. Scores FPCA (ξ1 vs ξ2)
#   5. Heatmap 2D (α, ω) — stratégie B
#   5b. Grid search α — stratégie C
#   6. Comparaison visuelle des stratégies + baselines
#   7. Courbes colorées par cluster (pour chaque stratégie)
#
# ============================================================================

cat("\n--- Étape 05 : Visualisation ---\n")

if (!exists("comparaison")) source("src/04_clustering.R")

# Dossier de sortie par dataset
if (!exists("dataset_name")) dataset_name <- "dataset"
fig_dir <- file.path("figures", dataset_name)
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)

# Palette de couleurs générique pour clusters/régions
niveaux <- levels(regions)
palette_base <- c("#1b9e77", "#d95f02", "#7570b3", "#e7298a",
                  "#66a61e", "#e6ab02", "#a6761d", "#666666")
palette_regions <- setNames(palette_base[1:length(niveaux)], niveaux)
couleurs_vrai <- palette_regions[as.character(regions)]
palette_cluster <- palette_base[1:n_clusters]

# Labels génériques (peuvent être redéfinis dans le preprocess)
if (!exists("xlab_courbe")) xlab_courbe <- "t"
if (!exists("ylab_courbe")) ylab_courbe <- "X(t)"

# ═══════════════════════════════════════════════════════════════════════════
# FIG 1 : Courbe GCV — Choix de λ
# ═══════════════════════════════════════════════════════════════════════════
png(file.path(fig_dir, "fig01_gcv.png"), width = 800, height = 500)
plot(log10(lissage_params$lambdas_grille), lissage_params$gcv_scores,
     type = "l", lwd = 2, col = "steelblue",
     main = "Sélection de λ par GCV", xlab = expression(log[10](lambda)),
     ylab = "Score GCV (erreur de validation croisée)")
abline(v = log10(lissage_params$lambda_gcv), col = "red", lwd = 2, lty = 2)
abline(v = log10(lissage_params$lambda_opt), col = "darkgreen", lwd = 2)
legend("topright",
       legend = c(sprintf("λ_GCV = %.1f", lissage_params$lambda_gcv),
                  sprintf("λ retenu = %.1f", lissage_params$lambda_opt)),
       col = c("red", "darkgreen"), lwd = 2, lty = c(2, 1))
dev.off()

# ═══════════════════════════════════════════════════════════════════════════
# FIG 2 : Courbes lissées colorées par vérité terrain
# ═══════════════════════════════════════════════════════════════════════════
png(file.path(fig_dir, "fig02_courbes_regions.png"), width = 900, height = 500)
plot(X_hat, col = couleurs_vrai, lwd = 1.5, lty = 1,
     main = paste0("Courbes lissées (", dataset_name, ") — Vérité terrain"),
     xlab = xlab_courbe, ylab = ylab_courbe)
legend("bottomright", legend = names(palette_regions),
       col = palette_regions, lwd = 3, cex = 0.9)
dev.off()

# ═══════════════════════════════════════════════════════════════════════════
# FIG 3 : Fonctions propres — modes de variation
# ═══════════════════════════════════════════════════════════════════════════
png(file.path(fig_dir, "fig03_fonctions_propres.png"), width = 900, height = 700)
par(mfrow = c(2, 2))
for (k in 1:min(K, 4)) {
  plot(phi_k[k], lwd = 2, col = "darkblue",
       main = sprintf("φ_%d(t) — %.1f%% de variance", k, var_expliquee[k] * 100),
       xlab = xlab_courbe, ylab = "")
  abline(h = 0, lty = 3, col = "gray50")
}
par(mfrow = c(1, 1))
dev.off()

# ═══════════════════════════════════════════════════════════════════════════
# FIG 4 : Scores FPCA (ξ1 vs ξ2), vérité terrain
# ═══════════════════════════════════════════════════════════════════════════
png(file.path(fig_dir, "fig04_scores_fpca.png"), width = 700, height = 600)
if (K >= 2) {
  plot(scores_fpca[, 1], scores_fpca[, 2],
       col = couleurs_vrai, pch = 19, cex = 1.5,
       main = paste0("Scores FPCA (ξ₁ vs ξ₂) — ", dataset_name),
       xlab = sprintf("PC1 (%.1f%%)", var_expliquee[1] * 100),
       ylab = sprintf("PC2 (%.1f%%)", var_expliquee[2] * 100))
  text(scores_fpca[, 1], scores_fpca[, 2], labels = noms_stations,
       cex = 0.6, pos = 3, col = "gray30")
  legend("topright", legend = names(palette_regions),
         col = palette_regions, pch = 19, cex = 0.9)
} else {
  stripchart(scores_fpca[, 1] ~ regions, method = "jitter",
             col = palette_regions, pch = 19, cex = 1.2,
             main = paste0("Score PC1 par classe — ", dataset_name),
             xlab = sprintf("PC1 (%.1f%%)", var_expliquee[1] * 100))
}
dev.off()

# ═══════════════════════════════════════════════════════════════════════════
# FIG 5 : Heatmap 2D (α, ω) — Stratégie B (Dw)
# ═══════════════════════════════════════════════════════════════════════════
png(file.path(fig_dir, "fig05_gridsearch_2D.png"), width = 900, height = 700)
par(mfrow = c(1, 2), mar = c(5, 5, 4, 2))

# --- Heatmap Silhouette ---
mat_sil <- matrix(resultats_B$grid$silhouette,
                  nrow = length(alphas), ncol = length(omegas),
                  byrow = FALSE)
image(alphas, omegas, mat_sil,
      col = hcl.colors(50, "YlOrRd", rev = TRUE),
      main = "Stratégie B — Silhouette",
      xlab = expression(alpha ~ "(D0/D1)"),
      ylab = expression(omega ~ "(fonctionnel/vectoriel)"))
contour(alphas, omegas, mat_sil, add = TRUE, labcex = 0.8)
points(alpha_best_B, omega_best_B, pch = 4, cex = 2, lwd = 3, col = "black")

# --- Heatmap ARI ---
mat_ari <- matrix(resultats_B$grid$ari,
                  nrow = length(alphas), ncol = length(omegas),
                  byrow = FALSE)
image(alphas, omegas, mat_ari,
      col = hcl.colors(50, "YlOrRd", rev = TRUE),
      main = "Stratégie B — ARI",
      xlab = expression(alpha ~ "(D0/D1)"),
      ylab = expression(omega ~ "(fonctionnel/vectoriel)"))
contour(alphas, omegas, mat_ari, add = TRUE, labcex = 0.8)
points(alpha_best_B, omega_best_B, pch = 4, cex = 2, lwd = 3, col = "black")

par(mfrow = c(1, 1))
dev.off()

# ═══════════════════════════════════════════════════════════════════════════
# FIG 5b : Grid search α — Stratégie C (DK)
# ═══════════════════════════════════════════════════════════════════════════
png(file.path(fig_dir, "fig05b_DK_alpha.png"), width = 800, height = 500)
par(mar = c(5, 4, 4, 4) + 0.1)
plot(resultats_C$grid$alpha, resultats_C$grid$silhouette,
     type = "b", pch = 19, col = "steelblue", lwd = 2,
     main = expression("Stratégie C : choix de " * alpha * " dans DK"),
     xlab = expression(alpha ~ "(poids de D1 dans Dp)"),
     ylab = "Silhouette moyenne")
par(new = TRUE)
plot(resultats_C$grid$alpha, resultats_C$grid$ari,
     type = "b", pch = 17, col = "coral", lwd = 2,
     axes = FALSE, xlab = "", ylab = "")
axis(4, col = "coral", col.axis = "coral")
mtext("ARI", side = 4, line = 3, col = "coral")
abline(v = alpha_best_C, col = "gray30", lty = 2)
legend("topleft", legend = c("Silhouette", "ARI"),
       col = c("steelblue", "coral"), pch = c(19, 17), lwd = 2)
dev.off()

# ═══════════════════════════════════════════════════════════════════════════
# FIG 6 : Barplot comparatif (baselines + A/B/C + HFV+DK)
# ═══════════════════════════════════════════════════════════════════════════
png(file.path(fig_dir, "fig06_comparaison.png"), width = 1000, height = 520)
par(mfrow = c(1, 2), mar = c(10, 4, 4, 1))

cols6 <- c("gray70", "gray70", "#4daf4a", "#377eb8", "#e41a1c", "#984ea3")
barplot(comparaison$Silhouette, names.arg = comparaison$Strategie,
        col = cols6,
        main = "Silhouette moyenne", las = 2, ylim = c(0, 1))

barplot(comparaison$ARI, names.arg = comparaison$Strategie,
        col = cols6,
        main = "ARI (vs régions)", las = 2, ylim = c(-0.1, 1))
abline(h = 0, lty = 3)

par(mfrow = c(1, 1))
dev.off()

# ═══════════════════════════════════════════════════════════════════════════
# FIG 7 : Courbes colorées par cluster — chaque stratégie (+ HFV+DK)
# ═══════════════════════════════════════════════════════════════════════════
png(file.path(fig_dir, "fig07_courbes_par_cluster.png"), width = 1400, height = 900)
par(mfrow = c(3, 3), mar = c(4, 4, 3, 1))

# Vérité terrain
plot(X_hat, col = couleurs_vrai, lwd = 1.2, main = "Vérité terrain",
     xlab = xlab_courbe, ylab = ylab_courbe)

# D0 seul
plot(X_hat, col = palette_cluster[pam_D0$clustering], lwd = 1.2,
     main = sprintf("D0 seul (ARI=%.2f)", ari_D0), xlab = xlab_courbe, ylab = ylab_courbe)

# Ds seul
plot(X_hat, col = palette_cluster[pam_Ds$clustering], lwd = 1.2,
     main = sprintf("Ds seul (ARI=%.2f)", ari_Ds), xlab = xlab_courbe, ylab = ylab_courbe)

# Stratégie A
plot(X_hat, col = palette_cluster[resultats_A$labels], lwd = 1.2,
     main = sprintf("A: FPCA+Z (ARI=%.2f)", ari_A), xlab = xlab_courbe, ylab = ylab_courbe)

# Stratégie B
plot(X_hat, col = palette_cluster[resultats_B$labels], lwd = 1.2,
     main = sprintf("B: Dw α=%.1f ω=%.1f (ARI=%.2f)",
                    alpha_best_B, omega_best_B, resultats_B$ari),
     xlab = xlab_courbe, ylab = ylab_courbe)

# Stratégie C
plot(X_hat, col = palette_cluster[resultats_C$labels], lwd = 1.2,
     main = sprintf("C: DK α=%.1f (ARI=%.2f)", alpha_best_C, ari_C),
     xlab = xlab_courbe, ylab = ylab_courbe)

# HFV + DK (reconstruit)
plot(X_hat, col = palette_cluster[resultats_DK_hfv$labels], lwd = 1.2,
     main = sprintf("HFV+DK (ARI=%.2f)", resultats_DK_hfv$ari),
     xlab = xlab_courbe, ylab = ylab_courbe)

# Deux cases vides pour compléter la grille 3x3
plot.new()

plot.new()

par(mfrow = c(1, 1))
dev.off()

# ═══════════════════════════════════════════════════════════════════════════
cat(sprintf("\n  Figures générées dans %s/ :\n", fig_dir))
figs <- list.files(fig_dir, pattern = "^fig.*\\.png$")
for (f in figs) cat(sprintf("    - %s\n", f))
cat("\n=== Pipeline terminé ===\n")