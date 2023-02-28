##############################################################
# uninstall k3s
##############################################################

# on worker nodes
sudo k3s crictl rmi --prune
sudo /usr/local/bin/k3s-agent-uninstall.sh

# on master node
sudo k3s crictl rmi --prune
sudo /usr/local/bin/k3s-uninstall.sh

# storage cleanup on all longhorn nodes
sudo rm -rf longhorn/storage/*

##############################################################
# DOCKER clean-up
##############################################################
docker image ls --format '{{.ID}}' | xargs docker image rm --force
docker container prune
docker volume prune