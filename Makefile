all:		clean
			@make -C ../cv
			@/bin/mv ../cv/cv.pdf static/cv.pdf

clean:
			@/bin/rm -rf resources .hugo*
