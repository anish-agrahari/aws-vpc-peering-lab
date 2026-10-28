#!/usr/bin/env bash
# 02 - key pair + security groups (needs 01 exports in shell)
set -euo pipefail
aws ec2 create-key-pair --key-name ewb-lab --query 'KeyMaterial' --output text > ewb-lab.pem && chmod 400 ewb-lab.pem
MYIP=$(curl -s ifconfig.me)/32
SG_BASTION=$(aws ec2 create-security-group --group-name ewb-sg-bastion --description bastion --vpc-id $VPC_A --query GroupId --output text)
aws ec2 authorize-security-group-ingress --group-id $SG_BASTION --protocol tcp --port 22 --cidr $MYIP
SG_APP_A=$(aws ec2 create-security-group --group-name ewb-sg-app-a --description app-a --vpc-id $VPC_A --query GroupId --output text)
aws ec2 authorize-security-group-ingress --group-id $SG_APP_A --protocol tcp --port 22 --cidr 10.10.1.10/32
aws ec2 authorize-security-group-ingress --group-id $SG_APP_A --protocol icmp --port -1 --cidr 10.20.1.10/32
SG_APP_B=$(aws ec2 create-security-group --group-name ewb-sg-app-b --description app-b --vpc-id $VPC_B --query GroupId --output text)
aws ec2 authorize-security-group-ingress --group-id $SG_APP_B --protocol tcp --port 22 --cidr 10.10.1.10/32
aws ec2 authorize-security-group-ingress --group-id $SG_APP_B --protocol icmp --port -1 --cidr 10.10.2.10/32
echo "export SG_BASTION=$SG_BASTION SG_APP_A=$SG_APP_A SG_APP_B=$SG_APP_B"
