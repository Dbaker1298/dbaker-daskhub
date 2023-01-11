# Install AWS Load Balancer Controller

The AWS Load Balancer Controller manages AWS Elastic Load Balancers for a Kubernetes cluster. This step is only performed once per cluster. It will be maintained and upgraded in the future following our Regular Upgrade Cadence.

## Steps
0. Update the variables of the `./install-load-balancer-controller.sh` script and review the details of the script.
1. Open two terminals in the current working directory of `./load-balancer-controller/`. One for script execution and one for monitoring the cluster.
2. Execute the `./install-load-balancer-controller.sh` script in the first terminal.
3. Monitor the progress in the second terminal with `kubectl` commands if necessary.

## References
[AWS Load Balancer Controller Docs](https://docs.amazonaws.cn/en_us/eks/latest/userguide/aws-load-balancer-controller.html)
[Associated IAM Policy](https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.5/docs/install/iam_policy.json)

