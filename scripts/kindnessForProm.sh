#!/bin/bash

echo "Installing dependencies..."
apt-get update 1> /dev/null
apt-get upgrade -y 1> /dev/null

apt-get install curl -y 1> /dev/null

echo "Fetching files..."
curl "https://raw.githubusercontent.com/HubbelGrayso24/AICE/main/misc_files/values.yaml" -o values.yaml 1> /dev/null

echo "Installing kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" 1> /dev/null
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl 1> /dev/null
kubectl version --client

echo "Installing Docker..."
apt-get install ca-certificates curl -y 1> /dev/null
install -m 0755 -d /etc/apt/keyrings 1> /dev/null
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc 1> /dev/null
chmod a+r /etc/apt/keyrings/docker.asc 1> /dev/null

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null 1> /dev/null
apt-get update 1> /dev/null

apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y 1> /dev/null

echo "Installing kind..."
[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.23.0/kind-linux-amd64 1> /dev/null

chmod +x ./kind 1> /dev/null
mv ./kind /usr/local/bin/kind 1> /dev/null

echo "Creating cluster..."
kind create cluster 1> /dev/null

echo "Install helm..."
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 1> /dev/null
chmod 700 get_helm.sh 1> /dev/null
./get_helm.sh 1> /dev/null
rm get_helm.sh 1> /dev/null

echo "Installing Prometheus..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts 1> /dev/null
helm repo update 1> /dev/null

helm install prom prometheus-community/prometheus -f values.yaml 1> /dev/null

kubectl port-forward svc/prom-prometheus 9090:9090 1> /dev/null
echo "Prometheus is now running on http://localhost:9090"