# Compilation du rapport d’instabilité (exp. 01)
# Usage : make (depuis experiments/01_instabilite/)

rapport_instabilite.pdf: rapport_instabilite.tex
	pdflatex rapport_instabilite
	pdflatex rapport_instabilite

clean:
	rm -f rapport_instabilite.aux rapport_instabilite.log rapport_instabilite.out
	rm -f rapport_instabilite.toc rapport_instabilite.synctex.gz
