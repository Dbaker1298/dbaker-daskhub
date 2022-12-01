#!/bin/bash

## admin
## us-west-2
## dbaker-daskhub-dev
## 979033099169
## admin

## Creates permissions for SMCE_Admin role

#eksctl --profile <aws-profile> --region <cluster-region> create iamidentitymapping --cluster <cluster-name> --arn arn:aws:iam::<account-number>:role/SMCE_Admin --group system:masters --username admin

## OPTIONAL: To create permissions for an IAM user in the target account

#eksctl --profile <aws-profile> --region <cluster-region> create iamidentitymapping --cluster <cluster-name> --arn arn:aws:iam::<account-number>:user/<iam-user-name> --group system:masters --username admin
eksctl --profile admin --region us-west-2 create iamidentitymapping --cluster dbaker-daskhub-dev --arn arn:aws:iam::979033099169:user/admin --group system:masters --username admin
