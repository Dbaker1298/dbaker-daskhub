#!/bin/bash

## admin
## us-west-2
## dbaker-daskhub-dev
## 979033099169


## Create Cluster Autoscaler IAM Policy

aws --profile admin iam create-policy \
    --policy-name k8s-asg-policy \
    --policy-document file://cluster-autoscaler-policy.json

## Create Cluster Autoscaler EKS Service Account

eksctl --profile admin --region us-west-2 create iamserviceaccount \
  --cluster=dbaker-daskhub-dev \
  --namespace=kube-system \
  --name=cluster-autoscaler \
  --attach-policy-arn=arn:aws:iam::979033099169:policy/k8s-asg-policy \
  --override-existing-serviceaccounts \
  --approve

## Deploy Cluster Autoscaler

kubectl apply -f ../kubectl/cluster-autoscaler.yaml

## Annontate Cluster Autoscaler deployment to mark it unsafe to evict

kubectl -n kube-system \
    annotate deployment.apps/cluster-autoscaler \
    cluster-autoscaler.kubernetes.io/safe-to-evict="false"

