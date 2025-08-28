#!/bin/bash

## read in ollama envs
. ./olmenv 

## get podman id
pmanid=$(podman ps | egrep  open-webui | cut -f 1 -d \ )

## now stop it 
podman stop ${pmanid}


