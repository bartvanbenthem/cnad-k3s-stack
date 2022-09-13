#!/bin/sh

##############################################################
# METRICS PROMETHEUS
##############################################################
#wget https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/master/bundle.yaml -O prometheus/bundle.yaml
#sed -i 's/namespace: default/namespace: monitoring/g' prometheus/bundle.yaml
#grep 'namespace: ' prometheus/bundle.yaml

kubectl create namespace monitoring
kubectl apply --server-side -f prometheus/bundle.yaml

# INSTALL SERVICE MONITORS
kubectl apply -f service-monitors/longhorn-sm.yaml
kubectl apply -f service-monitors/node-exporter-sm.yaml
kubectl apply -f service-monitors/kube-state-metrics-sm.yaml
kubectl apply -f service-monitors/kubelet-sm.yaml

# check exporters
kubectl -n monitoring get pods

# Install Prometheus
kubectl apply -f prometheus/prometheus.yaml

# Get External Loadbalancer IP
kubectl -n monitoring get svc prometheus-external
# NAME                  TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)             AGE
# prometheus-external   LoadBalancer   10.43.136.83   192.168.2.38    9090:30763/TCP      149m

##############################################################
# GRAFANA
##############################################################
kubectl apply -f grafana/grafana.yaml

kubectl -n monitoring get pods
# Get External Loadbalancer IP
kubectl -n monitoring get svc grafana
# NAME                  TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)             AGE
# grafana               LoadBalancer   10.43.0.220    192.168.2.39   3000:30917/TCP      44s

# Default login and password is admin:admin

# Add the Datasources and dashboards
Prometheus datasource:      http://prometheus.monitoring.svc.cluster.local:9090
Kubernetes nodes:           8171 
Kubernetes metrics:         7249 
longhorn dashboard:         13032 
nginx ingress dashboard:    9614    

