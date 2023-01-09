#!/usr/bin/env bash

set -euo pipefail

PROFILE=
REGION=
CLUSTER_NAME=
ACCOUNT_NUMBER=
SA_POLICY_NAME=AWSLoadBalancerControllerIAMPolicy
SA_NAME=aws-load-balancer-controller
ROLE_NAME=AmazonEKSLoadBalancerControllerRole
POLICY_ARN=arn:aws-cn:iam::${ACCOUNT_NUMBER}:policy/AWSLoadBalancerControllerIAMPolicy

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

## https://docs.amazonaws.cn/en_us/eks/latest/userguide/aws-load-balancer-controller.html
## curl -o load-balancer-controller-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.5/docs/install/iam_policy.json

# Create the IAM Policy
aws iam create-policy \
    --profile $PROFILE \
    --policy-name $SA_POLICY_NAME \
    --policy-document file://load-balancer-controller-policy.json

sleep 5

# Creat the IAM Role
eksctl create iamserviceaccount \
  --profile $PROFILE \
  --region $REGION \
  --cluster=$CLUSTER_NAME \
  --namespace=kube-system \
  --name=$SA_NAME \
  --role-name $ROLE_NAME \
  --attach-policy-arn=$POLICY_ARN \
  --approve

sleep 5

# Install AWS Load Balancer Controller using Helm V3
helm repo add eks https://aws.github.io/eks-charts
helm repo update

##### If upgrading, kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master #####
##### The helm install command automatically applies the CRDs, but helm upgrade doesn't. #####

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=$CLUSTER_NAME \
  --set serviceAccount.create=false \
  --set serviceAccount.name=$SA_NAME \
  --set enableShield=false \
  --set enableWaf=false \
  --set enableWafv2=false

sleep 30

kubectl get deployment -n kube-system aws-load-balancer-controller

echo
echo "*******************************"
echo "The script has completed"
echo "Proceed to Step 4 of README.md."
echo "*******************************"

