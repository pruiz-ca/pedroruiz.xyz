all:
			@/bin/rm -rf resources .hugo*
			@make -C ../cv
			@/bin/mv ../cv/cv.pdf static/cv.pdf

