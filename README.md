# AWS VPC Peering Lab — Private Connectivity Between Two VPCs

> Hands-on AWS networking project: connect two VPCs with VPC peering so private
> EC2 instances communicate over private IPv4 — with a bastion host, scoped
> security groups, and controlled failure testing. Built entirely on AWS Free Tier (~$0).

## Architecture
- **VPC A** `10.10.0.0/16` — public subnet `10.10.1.0/24` (bastion, auto public IP) + private subnet `10.10.2.0/24` (App-A, no public IP)
- **VPC B** `10.20.0.0/16` — private subnet `10.20.1.0/24` (App-B, no public IP, no IGW)
- **VPC peering** `ewb-a-b-peer` with routes on **both sides** (peering is non-transitive; a route in only one direction fails)
- **Admin path:** laptop -> bastion (SSH/22) -> App-A / App-B via `ProxyJump`
- **App path:** App-A <-> App-B over private IPs through the peering connection

<img width="2752" height="1536" alt="architecture_aws-vpc_" src="https://github.com/user-attachments/assets/ae68660d-c00d-499e-a1b4-edbb5f32b39d" />



## What This Project Demonstrates
| Concept | Evidence |
|---|---|
| Non-overlapping CIDR planning | 10.10.0.0/16 vs 10.20.0.0/16 |
| Explicit route tables + subnet associations | `docs/architecture.md` |
| VPC peering request -> accept -> **Active** | `evidence/` screenshots |
| Forward **and** return routes (one-way routing fails) | baseline failure vs post-routing success |
| Least-privilege security groups (/32 host rules) | `docs/architecture.md` |
| Bastion pattern with SSH ProxyJump (no keys copied) | Test 04 |
| Negative testing (rule removal breaks, restore fixes) | Test 05 |
| Free-tier discipline + full cleanup ($0.00 bill) | `scripts/99-cleanup.sh` |

## Quick Start (AWS Free Tier, ~90 min, $0 if cleaned same day)
1. Set a **$1 billing alarm** (CloudWatch -> Billing -> EstimatedCharges).
2. Open AWS CloudShell (browser terminal — nothing to install).
3. Run the scripts **in order**; each prints `export ...` lines — paste them into your shell so later steps know the IDs:
   ```bash
   ./scripts/01-network.sh      # VPCs, subnets, IGW, route tables
   ./scripts/02-security.sh     # key pair + security groups
   ./scripts/03-compute.sh      # bastion, App-A, App-B (t3.micro)
   ./scripts/04-peering.sh      # baseline failure test -> peering -> routes -> verify
   ./scripts/99-cleanup.sh      # terminate + delete everything, verify $0 bill
   ```
4. Save terminal output + console screenshots into `evidence/` as you go (`docs/evidence.md` is the checklist).

## Test Results (acceptance criteria)
| # | Test | Command (via bastion ProxyJump) | Expected |
|---|---|---|---|
| 01 | Baseline **before** peering | `ping -c 4 10.20.1.10` | 100% packet loss |
| 02 | Forward path | `ping -c 4 10.20.1.10` from App-A | 4 replies, 0% loss |
| 03 | Reverse path | `ping -c 4 10.10.2.10` from App-B | 4 replies, 0% loss |
| 04 | Private SSH via bastion | `ssh -J ec2-user@<bastion-ip> ec2-user@10.20.1.10` | shell on App-B |
| 05 | Controlled failure | remove ICMP rule from ewb-sg-app-b -> repeat 02 | loss; restore -> success |
| 06 | Isolation | EC2 console: App-A / App-B | Public IPv4 = empty |

## Key Lessons
- **Active peering != connectivity.** Routes in *both* route tables and matching security-group rules are required.
- **Peering is one-to-one and non-transitive** — A<->B plus A<->C gives no B<->C.
- **The bastion's public subnet needs a peering route too** — ProxyJump opens a second SSH connection from the bastion; the more-specific `10.20.0.0/16` beats the `0.0.0.0/0` IGW route.
- **Security groups are stateful** — allow inbound echo request only; replies flow automatically.

## Cost
Free tier: 3 x t3.micro for a few hours + 1 public IPv4 + 24 GB EBS — all within the 12-month free allowance. Cleanup script removes every resource the same day; final bill verified $0.00.

## License
MIT — reuse freely with attribution.
