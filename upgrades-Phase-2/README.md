# Phase 2 (Upgrades)

Phase 2 of our upgrade path to EKS K8s v1.24 is to first add and update several components and manifests, prior to EKS K8s version 1.23. 

## Key Component Additions and Updates
- Increase managedNodeGroup instances available pod Size (was capped at 17)
- CSI Snapshotter Controller
- EBS CSI Driver EKS AddOn
- Update the existing Storage Class
- AWS Load Balancer Controller deployment (Helm)
- Update the policy attached to the cluster-autoscaler `iamserviceaccount`
- Upgrade to v1.23
- Upgrade to v1.24

## Steps
1. Execute the contents of `../ebs-csi-driver/`
2. Execute the contents of `../load-balancer-controller/`
3. Update the cluster-autoscaler `iamserviceaccount`, there are breaking changes in v1.23
3. Upgrade to EKS v1.23 using scripts `{01-05}-*.sh`, first updating the variables of each file. 
4. Upgrade to EKS v1.24 using scripts `{01-05}-*.sh`, first updating the variables of each file.

## Next Steps
After Phase 2, we will transition into a Regual Upgrade Cadence to stay current with the AWS EKS Kubernetes release calendar.
[EKS Kubernetes Release Calendar](https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html#kubernetes-release-calendar)
