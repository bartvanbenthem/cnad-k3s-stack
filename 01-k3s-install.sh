##############################################################
# Kubernetes - K3S
##############################################################

# install k3s master node
TOKEN='123234454985944449564965869486954645959'
MSIP='192.168.2.177'
curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" \
INSTALL_K3S_EXEC="--cluster-cidr=10.0.0.0/16 --token=$TOKEN --disable=traefik --disable servicelb --disable local-storage --node-taint CriticalAddonsOnly=true:NoExecute" \
sh -

# copy rancher config to default kubeconfig
mkdir ~/.kube
cat /etc/rancher/k3s/k3s.yaml > ~/.kube/config
# sudo echo "KUBECONFIG=/etc/rancher/k3s/k3s.yaml" >> /etc/environment

# In order to add additional nodes to your cluster you need two piece of information.
#    K3S_URL which is going to be your main node ip address.
#    K3S_TOKEN which is stored in /var/lib/rancher/k3s/server/node-token
# curl -sfL https://get.k3s.io | K3S_URL=https://serverip:6443 K3S_TOKEN=mytoken sh -

TOKEN='123234454985944449564965869486954645959'
MSIP='192.168.2.177'
curl -sfL https://get.k3s.io | K3S_URL=https://$MSIP:6443 K3S_TOKEN=$TOKEN sh -

