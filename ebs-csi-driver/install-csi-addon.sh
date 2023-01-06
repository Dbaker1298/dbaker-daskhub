#!/usr/bin/env bash

# Update the variables

PROFILE=admin
REGION=us-west-2
CLUSTER_NAME=dbaker-daskhub-dev
K8S_VERSION="1-22"
ACCOUNT_NUMBER=979033099169
SA_POLICY_NAME=ebs-csi-controller-policy
SA_NAME=ebs-csi-controller-sa
ROLE_NAME=AmazonEKS_EBS_CSI_DriverRole

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

service-account-ebs-csi() {

  ## Using AWS Managed service-role
  ## https://docs.amazonaws.cn/en_us/eks/latest/userguide/csi-iam-role.html

  eksctl --profile $PROFILE --region $REGION create iamserviceaccount \
      --name $SA_NAME \
      --role-name $ROLE_NAME \
      --namespace kube-system \
      --cluster $CLUSTER_NAME \
      --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
      --role-only \
      --approve

}

install-csi-snapshotter() {

  ## https://github.com/kubernetes-csi/external-snapshotter#usage
  ## The external snapshotter must be installed BEFORE the EBS CSI Add-On ##
  ## First the CRDs, then the Volume snapshot Controller, and lastly the EBS CSI Driver
  echo "====> Installing the External Snapshotter CRDs and deployment..."
  echo

  kubectl kustomize ext-snapshotter-crd | kubectl create -f -

  sleep 5

  kubectl kustomize csi-snapshotter-controller-deploy | kubectl create -f -

  sleep 5
  
  kubectl get pod -n kube-system -l app=snapshot-controller

  confirmation

}


echo 
echo "====>  Have you updated the variables of this script?"
echo
confirmation
service-account-ebs-csi
confirmation
install-csi-snapshotter
