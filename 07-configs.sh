##############################################################
# Configure ingress resources and corresponding services
##############################################################
kubectl -n monitoring apply -f ingresses/prometheus-ingress.yaml
kubectl -n monitoring apply -f ingresses/grafana-ingress.yaml
kubectl -n longhorn-system apply -f ingresses/longhorn-ingress.yaml
kubectl -n argocd apply -f ingresses/argocd-ingress.yaml
kubectl -n portainer apply -f ingresses/portainer-ingress.yaml