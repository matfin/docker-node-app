# Developing a Node JS app using Docker
This is a very simple example of how to get started on developing a Node JS app while making use of Docker.

## What is docker?
Docker is a container management system that makes it easy to create and run instances of your application, whether you are on your local development environment or deploying to a production server.

## Requirements

You will need a running instance of Docker on your development machine. Go to the [Docker Docs](https://docs.docker.com/) for installation instructions.

It is recommended to have at least ```Docker v1.1``` and ```Docker Compose v1.6```. If you are installing Docker for MacOS or Windows, the latest versions should be installed. If you are running Linux, [refer to these instructions](https://docs.docker.com/compose/install/).

## What problem will it solve for me?
Your task is to create an application (in this case NodeJS) and you need the infrastructure to support it.

For a Typical NodeJS application, you would need to use MongoDB as your data store, Nginx for reverse proxying and load balancing and Node V6.x.x to run the application itself.

One approach you could take would be to grab all the pakages you need for your local development environment and install them in turn:

- using ```apt-get update && apt-get install ...``` on Ubuntu
- using ```brew update && brew install ...``` on MacOS
- using ```yum install -y ...``` on CentOS
- using your favourite Windows installer.

This approach can be quite problematic, expecially given the array of operating systems and potential differences between your own platform and what is running on production or even staging.

This traditional approach can also raise issues with other developers, introduce issues with onboarding new developers and raise the "It works on my machine why doesn't it work on yours??" scenario.

## How will Docker solve this problem for me?
Docker will solve this problem by creating a container for your application to run inside. This container will have all the application infrastructure you need to get going and it will also ensure that what you have running locally in development will be the same as what is running on all other environments, including other developers machines.

Docker does this by creating a container (like a virtual machine) that sets itself up based on the instructions given to it by its ```Dockerfile``` and ```docker-compose.yml```.

A docker container is like a virtual machine. It contains its own operating system and file system. A container could be running any one of the many flavours of Linux or Unix.

Docker reads in what is called a ```Dockerfile```. This contains instructions on how to create a Docker image, which we can then use to create a Docker container. 

**Tip:** Think of an image as a cookie cutter class and the container as being an instance of that class. An image can be used to spawn many containers.

## Taking a look at the files Docker needs to get set up.

If you take a look inside ```.docker/development.dockerfile``` you will see the following, and below you will see an explanation for what each directive means:

```yaml
	FROM node:latest
	
	MAINTAINER Matt Finucane
	
	ENV CONTAINER_PATH /opt
		
	WORKDIR $CONTAINER_PATH

	RUN npm install -g nodemon && npm install

	ENTRYPOINT ["nodemon", "index.js"]
```

#### FROM node:latest
This is instructing docker to fetch the latest official ```Node JS``` image. This image has everything needed to run a NodeJS application.

#### MAINTAINER Matt Finucane
Your name or company name can go in here.

#### ENV CONTAINER_PATH
Setting an environment variable for where your applcation will sit inside the container (virtual machine).

#### WORKDIR $CONTAINER_PATH
Change to the directory set by the environment variable $CONTAINER_PATH - in this case ```/opt```

#### RUN npm install -g nodemon && npm install
This will install all the Node modules needed to get the app running

#### EXPOSE $PORT
This will expose port 3000 (which the Node application is listening on) to the host operating system.

#### ENTRYPOINT ["nodemon", "index.js"]
This will start the application using ```nodemon```. Nodemon will restart node when a file is changed - useful for development.

If you take a look inside the ```docker-compose.yml``` file you will see the following:

```yaml
	version: '2'

	services:
	  node:
	    container_name: nodeapp
	    build:
	      context: .
	      dockerfile: .docker/development.dockerfile
	    volumes:
	      - .:/opt
	    environment:
	      - PORT=3000
	    ports: 
	      - "80:3000"
```

### services:
This defines the containers we are going to be running. In this case, we have only one but we will have more than that in the future. We could have another service for ```mongo``` which defines a container than runs an instance of MongoDB.

#### build:

#### context:
This is set to the current working directory ```.```, which should be used as the basis for locating other files needed.

#### dockerfile: 
The location of the docker file needed for the Node JS application relative to the current context.

#### volumes: 
This maps your current working directory to the ```/opt``` directory inside the running container. This means that any changes to files on your local file system will be reflected in the container immediately. This acts like a *symlink* of sorts.

#### environment:
Set any environment variables here that are needed by the node application.

#### ports:
This links port 80 on the host machine to the exposed port 3000 on the container. This means that you can visit ```http://192.168.99.100``` and your node application will appear (assuming the container is running).

***Note***: use the command ```docker-machine ip``` to verify that ```192.168.99.100``` is the correct IP address for your Docker installation.

## Runing this container

Assuming you have docker installed and set up, run the following via the command line from the root directory of this project:

	$ docker-compose up -d

Running this for the first time will do the following:

- pull down the officail ```node:latest``` docker image.
- create a container named ```nodeapp```.
- build an image for us which is extended from the ```node:latest``` image.
- build a container based on our new image, running through all the commands inside the ```.docker/development.dockerfile```.
- start our container, and bind port 80 on the host development machine to port 3000 on the running container.

You can verify thay the container is running with the following command:

	$ docker ps -a

This will yield: 

	CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS                         PORTS                  NAMES
	c03be8a36300        dockertest_node     "nodemon index.js"       2 minutes ago       Up 2 minutes                   0.0.0.0:80->3000/tcp   nodeapp

You can double check the IP address of your docker installation with the following command:

	$ docker-machine ip

Yields something like this:

	192.168.99.100

To tail the logs of your running container, run the following: 

	$ docker logs -f nodeapp

Then go to your browser and visit ```http://192.168.99.100``` and reload the browser window, keeping an eye on the log files.

To stop the container, run the following:

	$ docker-compose down
