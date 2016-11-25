FROM node:latest

MAINTAINER matfin@gmail.com

ENV CONTAINER_PATH /opt

WORKDIR $CONTAINER_PATH

RUN npm install -g nodemon && npm install

ENTRYPOINT ["nodemon", "index.js"]