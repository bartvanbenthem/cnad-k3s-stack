#!/bin/bash

##############################################################
# AZURE DEVOPS SELF HOSTED AGENT
##############################################################

# Specific config for my personal Azure ENV and AUTH
source ../00-ENV/env.sh

kubectl create ns azagent
kubectl -n azagent create secret generic azdevops \
                  --from-literal=AZP_URL="https://dev.azure.com/$ORGANIZATION" \
                  --from-literal=AZP_TOKEN=$PAT \
                  --from-literal=AZP_POOL=$POOL 

kubectl -n azagent apply -f azure-devops-agent/azagent.yaml

# remove agent
# kubectl -n azagent delete secret azdevops
# kubectl -n azagent delete -f azure-devops-agent/azagent.yaml

##############################################################
# INSTALL ARGOCD
##############################################################
#create namespace
kubectl create namespace argocd
#Install as on any other cluster
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl -n argocd patch service argocd-server --patch '{ "spec": { "type": "LoadBalancer", "loadBalancerIP": "192.168.2.36" } }'

# you now have access to the UI under IP: 192.168.2.36 and port: 80 but that will switch to 443 anyway.
# Username: admin and password is randomly generated. Get it like this:
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo