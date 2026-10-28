#!/usr/bin/env bash
# 01 - VPCs, subnets, IGW, route tables
set -euo pipefail
AZ=${AZ:-ap-south-1a}
VPC_A=$(aws ec2 create-vpc --cidr-block 10.10.0.0/16 --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=ewb-vpc-a}]' --query Vpc.VpcId --output text)
SUB_PUB=$(aws ec2 create-subnet --vpc-id $VPC_A --cidr-block 10.10.1.0/24 --availability-zone $AZ --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=ewb-a-public}]' --query Subnet.SubnetId --output text)
SUB_PRIV_A=$(aws ec2 create-subnet --vpc-id $VPC_A --cidr-block 10.10.2.0/24 --availability-zone $AZ --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=ewb-a-private}]' --query Subnet.SubnetId --output text)
VPC_B=$(aws ec2 create-vpc --cidr-block 10.20.0.0/16 --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=ewb-vpc-b}]' --query Vpc.VpcId --output text)
SUB_PRIV_B=$(aws ec2 create-subnet --vpc-id $VPC_B --cidr-block 10.20.1.0/24 --availability-zone $AZ --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=ewb-b-private}]' --query Subnet.SubnetId --output text)
IGW=$(aws ec2 create-internet-gateway --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=ewb-igw-a}]' --query InternetGateway.InternetGatewayId --output text)
aws ec2 attach-internet-gateway --internet-gateway-id $IGW --vpc-id $VPC_A
RT_PUB=$(aws ec2 create-route-table --vpc-id $VPC_A --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=ewb-rt-a-public}]' --query RouteTable.RouteTableId --output text)
aws ec2 create-route --route-table-id $RT_PUB --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW
aws ec2 associate-route-table --route-table-id $RT_PUB --subnet-id $SUB_PUB
RT_PRIV_A=$(aws ec2 create-route-table --vpc-id $VPC_A --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=ewb-rt-a-private}]' --query RouteTable.RouteTableId --output text)
aws ec2 associate-route-table --route-table-id $RT_PRIV_A --subnet-id $SUB_PRIV_A
RT_PRIV_B=$(aws ec2 create-route-table --vpc-id $VPC_B --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=ewb-rt-b-private}]' --query RouteTable.RouteTableId --output text)
aws ec2 associate-route-table --route-table-id $RT_PRIV_B --subnet-id $SUB_PRIV_B
echo "export VPC_A=$VPC_A SUB_PUB=$SUB_PUB SUB_PRIV_A=$SUB_PRIV_A VPC_B=$VPC_B SUB_PRIV_B=$SUB_PRIV_B IGW=$IGW RT_PUB=$RT_PUB RT_PRIV_A=$RT_PRIV_A RT_PRIV_B=$RT_PRIV_B"
