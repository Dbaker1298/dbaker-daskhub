#!/usr/bin/env bash

# Update variables first and Follow steps 1 - 6

PROFILE=admin
REGION=us-west-2
CLUSTER_NAME=dbaker-daskhub-dev
K8S_VERSION=1.23

# 1.  Log in to the respective AWS account and match it to the GitLab account.
# 2.  Git clone the Gitlab locally and `git checkout -b upgrade-to-v1.xx`
# 3.  Log into the actual Daskhub instance and spin up a small server.
# 4.  List clusters: aws eks list-clusters --region $REGION --profile $PROFILE
# 5.  Set "update-kubeconfig" or "use-context"
# 	5a.  aws eks --region $REGION update-kubeconfig --name $CLUSTER_NAME --profile $PROFILE
# 	5b.  kubectl config get-contexts ; kubectl use-context arn:aws:eks:$REGION:xxxxxxxxxxxx:cluster/$CLUSTER_NAME ; kubectl config current-context
# 6.  ##### ACTUAL_UPGRADE ##### 

##### ACTUAL_UPGRADE #####
##### Pre-Flight Checks #####

# Confirm that the nodes match the Control Plane
echo "++++++++++++++++++++++++++++++++++++++"
echo "==> Take note of the Server version prior to upgrade, is that right?"
echo
kubectl version --output yaml  && kubectl get nodes
echo
echo "++++++++++++++++++++++++++++++++++++++"
echo

# Ensure that the pod security policies are enabled.
kubectl get psp -A
echo
echo "++++++++++++++++++++++++++++++++++++++"
echo "Check that the \`eksctl\` version is > 0.121.0"
echo

# Check that the `eksctl` version is > 0.121.0
eksctl version
echo
echo "++++++++++++++++++++++++++++++++++++++"
echo

# Check Nodes, Pods, PVs, and PVCs
kubectl get nodes,pods,pv,pvc -A && kubectl get nodes,pods,pv,pvc -A > nodes-pods-pv-pvc-prior-upgrade-${K8S_VERSION}.txt

echo
echo "=================================================================="
echo
echo "Scroll up to review the output"
echo
echo "=================================================================="
echo "WAIT!!!! Did you perform steps 1 to 6 first?"
echo
echo "This output has been saved to a file named:  nodes-pods-pv-pvc-prior-upgrade-${K8S_VERSION}.txt"
