#!/usr/bin/env bash

set -e

# Update the variables

PROFILE=
REGION=
CLUSTER_NAME=
K8S_VERSION="1-23"
ACCOUNT_NUMBER=
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

backup-cluster-config() {
  echo
  echo "Backing up the ../eksctl/cluster-config.yaml"
  
  cp ../eksctl/cluster-config.yaml ../eksctl/cluster-config.yaml.backup.$(date +%F_%R)

  ls -ltr ../eksctl

  echo 
  echo "Is the backup file in place?"
  
  confirmation

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

add-the-addon() {

  echo
  echo "Appending to the ../eksctl/cluster-config.yaml to include the CSI add-on."

  cat << EoF >> ../eksctl/cluster-config.yaml

addons:
- name: aws-ebs-csi-driver
  version: 1.14.0
  serviceAccountRoleARN: arn:aws:iam::${ACCOUNT_NUMBER}:role/AmazonEKS_EBS_CSI_DriverRole
  resolveConflicts: overwrite
EoF
  ## Get the default version with `aws eks describe-addon-versions --addon-name aws-ebs-csi-driver | less`
  ## for the respective K8s Version

  #addons:
  #- name: aws-ebs-csi-driver
  #  version: 1.14.0
  #  attachPolicyARNs:
  #  - arn:aws:iam::${ACCOUNT_NUMBER}policy/ebs-csi-controller-policy
  #  resolveConflicts: overwrite

  tail -20 ../eksctl/cluster-config.yaml

  echo "Does the file look correct?"

  confirmation

}

install-csi-add-on() {

  echo "Installing the CSI addon now..."

  eksctl create addon --profile $PROFILE -f ../eksctl/cluster-config.yaml -v 4

  echo "Replacing the default storage class..."
  
  sleep 5

  kubectl replace -f ./storageclass.yaml --force

  kubectl describe storageclass

  echo
  echo "Looking for 'Provisioner: kubernetes.io/ebs.csi.aws.com' "
  echo
  
}

echo 
echo "====>  Have you updated the variables of this script?"
echo

backup-cluster-config
confirmation
service-account-ebs-csi
confirmation
install-csi-snapshotter
add-the-addon
install-csi-add-on

echo
echo "*******************************"
echo "The script has completed"
echo "Proceed to Step 3 of README.md."
echo "*******************************"
