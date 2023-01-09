#!/usr/bin/env bash
ACCOUNT_NUMBER=123456789

install-csi-add-on() {

  echo
  echo "Edit the ../eksctl/cluster-config.yaml to include the addOn."
  cat << EoF >> ../eksctl/test-file.yaml

addons:
- name: aws-ebs-csi-driver
  version: 1.14.0
  serviceAccountRoleARN: arn:aws:iam::${ACCOUNT_NUMBER}:role/AmazonEKS_EBS_CSI_DriverRole
  resolveConflicts: overwrite
EoF

}

install-csi-add-on
sleep 3
echo "All Done."
