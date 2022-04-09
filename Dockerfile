FROM nginx:alpine as build

ENV DOMAIN=localhost

RUN apk add --update --no-cache \
          wget \
          hugo

WORKDIR /site

EXPOSE 1313

CMD hugo server --disableFastRender --buildDrafts --watch --bind 0.0.0.0 --baseURL=//$DOMAIN --appendPort=false
