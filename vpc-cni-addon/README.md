# Helm Install the AWS VPC CNI
Many of our EKS clusters have a "Self-Managed" add-on for the vpc-cni. In many instances, this add-on is not managed by Helm, but rather it is managed indirectly with `eksctl`. This leads to some irregular behavior when upgrading the EKS Cluster and we are not able to easily customize and configure the Daemonset. We are not deleting the existing `aws-node` resources in the cluster that run the aws-vpc-cni, but rather we will adopt the resources into a release instead. This is performed within the script.
This installation is done only once per cluster and it is necessary to first identify whether the vpc-cni is "EKS Managed" or "Self-Managed." This is verified within the script execution.
The `./values.yaml` has the required configuration changes with corresponding comments. You will need to edit file with the respective variables before execution.

## Steps
0. Update the variables in the `./values.yaml` and the variables in the `./convert-vpc-cni-to-helm.sh`. Review the details of both files.
1. Open two terminals in the current working directory of `./vpc-cni-addon/`. One for script execution and one for monitoring the cluster.
2. Execute the `./convert-vpc-cni-to-helm.sh` script in the first terminal.
3. Monitor the progress in the second terminal with `kubectl` commands if necessary.

## References
[Managing AWS VPC CNI](https://docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html)
[AWS VPC CNI Chart](https://github.com/aws/eks-charts/tree/master/stable/aws-vpc-cni)
[AWS VPC CNI K8s Source](https://github.com/aws/amazon-vpc-cni-k8s)
[Increase default Pod IPs for an EKS Cluster](https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html)
