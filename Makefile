all:		clean
			@make -C ../cv
			@/bin/mv ../cv/cv.pdf static/cv.pdf

clean:
			@/bin/rm -rf resources .hugo*

img:
			@docker build -t pruizca/hugo .

pull:
			@git pull

push:		img
			@docker push pruizca/hugo:latest
			@docker image rm pruizca/hugo
