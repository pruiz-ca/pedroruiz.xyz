# 🏠 Repo synced with my minimal [website](https://pedroruiz.xyz)

This site is statically powered by [Hugo](https://github.com/gohugoio/hugo) using [Minimal Theme](https://github.com/calintat/minimal) and selfhosted with docker on my Raspberry Pi 4. It´s also linked with this repository using GitHub Actions to update the website when it changes.

## How to generate a website
1. Install Hugo and generate new site

		brew install hugo
		hugo new site <name>

2. Install a theme by cloning its repo to themes/

		git submodule add <theme-repo> themes/<theme-name>

3. Tweak config.toml to taste and add more content with:

		hugo new content/<name>

4. Run the server with:

		hugo server -D

5. Try it with your browser on ```localhost:1313```

## Host it with docker

In the host machine first clone your repo with the following command:

		git clone --recurse-submodules -j8 <your-repo>

Save this Dockerfile to your website folder and don't forget to update DOMAIN_NAME with your domain.

		FROM nginx:alpine as build

		RUN apk add --update \
			wget

		ARG HUGO_VERSION="0.89.4"
		RUN wget --quiet "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz" && \
			tar xzf hugo_${HUGO_VERSION}_Linux-64bit.tar.gz && \
			rm -r hugo_${HUGO_VERSION}_Linux-64bit.tar.gz && \
			mv hugo /usr/bin

		COPY ./ /site
		WORKDIR /site
		RUN hugo

		EXPOSE 80 1313

		CMD ["hugo"]
		CMD [ "hugo", "server", "--disableFastRender", "--buildDrafts", "--watch", "--bind", "0.0.0.0", "--baseURL=//DOMAIN_NAME", "--appendPort=false"]

Save this docker-compose file with the Dockerfile and change YOUR_REPO_PATH with your website repository folder path.

		version: '2.0'
		services:
		web:
			build: .
			ports:
			- "1313:1313"
			volumes:
			- YOUR_REPO_PATH:/site

Run ```docker-compose up``` to test it, ```docker-compose up -d``` to keep it in the background if working correctly. The website should be up at localhost:1313

## Update it with GitHub Actions

To update the website the process is quite simple:
1. ```ssh``` to the machine hosting the website
2. ```cd``` to the website directory
3. Run ```git pull```

We can automate this with GitHub Actions saving all sensitive info in the repository secrets (Repository Settings -> Secrets). We need to save the following, each in a secret:
- ```PROJECT_PATH```: path to your website folder in the host machine
- ```SERVER_IP```: public IP of your host machine
- ```SERVER_PORT```: ssh port opened to access the host machine
- ```SERVER_USERNAME```: username of the host machine
- ```SERVER_KEY```: private ssh key that has access to the host machine

Then create a new github action and add the following script:

		name: CI

		on: [push]

		jobs:
		deploy:
			if: github.ref == 'refs/heads/main'
			runs-on: [ubuntu-latest]
			steps:
			- uses: actions/checkout@v1
			- name: Push to server
				uses: appleboy/ssh-action@master
				with:
				host: ${{ secrets.SERVER_IP }}
				port: ${{ secrets.SERVER_PORT }}
				username: ${{ secrets.SERVER_USERNAME }}
				key: ${{ secrets.SERVER_KEY }}
				script: cd ${{ secrets.PROJECT_PATH }} && git pull

Now whenever you push the host downloads the new files and the website should update accordingly.
