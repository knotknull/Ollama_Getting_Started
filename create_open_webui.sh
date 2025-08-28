#!/bin/bash

## read in ollama envs
. ./olmenv 

## run run open-webui via podman 
## NOTE: 8181 is the localhost port to view UI via browser
##
## was working
## podman run -d \
##   --name open-webui \
##   --network=host \
##   -p 8181:8080 \
##   -v open-webui:/app/backend/data \
##   -e OLLAMA_BASE_URL=http://127.0.0.1:11434 \
##   --restart always \
##   ghcr.io/open-webui/open-webui:main

##  working
podman run -d \
  --name open-webui \
  --network=host \
  -v open-webui:/app/backend/data \
  -e OLLAMA_BASE_URL=http://127.0.0.1:11434 \
  --restart always \
  ghcr.io/open-webui/open-webui:main
