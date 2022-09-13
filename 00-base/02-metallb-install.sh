#!/bin/bash

##############################################################
# INSTALL METALLB
##############################################################
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.10.3/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.10.3/manifests/metallb.yaml

kubectl -n metallb-system apply -f metallb/pool.yaml