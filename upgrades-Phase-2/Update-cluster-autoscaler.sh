#!/usr/bin/env bash

PROFILE=admin
REGION=us-west-2
CLUSTER_NAME=dbaker-daskhub-dev
ACCOUNT_NUMBER=979033099169

#https://github.com/kubernetes/autoscaler/issues/3216#issuecomment-644038135

confirmation() {

    echo
    echo "Have you updated the variables of this script?"
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

}

confirmation

## DELETE Cluster Autoscaler EKS Service Account
eksctl --profile $PROFILE --region $REGION delete iamserviceaccount \
  --cluster=$CLUSTER_NAME \
  --namespace=kube-system \
  --name=cluster-autoscaler 

## DELETE Cluster Autoscaler IAM Policy

aws --profile admin iam delete-policy \
    --policy-arn arn:aws:iam::${ACCOUNT_NUMBER}:policy/k8s-asg-policy

## Create Cluster Autoscaler IAM Policy
sleep 5
aws --profile $PROFILE iam create-policy \
    --policy-name k8s-asg-policy \
    --policy-document file://cluster-autoscaler-policy.json

## Create Cluster Autoscaler EKS Service Account
sleep 5

eksctl --profile $PROFILE --region $REGION create iamserviceaccount \
  --cluster=$CLUSTER_NAME \
  --namespace=kube-system \
  --name=cluster-autoscaler \
  --attach-policy-arn=arn:aws:iam::${ACCOUNT_NUMBER}:policy/k8s-asg-policy \
  --override-existing-serviceaccounts \
  --approve

## Deploy Cluster Autoscaler
sleep 5
kubectl apply -f ../kubectl/cluster-autoscaler.yaml
kubectl rollout restart deploy -n kube-system cluster-autoscaler && \
kubectl rollout status deploy -n kube-system cluster-autoscaler

## We do NOT need to Annontate Cluster Autoscaler deployment to mark it unsafe to evict again

#kubectl -n kube-system \
#    annotate deployment.apps/cluster-autoscaler \
#    cluster-autoscaler.kubernetes.io/safe-to-evict="false"
#
echo 
echo "Complete"
confirmation
