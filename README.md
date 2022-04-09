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

Save this docker-compose file and as optional, add a .env file with the only variable DOMAIN_NAME='yourdomain'. If there's no .env file it will take localhost by default and you should remove the environment lines.

		version: '3.0'
		services:
		  web:
		    image: pruizca/hugo
		    container_name: personal_website
		    hostname: website
		    ports:
		    - "1313:1313"
		    volumes:
		    - ./:/site
		    environment:
		    - DOMAIN=${DOMAIN_NAME}

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
