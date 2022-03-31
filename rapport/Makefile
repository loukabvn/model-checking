SHELL=/bin/bash

all:
	@echo "Compiling..."; pdflatex -shell-escape spin.tex > /dev/null
	@pdflatex -shell-escape spin.tex > /dev/null
	@echo "Done"

clean:
	rm -rf spin.{aux,log,out,toc,pdf} _minted-spin/
