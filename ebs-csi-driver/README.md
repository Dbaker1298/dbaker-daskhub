# AWS EBS CSI Driver Installation

Prior to upgrading to Kubernetes v1.23, it is required that we transition from the current "in-tree" storage provider to the AWS EBS CSI provider. The Amazon Elastic Block Store (Amazon EBS) Container Storage Interface (CSI) driver allows Amazon Elastic Kubernetes Service (Amazon EKS) clusters to manage the lifecycle of Amazon EBS volumes for persistent volumes.
This specific installation is only performed once per cluster. It will be maintained and upgraded with our Regular Upgrade Cadence.

## Steps
0. Update the variables in the `./install-csi-addon.sh` file and review the details of the script and supporting directories.
1. Open two terminals in the current working directory of `./ebs-csi-driver/`. One for script execution and one for monitoring the cluster.
1. Execute the `./install-csi-addon.sh` script in the first terminal.
2. Monitor the progress in the second terminal with `kubectl` commands if necessary.

## References
[AWS EBS CSI Driver User Guide](https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html)
[CSI IAM Role for ServiceAccount](https://docs.amazonaws.cn/en_us/eks/latest/userguide/csi-iam-role.html)
[Kubernetes External Snapshotter](https://github.com/kubernetes-csi/external-snapshotter#usage)
[Managing the AWS CSI Add-On](https://docs.aws.amazon.com/eks/latest/userguide/managing-ebs-csi.html)

