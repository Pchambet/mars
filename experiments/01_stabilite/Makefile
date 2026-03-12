# Compilation du rapport stabilité
# Usage : make (depuis experiments/01_stabilite/)

rapport_stabilite.pdf: rapport_stabilite.tex
	pdflatex rapport_stabilite
	pdflatex rapport_stabilite

clean:
	rm -f rapport_stabilite.aux rapport_stabilite.log rapport_stabilite.out
	rm -f rapport_stabilite.toc rapport_stabilite.synctex.gz
