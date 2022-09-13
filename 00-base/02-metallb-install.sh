#!/bin/bash

##############################################################
# INSTALL METALLB
##############################################################
kubectl apply -f 00-base/metallb/namespace.yaml
kubectl -n metallb-system apply -f 00-base/metallb/metallb.yaml
kubectl -n metallb-system apply -f 00-base/metallb/pool.yaml