#!/bin/sh

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

kubectl -n azagent apply -f 00-base/azure-devops-agent/azagent.yaml

# remove agent
# kubectl -n azagent delete secret azdevops
# kubectl -n azagent delete -f ado-self-hosted-agent/azagent.yaml
