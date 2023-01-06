# Phase 1 Upgrades

Phase 1 will take the EKS clusters to v1.22.

This Phase 1 is necessary because of the breaking changes of v1.23, additional manifests, and configuration changes.
Phase 2 will take EKS clusters to v1.24.

## Set Up
- Log in to the respective AWS and match it to the GitLab repository.
- Git clone the repository locally and `git checkout -b upgrade-phase-1`.
- Have your MFA token generator app ready.
- List the cluster: aws eks list-clusters --region $REGION --profile $PROFILE
- Set your `kubectl config current-context` to this clusters credentials.
- You may need to `aws eks --region $REGION update-kubeconfig --name $CLUSTER_NAME --profile $PROFILE`
- Log into the Daskhub instance and spin up a Small Server to confirm functionality.
- `kubectl get pods -A` to verify all pods are running.

## Upgrade Steps
- Update the variables of the `phase-1-upgrade-EKS.sh` file.
- The `../upgrades-Phase-1/` directory is the working directory.
- Open two terminals in that working directory. One for the `phase-1-upgrade-EKS.sh` script and one to make working edits throughout the automation. Please read all output carefully during the upgrade. There are several `confirmation` steps built in.
- Be patient with the confirmations and validate results in the second terminal if necessary. Kubernetes will always need some time to "settle."
- Your upgrade path we go from [1.19 to 1.20], [1.20 to 1.21], and [1.21 to 1.22]. The `phase-1-upgrade-EKS.sh` script will be executed three times in this instance.
- The current version of the EKS cluster will dictate how many script executions are to reach v1.22.
- Each upgrade will change the `K8S_VERSION` variable in the script.
- Review the script before execution.

Go forth and conquer.
