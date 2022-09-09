#!/bin/bash

##############################################################
# INSTALL METALLB
##############################################################
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.10.3/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.10.3/manifests/metallb.yaml

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - 192.168.2.1-192.168.2.254
EOF

##############################################################
# INSTALL NGINX INGRESS
##############################################################
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm show values ingress-nginx/ingress-nginx
# check these values and change when needed
# Set hostNetwork to true
# Set hostPort:enabled to true
# Change kind from Deployment to DaemonSet

helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --values nginx-ingress/values.yaml \
  --set controller.metrics.enabled=true \
  --set controller.metrics.serviceMonitor.additionalLabels.release="prometheus"
  #--set controller.metrics.serviceMonitor.enabled=true

helm get values ingress-nginx --namespace ingress-nginx
# helm -n ingress-nginx uninstall ingress-nginx
# kubectl delete ns ingress-nginx