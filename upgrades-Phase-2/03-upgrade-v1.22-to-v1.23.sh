#!/usr/bin/env bash

PROFILE=admin
REGION=us-west-2
CLUSTER_NAME=dbaker-daskhub-dev
DATE="$(date +%Y-%m)"
K8S_VERSION="1-23"

echo
echo "Yow will first need to update the ../eksctl/cluster-config.yaml"
echo "by changing the {managedNodeGroups.name=ng-managed-ondemand-v${K8S_VERSION} and"
echo "{nodeGroups.name=ng-user-compute-spot-${DATE}-v${K8S_VERSION}"
echo
echo "Then uncomment the 6th to 2nd to last lines. Afterwhich, if the plan looks good, comment them back and uncomment the last line"
echo "Remember to verify the variables first"
echo
##### UPGRADE Step Three #####
# Update the name of the managed and unmanaged node groups. This will trigger 
# the upgrade of the node groups to match the now upgraded Control Plane.
# update the `cluster-config.yaml` "ng-managed-ondemand-v1-23" and "ng-user-compute-spot-2022-12-v1-23"
eksctl create nodegroup --config-file "../eksctl/cluster-config.yaml" --profile $PROFILE  # parrallel updated nodegroups
sleep 10
kubectl get nodes
echo
echo "******** Looks Good? You have 10 seconds ... *************"
sleep 10
eksctl delete nodegroup --config-file "../eksctl/cluster-config.yaml" --only-missing --profile $PROFILE --approve
