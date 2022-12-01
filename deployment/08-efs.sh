#!/bin/bash

## <aws-profile>
## <cluster-region>
## <cluster-az>


## We're not going to use this yet -- there's more we have to do than just this CLI command so go make it from the console for now!

#aws --profile <aws-profile> --region <cluster-region> efs \
#    efs create-file-system --performance-mode generalPurpose \
#    --encrypted --availability-zone-name <cluster-az> --no-backup


## You will need to manually go to the EFS console and add the proper EKS Cluster Security Groups to the Mount Target
