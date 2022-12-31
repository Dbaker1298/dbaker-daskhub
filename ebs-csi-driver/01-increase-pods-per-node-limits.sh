#!/usr/bin/env bash

## Step 1. Edit the ../eksctl/cluster-config.yaml to include "maxPodsPerNode: 80" under managedNodeGroups:
## and change the name field to upgrade the nodegroup as we did in Phase 1.

PROFILE=admin
REGION=us-west-2
CLUSTER_NAME=dbaker-daskhub-dev
DATE="$(date +%Y-%m)"
K8S_VERSION="1-22"

echo
echo "Yow will first need to update the ../eksctl/cluster-config.yaml"
echo "by changing the {managedNodeGroups.name=ng-managed-ondemand-v${K8S_VERSION}-pod-inc"
echo
sleep 5
##### UPGRADE Step Three #####
#eksctl create nodegroup --config-file "../eksctl/cluster-config.yaml" --profile $PROFILE  # parrallel updated nodegroups
#sleep 10
#kubectl get nodes
#sleep 10
#eksctl delete nodegroup --config-file "../eksctl/cluster-config.yaml" --only-missing --profile $PROFILE --approve
