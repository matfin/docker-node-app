FROM node:latest

MAINTAINER Matt Finucane

ENV CONTAINER_PATH /opt

ENV PORT 3000

WORKDIR $CONTAINER_PATH

# COPY index.js .

# COPY package.json .

RUN npm install -g nodemon && npm install

EXPOSE $PORT

ENTRYPOINT ["nodemon", "index.js"]