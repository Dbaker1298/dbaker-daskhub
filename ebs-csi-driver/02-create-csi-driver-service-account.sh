#!/usr/bin/env bash

PROFILE=admin
REGION=us-west-2
CLUSTER_NAME=dbaker-daskhub-dev
ACCOUNT_NUMBER=979033099169
SA_POLICY_NAME=ebs-csi-controller-policy
SA_NAME=ebs-csi-controller-sa
ROLE_NAME=AmazonEKS_EBS_CSI_DriverRole

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
