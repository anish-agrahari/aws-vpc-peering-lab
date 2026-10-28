# Architecture Notes

## Why these CIDRs?
10.10.0.0/16 and 10.20.0.0/16 cannot overlap — overlapping CIDRs make peering
creation fail (checked against primary AND secondary CIDRs). Subnets are /24s
inside their own VPC range.

## Route tables (3 explicit, custom — not defaults)
| Route table | Subnet association | Routes |
|---|---|---|
| ewb-rt-a-public | ewb-a-public (10.10.1.0/24) | local; 0.0.0.0/0 → igw; **10.20.0.0/16 → pcx** |
| ewb-rt-a-private | ewb-a-private (10.10.2.0/24) | local; **10.20.0.0/16 → pcx** |
| ewb-rt-b-private | ewb-b-private (10.20.1.0/24) | local; **10.10.0.0/16 → pcx** |

The public subnet's pcx route exists because ProxyJump makes the *bastion itself*
open the second SSH connection to App-B.

## Security groups (inbound only; outbound allow-all; stateful)
| SG | Rule | Source |
|---|---|---|
| ewb-sg-bastion | SSH 22 | my public IP /32 |
| ewb-sg-app-a | SSH 22 / ICMP echo | 10.10.1.10/32 / 10.20.1.10/32 |
| ewb-sg-app-b | SSH 22 / ICMP echo | 10.10.1.10/32 / 10.10.2.10/32 |

## Troubleshooting matrix
| Symptom | Check |
|---|---|
| Bastion SSH timeout | current public IP /32 in SG; subnet association; 0.0.0.0/0→igw route |
| App-A SSH fails | private IP correct; TCP22 from 10.10.1.10/32; key + ec2-user |
| App-B SSH fails | public RT has pcx route; VPC B return route; SG source = bastion *private* IP |
| Ping fails after accept | BOTH private RTs have pcx routes; pcx Active; ICMP echo rule on destination |
| Peering creation fails | any overlapping CIDR on either VPC (incl. secondary) |
| Permission denied (publickey) | key pair, IdentityFile, ec2-user — routing is fine if you reached auth |

## Architecture
<img width="2752" height="1536" alt="architecture_aws-vpc" src="https://github.com/user-attachments/assets/2cfd16a9-c016-45f1-a8ee-579767264407" />


## Can VPC B reach the internet via VPC A's IGW over peering?
No — peering never provides transitive internet access. VPC B stays fully private
(no NAT gateway needed, which keeps the lab free).
