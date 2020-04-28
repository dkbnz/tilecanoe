FROM node:12

# Create app directory
WORKDIR /app

# Install app dependencies
# Ensure both package.json AND package-lock.json are copied
COPY ./app/package*.json ./

# Installation of dependencies is done before application
# To make use of docker's layering
RUN npm install

# Bundle app source
COPY ./app/ .

EXPOSE 8080
CMD [ "node", "index.js" ]
