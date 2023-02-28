# k3s stack

```bash
##############################################################
# Kubernetes - K3S
##############################################################

# install k3s master node
TOKEN='123234454985944449564965869486954645959'
MSIP='192.168.2.166' # set to host IP: hostname -I
curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" \
INSTALL_K3S_EXEC="--cluster-cidr=10.0.0.0/16 --token=$TOKEN --disable=traefik --disable servicelb --disable local-storage" \
sh -
# in production add:
# --node-taint CriticalAddonsOnly=true:NoExecute

# copy rancher config to default kubeconfig
mkdir ~/.kube
cat /etc/rancher/k3s/k3s.yaml > ~/.kube/config
# sudo echo "KUBECONFIG=/etc/rancher/k3s/k3s.yaml" >> /etc/environment

# In order to add additional nodes to your cluster you need two piece of information.
#    K3S_URL which is going to be your main node ip address.
#    K3S_TOKEN which is stored in /var/lib/rancher/k3s/server/node-token
# curl -sfL https://get.k3s.io | K3S_URL=https://serverip:6443 K3S_TOKEN=mytoken sh -

# print line to add additional nodes to cluster
echo "curl -sfL https://get.k3s.io | K3S_URL=https://$MSIP:6443 K3S_TOKEN=$TOKEN sh -"

```

```bash
##############################################################
# INSTALL METALLB
##############################################################
kubectl apply -f 00-base/metallb/namespace.yaml
kubectl -n metallb-system apply -f 00-base/metallb/metallb.yaml
kubectl -n metallb-system apply -f 00-base/metallb/pool.yaml
```


```bash
##############################################################
# INSTALL LONGHORN DISTRIBUTED STORAGE
##############################################################

# ON THE NODES RUN
##############################################################
# install packages
sudo apt update
sudo apt install -y nfs-common open-iscsi util-linux jq
# check disks
lsblk -f
# Next, we need to make your hard-drive shareable for Longhorn.
# sudo mount --make-rshared /
sudo mount --make-rshared /longhorn

# ON THE K8S API RUN
##############################################################

# You must run this command from a computer with kubectl access to your cluster.
curl -sSfL https://raw.githubusercontent.com/longhorn/longhorn/v1.0.0/scripts/environment_check.sh | bash

helm repo add longhorn https://charts.longhorn.io
helm repo update
helm install longhorn longhorn/longhorn --namespace longhorn-system --create-namespace --set defaultSettings.defaultDataPath="/longhorn/storage01"
# if you do not want to create separate service file for UI access as I did later on with `service.yaml` you can use it like this:
# helm install longhorn longhorn/longhorn --namespace longhorn-system --create-namespace --set defaultSettings.defaultDataPath="/storage01" --set service.ui.loadBalancerIP="192.168.0.201" --set service.ui.type="LoadBalancer"

#Expose UI over MetalLB
kubectl -n longhorn-system apply -f 00-base/longhorn/longhorn-lb.yaml

# check the assigned loadbalancer IP to access the UI
kubectl -n longhorn-system get svc longhorn-ingress-lb
# NAME                  TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
# longhorn-ingress-lb   LoadBalancer   10.43.68.146   192.168.2.2   80:30365/TCP   8m18s

# check if the longhorn storage class is the default
kubectl get storageclass
# NAME                 PROVISIONER          RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
# longhorn (default)   driver.longhorn.io   Delete          Immediate           true                   35m
```

```bash
##############################################################
# METRICS PROMETHEUS
##############################################################
#wget https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/master/bundle.yaml -O prometheus/bundle.yaml
#sed -i 's/namespace: default/namespace: monitoring/g' prometheus/bundle.yaml
#grep 'namespace: ' prometheus/bundle.yaml

kubectl create namespace monitoring
kubectl apply --server-side -f 00-base/prometheus/bundle.yaml

# INSTALL SERVICE MONITORS
kubectl apply -f 00-base/service-monitors/node-exporter-sm.yaml
kubectl apply -f 00-base/service-monitors/kube-state-metrics-sm.yaml
kubectl apply -f 00-base/service-monitors/kubelet-sm.yaml
kubectl apply -f 00-base/service-monitors/longhorn-sm.yaml
kubectl apply -f 00-base/service-monitors/nginx-ingress-sm.yaml

# check exporters
kubectl -n monitoring get pods

# Install Prometheus
kubectl apply -f 00-base/prometheus/prometheus.yaml

# Get External Loadbalancer IP
kubectl -n monitoring get svc prometheus-external
# NAME                  TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)             AGE
# prometheus-external   LoadBalancer   10.43.136.83   192.168.2.38    9090:30763/TCP      149m

##############################################################
# LOCAL GRAFANA INSTANCE
##############################################################
kubectl apply -f 00-base/grafana/grafana.yaml

kubectl -n monitoring get pods
# Get External Loadbalancer IP
kubectl -n monitoring get svc grafana
# NAME                  TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)             AGE
# grafana               LoadBalancer   10.43.0.220    192.168.2.39   3000:30917/TCP      44s

# Default login and password is admin:admin

# Add the Datasources and dashboards
# Prometheus datasource:      http://prometheus.monitoring.svc.cluster.local:9090
# Kubernetes nodes:           8171 
# Kubernetes metrics:         7249 
# nginx ingress dashboard:    9614 
# longhorn dashboard:         13032   

```

```bash
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
  --values 00-base/nginx-ingress/values.yaml \
  --set controller.service.loadBalancerIP='192.168.2.30' \
  --set controller.metrics.enabled=true \
  --set controller.metrics.serviceMonitor.additionalLabels.release="prometheus"
  #--set controller.metrics.serviceMonitor.enabled=true

helm get values ingress-nginx --namespace ingress-nginx

# helm -n ingress-nginx uninstall ingress-nginx
# kubectl delete ns ingress-nginx
```

