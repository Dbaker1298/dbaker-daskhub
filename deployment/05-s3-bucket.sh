#!/bin/bash

## admin
## us-west-2
## <cluster-bucket-name>-users
## <cluster-bucket-name>-shared
## <cluster-bucket-name>-curated

## Create bucket

aws --profile admin --region us-west-2 s3 mb s3://dbaker-daskhubdev-users 
aws --profile admin --region us-west-2 s3 mb s3://dbaker-daskhubdev-shared
aws --profile admin --region us-west-2 s3 mb s3://dbaker-daskhubdev-curated



