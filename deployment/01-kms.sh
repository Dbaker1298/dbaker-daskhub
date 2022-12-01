#!/bin/bash

## admin
## us-west-2
## dbaker-daskhub-dev

## Creates and returns the cluster encryption key that is required for the cluster-config.yaml file

aws --profile admin --region us-west-2 kms create-alias --alias-name alias/dbaker-daskhub-dev --target-key-id $(aws --profile admin --region us-west-2 kms create-key --query KeyMetadata.Arn --output text)

aws --profile admin --region us-west-2 kms describe-key --key-id alias/dbaker-daskhub-dev --query KeyMetadata.Arn --output text
