#!/usr/bin/env bash

PROFILE=admin
REGION=us-west-2
CLUSTER_NAME=dbaker-daskhub-dev
K8S_VERSION="1.22"

echo
echo "Yow will first need to update the ../kubectl//cluster-autoscaler.yaml"
echo "by changing the image to version: v${K8S_VERSION}.2"
echo
echo "Then uncomment the last 7 lines"
echo "Remember to verify the variables first"
echo
##### UPGRADE Step Four #####
# Update the ../kubectl/cluster-autoscaler.yaml to new version: v1.20.3 ; v1.21.2 ; v1.22.2 ; v1.23.0 ; v1.24.0
#kubectl apply -f ../kubectl/cluster-autoscaler.yaml
#sleep 3
#kubectl get deploy -n kube-system cluster-autoscaler -oyaml | grep 'image:'
#sleep 2
#kubectl get pod -A
#echo
#echo "Is everyting in a RUNNING state?"
