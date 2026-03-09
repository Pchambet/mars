# Makefile — Compilation des rapports LaTeX
# Usage : make (depuis docs/) ou make -C docs

TEX_FILES = resume_donnees_fonctionnelles rapport_distances rapport_canadian_weather rapport_synthese

.PHONY: all clean

all: $(addsuffix .pdf,$(TEX_FILES))

%.pdf: %.tex
	pdflatex $<
	pdflatex $<

clean:
	rm -f *.aux *.log *.out *.toc *.synctex.gz *.fdb_latexmk *.fls
