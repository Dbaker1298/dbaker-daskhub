#!/bin/bash

## Make absolutely sure you're ready to go and have edited all the files before you run this
helm repo add dask https://helm.dask.org/
helm repo update
helm upgrade dhub dask/daskhub --namespace=daskhub --values=../helm/dh-config.yaml --values=../helm/dh-secrets.yaml --install --debug --version 2022.8.2


## After this is done, you still have work to do:
## Route 53 DNS mapping
## Restart autohttps pod
