#!/usr/bin/env bash

# https://docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html
# https://github.com/aws/eks-charts/tree/master/stable/aws-vpc-cni
# https://github.com/aws/amazon-vpc-cni-k8s

# Update the variables

PROFILE=admin
REGION=us-west-2
CLUSTER_NAME=dbaker-daskhub-dev
DATE="$(date +%Y-%m)"
K8S_VERSION="1-24"
ACCOUNT_NUMBER=979033099169

# The current recommended Add-on version is 1.12.0-eksbuild.1

confirmation() {

  echo
  while true; do
      read -p "Are you certain that you wish to continue? " yn
      case $yn in
          [Yy]* ) echo "ok, we shall proceed";
              break;;
          [Nn]* ) echo "exiting...";
              exit 13;;
          * ) echo "Please answer yes or no.";;
      esac
  done
  echo

}

downtime() {

  echo
  echo "****************************************************************"
  echo
  echo "The cluster will experience downtime while completing this step."
  echo
  echo "****************************************************************"
  echo
  confirmation

}

determine-if-eks-or-selfmanaged-add-on() {

  echo "Is this an EKS managed add-on or a Self Managed add-on for the vpc-cni?"
  echo "=======> See output below..."

  aws eks describe-addon \
  --cluster-name $CLUSTER_NAME \
  --addon-name vpc-cni \
  --profile $PROFILE \
  --region $REGION \
  --query addon.addonVersion \
  --output text
  
  echo 
  echo "=======> If the output is '... No addon: vpc-cni found in cluster: ...', then this is a \"Self Managed\" vpc-cni and YES, continue."
  echo 
  echo "=======> If you see a version like: 'v1.10.4' then this is an \"EKS add-on\" and DO NOT proceed with this script."
  echo 
  confirmation

}

annotate-and-label() {

  helm repo add eks https://aws.github.io/eks-charts
  helm repo update
  # Backup the current settings
  kubectl get daemonset aws-node -n kube-system -o yaml > aws-k8s-cni-old.yaml
  set -e 
  # Annotate resources to be managed by Helm
  ./helm-cni.sh

}

helm-upgrade-install() {

  helm install  aws-vpc-cni eks/aws-vpc-cni \
    --namespace kube-system \
    --values values.yaml 

  sleep 30

  kubectl get ds aws-node -n kube-system

  echo "Checking all pods..."
  sleep 10
  
  kubectl get pods -A

}

downtime
determine-if-eks-or-selfmanaged-add-on
annotate-and-label
helm-upgrade-install
echo
echo "************************"
echo "The script has completed"
echo "************************"
