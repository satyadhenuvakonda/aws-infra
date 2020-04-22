#! /bin/sh

# Add the Docker GPG key:
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Add the Docker repository:
sudo add-apt-repository \
"deb [arch=amd64] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) \
stable"

# This update will add the localrepo
sudo apt-get update
# Installing docker docker-ce=18
sudo apt-get install -y docker-ce=18.06.1~ce~3-0~ubuntu
# Hold Docker at this specific version:
sudo apt-mark hold docker-ce

# check the status of docker
systemctl is-active --quiet docker
if [ $? -eq 0 ]; then
    echo DOCKER-IS-RUNNING
else
    echo FAILED-TO-START-DOCKER
fi

# Add the Kubernetes GPG key:
 curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
# Add the Kubernetes repository:
cat << EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt-get update

# Kubernetes version is set and locked for 1.12.7-00
sudo apt-get install -y kubelet=1.12.7-00 kubeadm=1.12.7-00 kubectl=1.12.7-00
sudo apt-mark hold kubelet kubeadm kubectl

# This is where you are adding the join command. NOTE This will be different for different clusters
# kubeadm join 172.31.29.36:6443 --token ypkxqi.uqrx79np6l1hwmlt --discovery-token-ca-cert-hash sha256:0f8882eac73aca0404b3198500d317334877a9dded8b9a36074771eb93b0df6e

echo "net.bridge.bridge-nf-call-iptables=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
