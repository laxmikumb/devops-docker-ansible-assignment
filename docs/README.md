# DevOps Technical Assessment - Implementation Documentation

## 1. Docker Setup
- Three containers (vm1, vm2, vm3) built from a custom Ubuntu 22.04 image with SSH, Nginx, and UFW pre-installed.
- Custom bridge network vmnet with a defined subnet 172.28.0.0/24 (not Docker's default auto-assigned network).
- All containers run with --restart unless-stopped, verified by killing the Nginx process inside a container and confirming Docker restarted it automatically.
- Host-level firewall (UFW) configured inside each container: default-deny inbound, SSH allowed only from the vmnet subnet, ports 80/443 opened only on vm1.

## 2. SSH Hardening
- OpenSSH Server installed in all three containers.
- A dedicated deployer user authenticates via SSH key only.
- PasswordAuthentication no and PermitRootLogin no set in sshd_config.
- Verified: key-based login succeeds; password login rejected; root login rejected.

## 3. Domain and TLS Configuration
- public.vm1.local, public.vm2.local, public.vm3.local mapped in the Windows hosts file.
- Self-signed TLS certificate generated via OpenSSL for public.vm1.local.
- Nginx on vm1 redirects HTTP to HTTPS with a 301 redirect, verified via curl.

## 4. Ansible Automation
- Inventory (inventory.ini) lists all three hosts; ansible.cfg configures the SSH key path and vault password file.
- Connectivity verified with ansible all -m ping (all three hosts return pong).
- Playbook (site.yml) structured into three roles: common, ssh, nginx.
- Secrets stored via ansible-vault encrypt_string; no plaintext passwords committed.
- Idempotency proven: run1.log and run2.log show the second run reporting changed=0 across all hosts.

## 5. Nginx Dynamic Pages
- Each VM serves a page generated dynamically per request using Nginx's built-in SSI, no backend code required.
- Verified by requesting the same page twice and observing the timestamp change each time.

## 6. Reverse Proxy and Load Balancing
- vm1's Nginx configured as a reverse proxy: /vm2/ and /vm3/ route to their respective backends.
- /app/ load-balances across vm2 and vm3 using an upstream block with passive health checking (max_fails and fail_timeout).
- Failover test (full log in failover.log): a curl loop was run against /app/ every second. When vm2 was stopped, all requests continued succeeding via vm3. When vm2 was restarted, it automatically rejoined the rotation with no manual Nginx reload at any point.

## 7. Key Assumptions
- Docker Desktop on Windows/WSL2 did not expose the custom bridge network's container IPs directly to the WSL2 host terminal. Containers are reached from the host via published ports bound to 127.0.0.1 only, while container-to-container traffic uses the internal 172.28.0.0/24 addresses directly.
- Active health checking is an Nginx Plus-only feature. This project uses Nginx's built-in passive health check, which satisfies the intent of the requirement using free, open-source tooling.
- .local domains and a self-signed certificate stand in for a real domain and CA-issued certificate, per the zero-cost constraint in the brief.

## 8. Verification Commands Reference
- Containers running: docker ps
- Auto-restart: docker exec vm2 pkill -9 nginx then docker ps
- Key SSH: ssh -i docker/vm_key -p 2201 deployer@localhost
- Password rejected: ssh -o PreferredAuthentications=password -p 2201 deployer@localhost
- Domain resolution: ping public.vm1.local
- HTTPS and redirect: curl -Ik http://public.vm1.local:8080 and curl -Ik https://public.vm1.local:8443
- Ansible connectivity: ansible all -m ping
- Idempotency: ansible-playbook site.yml (second run shows changed=0)
- Fixed routing: curl -k https://public.vm1.local:8443/vm2/
- Load balancing: repeated curl -k https://public.vm1.local:8443/app/
- Failover: see failover.log
