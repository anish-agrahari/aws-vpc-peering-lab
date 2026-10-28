#!/usr/bin/env bash
# 99 - delete EVERYTHING (run same day; verify bill = $0)
set -euo pipefail
aws ec2 terminate-instances --instance-ids $BASTION $APP_A $APP_B
aws ec2 wait instance-terminated --instance-ids $BASTION $APP_A $APP_B
aws ec2 delete-vpc-peering-connection --vpc-peering-connection-id $PCX
for SG in $SG_BASTION $SG_APP_A $SG_APP_B; do aws ec2 delete-security-group --group-id $SG; done
for RT in $RT_PUB $RT_PRIV_A $RT_PRIV_B; do aws ec2 delete-route-table --route-table-id $RT; done
aws ec2 detach-internet-gateway --internet-gateway-id $IGW --vpc-id $VPC_A
aws ec2 delete-internet-gateway --internet-gateway-id $IGW
for S in $SUB_PUB $SUB_PRIV_A $SUB_PRIV_B; do aws ec2 delete-subnet --subnet-id $S; done
aws ec2 delete-vpc --vpc-id $VPC_A
aws ec2 delete-vpc --vpc-id $VPC_B
aws ec2 delete-key-pair --key-name ewb-lab
echo "DONE. Check Billing -> Bills -> this month = 0.00"
