# Evidence checklist (screenshot each, save here)

- [ ] Route table associations + public 0.0.0.0/0 -> igw route (Checkpoint 01)
- [ ] 3 instance IDs + private IPs; App-A/App-B Public IPv4 empty (Checkpoint 02)
- [ ] Peering connection: Name, Active status, both VPC IDs (Checkpoint 03)
- [ ] All 3 route tables with pcx routes (Checkpoint 04)
- [ ] Test 01 baseline: 100% packet loss
- [ ] Test 02 forward ping: 4 replies, 0% loss
- [ ] Test 03 reverse ping: 4 replies, 0% loss
- [ ] Test 04: hostname/hostname -I on App-B via ProxyJump
- [ ] Test 05: ICMP rule removed -> loss; restored -> success
- [ ] Billing: current month total $0.00 after cleanup
