#!/usr/bin/env bash

# Update variables first

PROFILE=
REGION=
CLUSTER_NAME=
DATE="$(date +%Y-%m)"
K8S_VERSION=1.23

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
  echo "==> Take note of the Server version prior to upgrade, is that correct for this cluster?"
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
  kubectl get nodes,pods,pv,pvc -A && kubectl get nodes,pods,pv,pvc -A > nodes-pods-pv-pvc-prior-upgrade-${K8S_VERSION}.txt

  echo
  echo "=================================================================="
  echo
  echo "    ************ Scroll up to review the output ************"
  echo
  echo "=================================================================="
  echo
  echo "This output of \`kubectl get nodes,pods,pv,pvc -A\` has been saved to a file named:  nodes-pods-pv-pvc-prior-upgrade-${K8S_VERSION}.txt"
  echo
  echo "     *********** Did you update the variables? *************"
  echo "     ******** Do you have a second terminal open? **********"

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

backup-cluster-config() {
  echo
  echo "Backing up the ../eksctl/cluster-config.yaml"

  cp ../eksctl/cluster-config.yaml ../eksctl/cluster-config.yaml.backup.$(date +%F_%R)

  ls -ltr ../eksctl

  echo
  echo "Is the backup file in place?"

  confirmation

}

upgrade-control-plane() {

  # First upgrade the AWS EKS Control Plane, before nodes & kube-system pods
  echo "In a separate terminal, edit the \`../eksctl/cluster-config.yaml\`. The {metadata.version=${K8S_VERSION}, {managedNodeGroups.maxSize=3}, and managedNodeGroups.desiredCapacity=2"
  echo "then answer yes or no in this terminal to proceed."
  
  confirmation

  eksctl upgrade cluster --config-file "../eksctl/cluster-config.yaml" --profile $PROFILE  # view the "plan"
  
  echo 
  echo "Does the plan look correct for upgrading to EKS v${K8S_VERSION}? "

  confirmation

  echo "We will now execute the above plan, which takes about 12 minutes..."

  eksctl upgrade cluster --config-file "../eksctl/cluster-config.yaml" --profile $PROFILE --approve  # About 12 minutes

  echo

  kubectl get nodes

}

upgrade-both-node-groups() {

  # Update the name of the managed and unmanaged node groups. This will trigger
  # the upgrade of the node groups to match the now upgraded Control Plane.
  echo
  echo "Update the \`../eksctl/cluster-config.yaml\` nodeGroupNames; \"{ng-managed-ondemand-v1-2*\" and \"{ng-user-compute-spot-2022-12-v1-2*}\""
  echo

  confirmation

  eksctl create nodegroup --config-file "../eksctl/cluster-config.yaml" --profile $PROFILE 

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

  echo "In your second terminal, update the ../kubectl/cluster-autoscaler.yaml to the correct version:  v1.23.0 or v1.24.0"
  
  confirmation
  
  kubectl apply -f ../kubectl/cluster-autoscaler.yaml
  sleep 3

  kubectl get deploy -n kube-system cluster-autoscaler -oyaml | grep 'image:'
  echo

  kubectl get pod -A
  
  echo "Are all pods running? You may need to monitor in other terminal before proceeding..."

  confirmation

}

update-coredns-kube-proxy() {

  echo
  echo "We are updating the utils: kube-proxy, and coredns."
  echo "We may need to edit some kube-proxy deployment image at this stage..."
  echo ""

  # Upgrade the `eksctl utils`; kube-proxy, coredns

  for i in kube-proxy coredns ; do eksctl utils update-${i}  --cluster $CLUSTER_NAME --region $REGION --profile $PROFILE --approve ; done

  sleep 10
  kubectl get pod -n kube-system  
  echo

  echo "Are the kube-proxy pods failing to pull the correct image???"
  ## The kube-proxy image may not be found
  aws eks describe-addon-versions --addon-name kube-proxy --kubernetes-version $K8S_VERSION --query "addons[].addonVersions[].[addonVersion, compatibilities[].defaultVersion]" --output text --region $REGION --profile $PROFILE

  echo "Take note of the default version. We will edit the DaemonSet in this terminal when you proceed..."

  confirmation
  
  kubectl edit ds -n kube-system kube-proxy  # update the image to the one that is "True" from the above query
  sleep 10

  # Check Nodes, Pods, PVs, and PVCs
  echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  kubectl get nodes,pods,pv,pvc -A && kubectl get nodes,pods,pv,pvc -A >> nodes-pods-pv-pvc-POST-upgrade-${K8S_VERSION}.txt

  echo
  echo "This output has been saved to a file named:  nodes-pods-pv-pvc-POST-upgrade-${K8S_VERSION}.txt"

}

pre-flight-check
confirmation
backup-cluster-config
upgrade-control-plane
upgrade-both-node-groups
update-cluster-autoscaler-image
update-coredns-kube-proxy

echo "**********************  We made it! ***********************************"
