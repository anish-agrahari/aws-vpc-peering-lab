#!/usr/bin/env bash
# 04 - baseline failure test, peering, routes, verification
set -euo pipefail
echo "=== TEST 01: baseline (expect 100% packet loss) ==="
ssh -i ewb-lab.pem -J ec2-user@$BASTION_IP -o StrictHostKeyChecking=accept-new ec2-user@10.10.2.10 "ping -c 4 10.20.1.10" || true
read -p "Screenshot the failure, then press Enter to create peering..."
PCX=$(aws ec2 create-vpc-peering-connection --vpc-id $VPC_A --peer-vpc-id $VPC_B --tag-specifications 'ResourceType=vpc-peering-connection,Tags=[{Key=Name,Value=ewb-a-b-peer}]' --query VpcPeeringConnection.VpcPeeringConnectionId --output text)
aws ec2 accept-vpc-peering-connection --vpc-peering-connection-id $PCX
sleep 5
aws ec2 create-route --route-table-id $RT_PRIV_A --destination-cidr-block 10.20.0.0/16 --vpc-peering-connection-id $PCX
aws ec2 create-route --route-table-id $RT_PRIV_B --destination-cidr-block 10.10.0.0/16 --vpc-peering-connection-id $PCX
aws ec2 create-route --route-table-id $RT_PUB   --destination-cidr-block 10.20.0.0/16 --vpc-peering-connection-id $PCX
echo "=== TEST 02: App-A -> App-B (expect 4 replies) ==="
ssh -i ewb-lab.pem -J ec2-user@$BASTION_IP ec2-user@10.10.2.10 "ping -c 4 10.20.1.10"
echo "=== TEST 03: App-B -> App-A (expect 4 replies) ==="
ssh -i ewb-lab.pem -J ec2-user@$BASTION_IP ec2-user@10.20.1.10 "ping -c 4 10.10.2.10"
echo "=== TEST 04: SSH to App-B via bastion ==="
ssh -i ewb-lab.pem -J ec2-user@$BASTION_IP ec2-user@10.20.1.10 "hostname; hostname -I"
echo "=== TEST 05 (manual): remove ICMP rule from ewb-sg-app-b, re-run TEST 02 (expect loss), restore rule, re-run (expect success) ==="
echo "export PCX=$PCX"
