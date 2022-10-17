#!/bin/bash

#Variables
source ./00-variables.sh

cd ../src/TodoApi
docker build -t todoapi:$frontendContainerImageTag -f Dockerfile ..
cd ../TodoWeb
docker build -t todoweb:$backendContainerImageTag -f Dockerfile ..