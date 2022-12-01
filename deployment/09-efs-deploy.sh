#!/bin/bash

## Create K8S persistent volumes and claim

kubectl apply -f ../kubectl/efs-pv.yaml
kubectl apply -n daskhub -f ../kubectl/efs-pvc.yaml
