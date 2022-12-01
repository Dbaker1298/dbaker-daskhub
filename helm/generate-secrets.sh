#!/bin/bash
key1=$(openssl rand -hex 32)
key2=$(openssl rand -hex 32)

sed -i "s/(1)/$key1/g" dh-secrets.yaml
sed -i "s/(2)/$key2/g" dh-secrets.yaml
