##############################################################
# INSTALL DOCKER
##############################################################
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
apt-cache policy docker-ce
sudo apt install -y docker-ce
sudo systemctl status docker
# Executing the Docker Command Without Sudo 
sudo usermod -aG docker ${USER}
su - ${USER}
cat /etc/group | grep docker
# test docker
docker version

##############################################################
# INSTALL CLIENT TOOLING
##############################################################
# install kubectl
sudo snap install kubectl --classic
# kubectl auto complete
source /usr/share/bash-completion/bash_completion
echo 'source <(kubectl completion bash)' >>~/.bashrc
kubectl completion bash >/etc/bash_completion.d/kubectl
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -F __start_kubectl k' >>~/.bashrc

# install helm v3
##############################################################
sudo snap install helm --classic
helm plugin install https://github.com/databus23/helm-diff --version master
helm version

# install azure cli
##############################################################
sudo apt-get install ca-certificates curl apt-transport-https lsb-release gnupg

curl -sL https://packages.microsoft.com/keys/microsoft.asc |
    gpg --dearmor |
    sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
    
AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" |
    sudo tee /etc/apt/sources.list.d/azure-cli.list

sudo apt-get update
sudo apt-get install azure-cli

az version

# install argo cli
##############################################################
todo

# install etcdctl
##############################################################
todo