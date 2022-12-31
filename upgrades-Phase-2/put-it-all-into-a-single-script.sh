#!/usr/bin/env bash

# Update variables first

PROFILE=admin
REGION=us-west-2
CLUSTER_NAME=dbaker-daskhub-dev
DATE="$(date +%Y-%m)"
K8S_VERSION=1.23


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
echo "This output has been saved to a file named:  nodes-pods-pv-pvc-prior-upgrade-${K8S_VERSION}.txt"
echo "****************** Looks Good? You have 15 seconds to abort ... *************************"
######################################################################################################
########################## ADD CONDITIONAL ###########################################################
######################################################################################################

##### UPGRADE Step Two #####
# First upgrade the AWS EKS Control Plane, before nodes & kube-system pods
# Update the `../eksctl/cluster-config.yaml`. The {metadata.version} & {managedNodeGroups.maxSize}

########################## ADD sed edit ###########################################################

eksctl upgrade cluster --config-file "../eksctl/cluster-config.yaml" --profile $PROFILE  # view the "plan"
echo
echo "Looks good?, you have 10 seconds to abort"
######################################################################################################
########################## ADD CONDITIONAL ###########################################################
#####################################################################################################
sleep 10
eksctl upgrade cluster --config-file "../eksctl/cluster-config.yaml" --profile $PROFILE --approve  # About 12 minutes

######################################################################################################
########################## ADD CONDITIONAL ###########################################################
#####################################################################################################

##### UPGRADE Step Three #####
# Update the name of the managed and unmanaged node groups. This will trigger
# the upgrade of the node groups to match the now upgraded Control Plane.
# update the `cluster-config.yaml` "ng-managed-ondemand-v1-23" and "ng-user-compute-spot-2022-12-v1-23"

########################## ADD sed edit ###########################################################
eksctl create nodegroup --config-file "../eksctl/cluster-config.yaml" --profile $PROFILE  # parrallel updated nodegroups
sleep 10
kubectl get nodes
echo
echo "******** Looks Good? You have 10 seconds ... *************"
######################################################################################################
########################## ADD CONDITIONAL ###########################################################
#####################################################################################################

sleep 10
eksctl delete nodegroup --config-file "../eksctl/cluster-config.yaml" --only-missing --profile $PROFILE --approve

kubectl get nodes && kubectl get pods -A
######################################################################################################
########################## ADD CONDITIONAL ###########################################################
#####################################################################################################

echo
echo "Yow will first need to update the ../kubectl//cluster-autoscaler.yaml"

echo "by changing the image to version: v${K8S_VERSION}.2"
########################## ADD sed edit ###########################################################
echo "Then uncomment the last 7 lines"
echo "Remember to verify the variables first"
echo
##### UPGRADE Step Four #####
# Update the ../kubectl/cluster-autoscaler.yaml to new version: v1.20.3 ; v1.21.2 ; v1.22.2 ; v1.23.0 ; v1.24.0
#kubectl apply -f ../kubectl/cluster-autoscaler.yaml
#sleep 3
#kubectl get deploy -n kube-system cluster-autoscaler -oyaml | grep 'image:'
#sleep 2
#kubectl get pod -A
#echo
#echo "Is everything in a RUNNING state?"
######################################################################################################
########################## ADD CONDITIONAL ###########################################################
#####################################################################################################

##### More Work Here for 05-upgrade-* ############ v1.23.7-eksbuild.1 ==> kube-proxy

aws eks describe-addon-versions --addon-name kube-proxy \
 --kubernetes-version $K8S_VERSION --query "addons[].addonVersions[].[addonVersion, compatibilities[].defaultVersion]" \
 --output text --region $REGION --profile $PROFILE



