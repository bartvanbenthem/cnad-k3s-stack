#!/bin/bash

##############################################################
# INSTALL ARGOCD
###############################################
#create namespace
kubectl create namespace argocd
#Install as on any other cluster
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl -n argocd patch service argocd-server --patch '{ "spec": { "type": "LoadBalancer", "loadBalancerIP": "192.168.2.36" } }'

# you now have access to the UI under IP: 192.168.2.36 and port: 80 but that will switch to 443 anyway.
# Username: admin and password is randomly generated. Get it like this:
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo

##############################################################
# PORTAINER
###############################################
helm repo add portainer https://portainer.github.io/k8s/
helm repo update
helm install --create-namespace -n portainer portainer portainer/portainer

# expose UI 
kubectl -n portainer apply -f portainer/portainer-lb.yaml

# check 
kubectl -n portainer get svc portainer 
# NAME        TYPE           CLUSTER-IP     EXTERNAL-IP    PORT(S)          AGE
# portainer   LoadBalancer   10.43.11.217   192.168.2.37   9000:31164/TCP   17s

# When you try to log in to the Portainer for the first time, and you took too much time, the UI will time out with this message: 
# "Your Portainer Instance timed out for security purposes."
kubectl scale --replicas=0 deployment portainer -n portainer
kubectl scale --replicas=1 deployment portainer -n portainer