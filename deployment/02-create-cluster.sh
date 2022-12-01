#!/bin/bash

## admin
## us-west-2
## dbaker-daskhub-dev


## This creates the cluster from the Cluster Config file

eksctl --profile admin create cluster -f ../eksctl/cluster-config.yaml

## This will create and activate the new context in the .kube/config file locally

aws --profile admin --region us-west-2 eks update-kubeconfig --name dbaker-daskhub-dev
