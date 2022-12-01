#!/bin/bash

## admin
## us-west-2
## dbaker-daskhub-dev
## 979033099169
## dh-dbaker-daskhub-dev-policy


## Add OIDC Provider

aws --profile admin --region us-west-2 eks describe-cluster --name dbaker-daskhub-dev --query cluster.identity.oidc.issuer --output text
eksctl --profile admin --region us-west-2 utils associate-iam-oidc-provider --cluster dbaker-daskhub-dev --approve

## Create IAM policy for default service account

aws --profile admin iam create-policy \
    --policy-name dh-dbaker-daskhub-dev-policy \
    --policy-document file://service-account-policy.json

## Create EKS/K8S Service Account

eksctl create iamserviceaccount \
    --profile admin --region us-west-2 \
    --name dh-dbaker-daskhub-dev-role   \
    --role-name dh-dbaker-daskhub-dev-role
    --namespace daskhub \
    --cluster dbaker-daskhub-dev \
    --attach-policy-arn arn:aws:iam::979033099169:policy/dh-dbaker-daskhub-dev-policy \
    --approve \
    --override-existing-serviceaccounts



