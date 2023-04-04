## Demo app - Developing with Docker

This demo app shows a simple user profile app set up using 
- index.html with pure js and css styles
- nodejs backend with express module
- mongodb for data storage

All components are docker-based
In case you deploy this app successfully, let's fill some information in the form on website
Then check if data would be updated into database using mongo-express to show data.

### 1. With Docker
#### To start the application step by step

Step 1: Pull mongo image from Dockerhub and start mongodb

    docker pull mongo

    docker run -d -p 27017:27017 -e MONGO_INITDB_ROOT_USERNAME=admin -e MONGO_INITDB_ROOT_PASSWORD=password --name mongodb --net mongo-network mongo    

Step 2: Pull mongo-express from Dockerhub and start mongo-express

    docker pull mongo-express
    
    docker run -d -p 8081:8081 -e ME_CONFIG_MONGODB_ADMINUSERNAME=admin -e ME_CONFIG_MONGODB_ADMINPASSWORD=password --net mongo-network --name mongo-express -e ME_CONFIG_MONGODB_SERVER=mongodb mongo-express  

> ***NOTE:***   

> ***Creating docker-network in optional. You can start both containers in a default network. In this case, just emit `--net` flag in `docker run` command_***

> ***Instead of doing gradually from step 1 - step 2, you can run this command below:***  

    docker compose -f docker-compose.yaml up

Step 3: Open mongo-express from browser

    http://XXX.XXX.XXX.XXX:8080 (XXX.XXX.XXX.XXX: ipv4 server ec2)
    // or http://localhost:8080 (running on local machine)

Step 4: Create `user-account` _db_ and `users` _collection_ in mongo-express

Step 5: Start your nodejs application locally - go to `app` directory of project 

    npm install 
    node server.js
    
Step 6: Access you nodejs application UI from browser

    http://XXX.XXX.XXX.XXX:3000 (XXX.XXX.XXX.XXX: ipv4 server ec2)
    // or http://localhost:3000 (running on local machine)

### 2. With Docker Compose
#### To start the application

Step 1: Start mongodb and mongo-express

    docker compose -f docker-compose.yaml up
    
_You can access the mongo-express under <server_public_ip>:8080 from your browser_
    
Step 2: In mongo-express UI - create a new database `my-db`

Step 3: In mongo-express UI - create a new collection `users` in the database `my-db`       
    
Step 4: Start your nodejs application locally - go to `app` directory of project on node server 

    npm install
    node server.js
    
Step 5: Access the nodejs application from browser 

    http://XXX.XXX.XXX.XXX:3000 (XXX.XXX.XXX.XXX: ipv4 server ec2)
    // or http://localhost:3000 (running on local machine)

#### To build a docker image from the application

    docker build -t my-app:1.0 .

<!-- docker build -t mnikhoa/docker-and-compose:latest . -->
    
The dot "." at the end of the command denotes location of the Dockerfile.

    docker network create mongo-network
    docker run -d -p 3000:3000 --net mongo-network my-app:1.0

To create container running the app with the image my-app:1.0

> ***NOTE:***

> ***Substitute the variable `mongoUrlLocal` in `server.js` file as the variable `mongoUrlDocker` for both POST and GET method***
