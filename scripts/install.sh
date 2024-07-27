#!/bin/bash

echo "Creating cluster..."
kind create cluster 1> /dev/null

echo "Installing Prometheus..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts 1> /dev/null
helm repo update 1> /dev/null

helm install prom prometheus-community/prometheus -f values.yaml 1> /dev/null

kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=prometheus -n default --timeout=30s 1> /dev/null

export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=prometheus,app.kubernetes.io/instance=prom" -o jsonpath="{.items[0].metadata.name}")
  kubectl --namespace default port-forward $POD_NAME 9090 &

echo "Prometheus is now running on http://localhost:9090"

echo "Done!"