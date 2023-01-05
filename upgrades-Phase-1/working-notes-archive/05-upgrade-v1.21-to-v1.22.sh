#!/usr/bin/env bash


{
PROFILE=admin
REGION=us-west-2
CLUSTER_NAME=dbaker-daskhub-dev
K8S_VERSION="1.22"
}

echo
echo "Yow will need to run these manually for now"
echo "First check to see if we even need to update these utils..."
##### UPGRADE Step Four; This Requires some manual edits due to the older versions of 1.19, 1.20, 1.21 #####
# Upgrade the `eksctl utils`; aws-node, kube-proxy, coredns

#for i in aws-node kube-proxy coredns ; do eksctl utils update-${i} --verbose 4 --cluster $CLUSTER_NAME --region $REGION --profile $PROFILE --approve ; done

#kubectl get pod -n kube-system  # Notice the CreateContainerConfigError for aws-node in kube-system namespace

#kubectl edit ds -n kube-system aws-node  # remove allowPrivilegeEscalation and runAsNonRoot

#kubectl get pod -n kube-system -w

## The kube-proxy image may not be found
#aws eks describe-addon-versions --addon-name kube-proxy --kubernetes-version $K8S_VERSION --query "addons[].addonVersions[].[addonVersion, compatibilities[].defaultVersion]" --output text --region $REGION --profile $PROFILE

#kubectl edit ds -n kube-system kube-proxy  # update the image to the one that is "True" from the above query

#kubectl get pod -n kube-system
#kubectl get pod -A

#k get nodes

## kubectl get nodes,pods,pv,pvc -A

# Check Nodes, Pods, PVs, and PVCs
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
kubectl get nodes,pods,pv,pvc -A && kubectl get nodes,pods,pv,pvc -A > nodes-pods-pv-pvc-POST-upgrade-${K8S_VERSION}.txt

echo
echo "This output has been saved to a file named:  nodes-pods-pv-pvc-POST-upgrade-${K8S_VERSION}.txt"

##### All Pods are RUNNING and Nodes are of the correct K8s Version #####
