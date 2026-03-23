# Makefile — Compilation des rapports LaTeX
# Usage : make (depuis docs/) ou make -C docs

TEX_FILES = resume_donnees_fonctionnelles rapport_distances rapport_canadian_weather rapport_synthese rapport_stage

.PHONY: all clean benchmark-tex paradox-tex ch6-real-tex

all: $(addsuffix .pdf,$(TEX_FILES))

# Tableau ARI ch.5 (depuis CSV benchmark simulé) — lancer avant `make` si les CSV ont changé
benchmark-tex:
	cd .. && Rscript scripts/generate_rapport_stage_benchmark_tex.R

# Tableau paradoxe silhouette / ARI ch.4 — relancer si la grille ou les jeux réels changent
paradox-tex:
	cd .. && Rscript scripts/generate_rapport_stage_paradox_tex.R

# Tableau ch.6 (trois jeux réels) — exécuter d'abord le pipeline avec
# MARS_EXPORT_COMPARAISON=1 pour canadian, growth, tecator
ch6-real-tex:
	cd .. && Rscript scripts/generate_ch6_three_games_table_tex.R

%.pdf: %.tex
	pdflatex $<
	pdflatex $<

clean:
	rm -f *.aux *.log *.out *.toc *.synctex.gz *.fdb_latexmk *.fls
