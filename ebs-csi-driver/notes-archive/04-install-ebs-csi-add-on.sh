#!/usr/bin/env bash

ACCOUNT_NUMBER=979033099169

## Edit the ../eksctl/cluster-config.yaml to include the addOn.
## Get the default version with `aws eks describe-addon-versions --addon-name aws-ebs-csi-driver | less`
## for the respective K8s Version

#addons:
#- name: aws-ebs-csi-driver
#  version: 1.14.0
#  attachPolicyARNs:
#  - arn:aws:iam::${ACCOUNT_NUMBER}policy/ebs-csi-controller-policy
#  resolveConflicts: overwrite

eksctl create addon --profile admin -f ../eksctl/cluster-config.yaml -v 4

sleep 5

kubectl replace -f ./storageclass.yaml --force

