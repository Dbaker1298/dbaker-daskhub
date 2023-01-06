#!/usr/bin/env bash

# Update variables first

PROFILE=admin
REGION=us-west-2
CLUSTER_NAME=dbaker-daskhub-dev
DATE="$(date +%Y-%m)"
K8S_VERSION=1.24

command-exists() {

  # Check if we have the required commands and fail otherwise
  command -v "$1" >/dev/null 2>&1
  if [[ $? -ne 0 ]]; then 
    echo "I require $1 but it is not installed. Exiting..."
    exit 1
  fi

}

pre-flight-check() {

    for COMMAND in "kubectl" "helm" "aws" "eksctl"; do
      command-exists "${COMMAND}"
    done

    date
    date > nodes-pods-pv-pvc-prior-upgrade-${K8S_VERSION}.txt
    echo
    # Confirm that the nodes match the Control Plane
    echo "++++++++++++++++++++++++++++++++++++++"
    echo "==> Take note of the Server version prior to upgrade, is that right?"
    echo
    kubectl version --output yaml  && kubectl get nodes
    echo
    echo "++++++++++++++++++++++++++++++++++++++"
    echo "Check that the \`eksctl\` version is > 0.122.0"
    echo
    # Check that the `eksctl` version is > 0.121.0
    eksctl version
    echo "The version of eksctl must be greater than 0.122.0"
    echo "++++++++++++++++++++++++++++++++++++++"
    echo

    # Check Nodes, Pods, PVs, and PVCs
    kubectl get nodes,pods,pv,pvc -A && kubectl get nodes,pods,pv,pvc -A >> nodes-pods-pv-pvc-prior-upgrade-${K8S_VERSION}.txt

    echo
    echo "=================================================================="
    echo
    echo "    ************ Scroll up to review the output ************"
    echo
    echo "=================================================================="
    echo
    echo "This output of \`kubectl get nodes,pods,pv,pvc -A\` has been saved to a file named:  nodes-pods-pv-pvc-prior-upgrade-${K8S_VERSION}.txt"
    echo

}


confirmation() {

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

upgrade-control-plane() {

    # First upgrade the AWS EKS Control Plane, before nodes & kube-system pods
    echo "In a separate terminal, edit the \`../eksctl/cluster-config.yaml\`. The {metadata.version=${K8S_VERSION} & {managedNodeGroups.maxSize=3},"
    echo "then answer yes or no to proceed."
    
    confirmation
 
    # Update the `../eksctl/cluster-config.yaml`. The {metadata.version} & {managedNodeGroups.maxSize}

    eksctl upgrade cluster --config-file "../eksctl/cluster-config.yaml" --profile $PROFILE  # view the "plan"
    
    sleep 5

    echo "We will now execute the above plan, which takes about 12 minutes..."

    eksctl upgrade cluster --config-file "../eksctl/cluster-config.yaml" --profile $PROFILE --approve  # About 12 minutes
    echo
    kubectl get nodes

}

upgrade-both-node-groups() {

    # Update the name of the managed and unmanaged node groups. This will trigger
    # the upgrade of the node groups to match the now upgraded Control Plane.
    echo
    echo "Update the \`../eksctl/cluster-config.yaml\` nodeGroupNames; \"{ng-managed-ondemand-v1-2*\" and \"{ng-user-compute-spot-2022-12-v1-23}\""
    echo
    confirmation

    eksctl create nodegroup --config-file "../eksctl/cluster-config.yaml" --profile $PROFILE  # parrallel updated nodegroups
    sleep 10
    kubectl get nodes
    echo
    echo "We will now delete the old nodeGroups..."
    echo
    confirmation

    eksctl delete nodegroup --config-file "../eksctl/cluster-config.yaml" --only-missing --profile $PROFILE --approve

    echo

    kubectl get nodes && kubectl get pods -A

    echo

}

update-cluster-autoscaler-image() {

    echo "Update the ../kubectl/cluster-autoscaler.yaml to the correct version: v1.20.3 ; v1.21.2 ; v1.22.2 ; v1.23.0 ; v1.24.0"
    
    confirmation
    
    kubectl apply -f ../kubectl/cluster-autoscaler.yaml
    sleep 3
    kubectl get deploy -n kube-system cluster-autoscaler -oyaml | grep 'image:'
    echo
    kubectl get pod -A
    
    echo "Are all pods running?"

    confirmation

}

update-coredns-kube-proxy-aws-node() {

    echo
    echo "We are updating the utils: aws-node, kube-proxy, and coredns."
    echo "We may need to edit some manifests at this stage..."

    # Upgrade the `eksctl utils`; aws-node, kube-proxy, coredns

    for i in aws-node kube-proxy coredns ; do eksctl utils update-${i}  --cluster $CLUSTER_NAME --region $REGION --profile $PROFILE --approve ; done

    sleep 10
    kubectl get pod -n kube-system  # Notice the CreateContainerConfigError for aws-node in kube-system namespace
    echo
    echo "We are going to edit the DaemonSet for the aws-node pods if they are in 'CreateContainerConfigError' status..."
    echo "  We must remove 'allowPrivilegeEscalation' and 'runAsNonRoot'"
    sleep 10
    kubectl edit ds -n kube-system aws-node  # remove allowPrivilegeEscalation and runAsNonRoot
    sleep 10
    kubectl get pod -n kube-system
    sleep 10
    echo "Are the kube-proxy pods failing to pull the correct image???"
    ## The kube-proxy image may not be found
    aws eks describe-addon-versions --addon-name kube-proxy --kubernetes-version $K8S_VERSION --query "addons[].addonVersions[].[addonVersion, compatibilities[].defaultVersion]" --output text --region $REGION --profile $PROFILE

    echo "Take note of the default version."
    confirmation
    
    kubectl edit ds -n kube-system kube-proxy  # update the image to the one that is "True" from the above query
    sleep 10
    # Check Nodes, Pods, PVs, and PVCs
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    kubectl get nodes,pods,pv,pvc -A && kubectl get nodes,pods,pv,pvc -A > nodes-pods-pv-pvc-POST-upgrade-${K8S_VERSION}.txt

    echo
    echo "This output has been saved to a file named:  nodes-pods-pv-pvc-POST-upgrade-${K8S_VERSION}.txt"

}

pre-flight-check
confirmation
upgrade-control-plane
upgrade-both-node-groups
update-cluster-autoscaler-image
update-coredns-kube-proxy-aws-node

echo "**********************  We made it! ***********************************"
