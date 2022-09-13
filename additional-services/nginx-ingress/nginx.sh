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
  --set controller.service.loadBalancerIP='192.168.2.30' \
  --set controller.metrics.enabled=true \
  --set controller.metrics.serviceMonitor.additionalLabels.release="prometheus"
  #--set controller.metrics.serviceMonitor.enabled=true

helm get values ingress-nginx --namespace ingress-nginx

# add nginx service-monitor for prometheus integration
kubectl apply -f service-monitors/nginx-ingress-sm.yaml

##############################################################
# Configure ingress resources and corresponding services
##############################################################
kubectl -n monitoring apply -f ingresses/prometheus-ingress.yaml
kubectl -n monitoring apply -f ingresses/grafana-ingress.yaml
kubectl -n longhorn-system apply -f ingresses/longhorn-ingress.yaml
kubectl -n argocd apply -f ingresses/argocd-ingress.yaml
kubectl -n portainer apply -f ingresses/portainer-ingress.yaml

# helm -n ingress-nginx uninstall ingress-nginx
# kubectl delete ns ingress-nginx