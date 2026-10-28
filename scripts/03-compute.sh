#!/usr/bin/env bash
# 03 - launch bastion, App-A, App-B (t3.micro, free tier)
set -euo pipefail
AMI=$(aws ssm get-parameters --names /aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64 --query 'Parameters[0].Value' --output text)
BDM='[{"DeviceName":"/dev/xvda","Ebs":{"VolumeSize":8,"DeleteOnTermination":true}}]'
BASTION=$(aws ec2 run-instances --image-id $AMI --instance-type t3.micro --key-name ewb-lab --subnet-id $SUB_PUB --private-ip-address 10.10.1.10 --associate-public-ip-address --security-group-ids $SG_BASTION --block-device-mappings "$BDM" --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=ewb-bastion}]' --query 'Instances[0].InstanceId' --output text)
APP_A=$(aws ec2 run-instances --image-id $AMI --instance-type t3.micro --key-name ewb-lab --subnet-id $SUB_PRIV_A --private-ip-address 10.10.2.10 --no-associate-public-ip-address --security-group-ids $SG_APP_A --block-device-mappings "$BDM" --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=ewb-app-a}]' --query 'Instances[0].InstanceId' --output text)
APP_B=$(aws ec2 run-instances --image-id $AMI --instance-type t3.micro --key-name ewb-lab --subnet-id $SUB_PRIV_B --private-ip-address 10.20.1.10 --no-associate-public-ip-address --security-group-ids $SG_APP_B --block-device-mappings "$BDM" --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=ewb-app-b}]' --query 'Instances[0].InstanceId' --output text)
aws ec2 wait instance-running --instance-ids $BASTION $APP_A $APP_B
BASTION_IP=$(aws ec2 describe-instances --instance-ids $BASTION --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
aws ec2 describe-instances --instance-ids $APP_A $APP_B --query 'Reservations[].Instances[].{Name:Tags[?Key==`Name`]|[0].Value,Priv:PrivateIpAddress,Pub:PublicIpAddress}' --output table
echo "export BASTION=$BASTION APP_A=$APP_A APP_B=$APP_B BASTION_IP=$BASTION_IP"
