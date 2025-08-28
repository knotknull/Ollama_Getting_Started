#!/bin/bash

## read in ollama envs
. ./olmenv 

## run run open-webui via podman 
## NOTE: 8181 is the localhost port to view UI via browser
##
podman start open-webui
