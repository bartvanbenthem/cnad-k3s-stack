#!/bin/sh

##############################################################
# INSTALL LONGHORN
##############################################################

# install on all nodes
sudo apt update \
sudo apt install -y nfs-common open-iscsi util-linux jq
# check disks
lsblk -f

# Next, we need to make your hard-drive shareable for Longhorn.
sudo mount --make-rshared /

# You must run this command from a computer with kubectl access to your cluster.
curl -sSfL https://raw.githubusercontent.com/longhorn/longhorn/v1.0.0/scripts/environment_check.sh | bash

helm repo add longhorn https://charts.longhorn.io
helm repo update
helm install longhorn longhorn/longhorn --namespace longhorn-system --create-namespace --set defaultSettings.defaultDataPath="/storage01"
# if you do not want to create separate service file for UI access as I did leter on with `service.yaml` you can use it like this:
# helm install longhorn longhorn/longhorn --namespace longhorn-system --create-namespace --set defaultSettings.defaultDataPath="/storage01" --set service.ui.loadBalancerIP="192.168.0.201" --set service.ui.type="LoadBalancer"

#Expose UI over MetalLB
kubectl -n longhorn-system apply -f longhorn/longhorn-lb.yaml


# check the assigned loadbalancer IP to access the UI
kubectl -n longhorn-system get svc longhorn-ingress-lb
# NAME                  TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
# longhorn-ingress-lb   LoadBalancer   10.43.68.146   192.168.2.2   80:30365/TCP   8m18s

# check if the longhorn storage class is the default
kubectl get storageclass
# NAME                 PROVISIONER          RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
# longhorn (default)   driver.longhorn.io   Delete          Immediate           true                   35m