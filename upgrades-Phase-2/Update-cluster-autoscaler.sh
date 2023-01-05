#!/bin/bash

#https://github.com/kubernetes/autoscaler/issues/3216#issuecomment-644038135

## admin
## us-west-2
## dbaker-daskhub-dev
## 979033099169

## DELETE Cluster Autoscaler EKS Service Account

eksctl --profile admin --region us-west-2 delete iamserviceaccount \
  --cluster=dbaker-daskhub-dev \
  --namespace=kube-system \
  --name=cluster-autoscaler 

## DELETE Cluster Autoscaler IAM Policy

aws --profile admin iam delete-policy \
    --policy-arn arn:aws:iam::979033099169:policy/k8s-asg-policy

## Create Cluster Autoscaler IAM Policy
sleep 5
aws --profile admin iam create-policy \
    --policy-name k8s-asg-policy \
    --policy-document file://cluster-autoscaler-policy.json

## Create Cluster Autoscaler EKS Service Account
sleep 5

eksctl --profile admin --region us-west-2 create iamserviceaccount \
  --cluster=dbaker-daskhub-dev \
  --namespace=kube-system \
  --name=cluster-autoscaler \
  --attach-policy-arn=arn:aws:iam::979033099169:policy/k8s-asg-policy \
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
