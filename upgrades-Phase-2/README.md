# Phase 2 Upgrades

Phase 2 of our upgrade path to EKS Kubernetes v1.24 is to first add and update several components and manifests, prior to EKS Kubernetes version 1.23.

## Key Component Additions and Updates
- Install the vpc-cni and increase the managedNodeGroup instances available pod Size (was capped at 17 pods per node)
- Install CSI Snapshotter Controller
- Install EBS CSI Driver EKS AddOn
- Update the existing Storage Class
- Install AWS Load Balancer Controller deployment (Helm)
- Update the policy attached to the `cluster-autoscaler` `iamserviceaccount`
- Upgrade to v1.23
- Upgrade to v1.24

## Steps
1. Update the variables inside `convert-vpc-cni-to-helm.sh` of `../vpc-cni-addon/` and execute that script.
2. Update the variables inside `install-csi-addon.sh` of `../ebs-csi-driver/` and execute that script.
3. Update the variables of `install-load-balancer-controller.sh` of `../load-balancer-controller/` and execute that script.
4. Execute the `./Update-cluster-autoscaler.sh` script only **once** before we upgrade to v1.23. The `cluster-autoscaler` `iamserviceaccount` policy must be modified; there are breaking changes in v1.23.
5. Update the variables inside `./phase-2-upgrade-EKS.sh` for v1.23 and execute that script to upgrade to EKS v1.23.
6. Update the variables inside `./phase-2-upgrade-EKS.sh` for v1.24 and execute that script to upgrade to EKS v1.24.

### References
[Managing VPC CNI](https://docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html)
[AWS VPC CNI Charts](https://github.com/aws/eks-charts/tree/master/stable/aws-vpc-cni)
[AWS VPC CNI Source](https://github.com/aws/amazon-vpc-cni-k8s)
[CSI IAM role](https://docs.amazonaws.cn/en_us/eks/latest/userguide/csi-iam-role.html)
[K8s External Snapshotter](https://github.com/kubernetes-csi/external-snapshotter#usage)
[AWS EBS CSI Driver add-on](https://docs.aws.amazon.com/eks/latest/userguide/managing-ebs-csi.html)
[AWS Load Balancer Controller](https://docs.amazonaws.cn/en_us/eks/latest/userguide/aws-load-balancer-controller.html)



## Next Steps
After Phase 2, we will transition into a Regular Upgrade Cadence to stay current with the AWS EKS Kubernetes release calendar. With a regular Upgrade Cadence, we will not have as many steps and modifications at one time.
[EKS Kubernetes Release Calendar](https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html#kubernetes-release-calendar)
