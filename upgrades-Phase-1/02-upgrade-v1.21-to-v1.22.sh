#!/usr/bin/env bash

PROFILE=admin
REGION=us-west-2
CLUSTER_NAME=dbaker-daskhub-dev
K8S_VERSION=1.22

echo
echo "Yow will first need to update the ../eksctl/cluster-config.yaml"
echo "by changing the {metadata.version=${K8S_VERSION} and {managedNodeGroups.maxSize=3}"
echo
echo "Then uncomment the second to last line to view the planned control plane upgrade"
echo "Remember to verify the variables first"
echo
##### UPGRADE Step Two #####
# First upgrade the AWS EKS Control Plane, before nodes & kube-system pods
# Update the `../eksctl/cluster-config.yaml`. The {metadata.version} & {managedNodeGroups.maxSize}
#eksctl upgrade cluster --config-file "../eksctl/cluster-config.yaml" --profile $PROFILE  # view the "plan"
#eksctl upgrade cluster --config-file "../eksctl/cluster-config.yaml" --profile $PROFILE --approve  # About 12 minutes
