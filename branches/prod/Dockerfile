FROM node:18.13.0-alpine3.16
ENV MONGO_DB_USERNAME=admin \
    MONGO_DB_PWD=password
RUN mkdir -p /home/app
# set default dir so that next commands executes in /home/app dir
WORKDIR /home/app
COPY ./app /home/app
# will execute npm install in /home/app because of WORKDIR
RUN npm install
EXPOSE 3000
# no need for /home/app/server.js because of WORKDIR
CMD ["node", "server.js"]

# ARG VERSION=latest
# FROM mongo:${VERSION}
# ARG MONGO_INITDB_ROOT_USERNAME=admin \
#     MONGO_INITDB_ROOT_PASSWORD=password
# ENV MONGO_INITDB_ROOT_USERNAME=${MONGO_INITDB_ROOT_USERNAME} \
#     MONGO_INITDB_ROOT_PASSWORD=${MONGO_INITDB_ROOT_PASSWORD}
# EXPOSE 27017

# FROM mongo-express:${VERSION}
# ARG ME_CONFIG_MONGODB_ADMINUSERNAME=admin \
#     ME_CONFIG_MONGODB_ADMINPASSWORD=password \
#     ME_CONFIG_MONGODB_SERVER=mongodb
# ENV ME_CONFIG_MONGODB_ADMINUSERNAME=${ME_CONFIG_MONGODB_ADMINUSERNAME} \
#     ME_CONFIG_MONGODB_ADMINPASSWORD=${ME_CONFIG_MONGODB_ADMINPASSWORD} \
#     ME_CONFIG_MONGODB_SERVER=${ME_CONFIG_MONGODB_SERVER}
# EXPOSE 8081
