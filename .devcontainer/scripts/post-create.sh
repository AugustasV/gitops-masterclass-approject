#!/bin/bash

echo "post-create start" >> ~/.status.log

# Install the K3D cluster for Argo CD
k3d cluster create --config .devcontainer/manifests/k3d-dev.yaml --wait | tee -a ~/.status.log

# Install the managed K3D cluster
k3d cluster create --api-port=$(hostname -I | awk '{print $1}'):6550 --config .devcontainer/manifests/k3d-managed.yaml --wait | tee -a ~/.status.log

# Make sure we're on the right context
kubectx k3d-dev | tee -a ~/.status.log

# Install Argo CD using Helm
helm repo add argo https://argoproj.github.io/argo-helm | tee -a  ~/.status.log 
helm repo update | tee -a  ~/.status.log 
helm install argocd argo/argo-cd --version 7.8.26 --namespace argocd --create-namespace --set server.service.type="NodePort" --set server.service.nodePortHttps=30272 --set configs.cm."kustomize\.buildOptions"="--enable-helm" | tee -a  ~/.status.log 



echo "post-create complete" >> ~/.status.log
