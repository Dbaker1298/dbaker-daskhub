#!/usr/bin/env bash

## https://github.com/kubernetes-csi/external-snapshotter#usage
## The external snapshotter must be installed BEFORE the EBS CSI Add-On ##
## First the CRDs, then the Volume snapshot Controller, and lastly the EBS CSI Driver

kubectl kustomize ext-snapshotter-crd | kubectl create -f -

sleep 5

kubectl kustomize csi-snapshotter-controller-deploy | kubectl create -f -
