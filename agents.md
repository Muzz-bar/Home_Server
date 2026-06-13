### A. Core Hardware Node

* **Processor** : Intel Core 3rd Gen (Ivy Bridge x86_64) @ **800** MHz – **1.2** GHz ( *idle* ).
* **Memory** : **4** GB Physical RAM (**3.71** GiB terdeteksi kernel).
* **Storage** : **452** GiB Root Partition (Solid State Drive) + **974** MiB EFI System Partition.
* **Power State** : AC Input direct passthrough, Battery capacity **0%** (Bypass mode).

### B. OS & Networking Layer

* **Sistem Operasi** : Debian 13 (Trixie) Netinst, Minimal Kernel murni tanpa Desktop Environment.
* **Local Network IP** : `192.168.1.24` via interface nirkabel internal (`wlp2s0`).
* **Overlay Network (VPN)** : Tailscale Network Mesh di segmen IP `100.73.65.32`.
* **Public Proxy Gateway** : Cloudflare Tunnel (`cloudflared`) memetakan HTTPS ke domain `[https://cloud.muzz.my.id](https://cloud.muzz.my.id)`.

  C. Docker Container Stack Orchestration

| **Service Name**   | **Container Image**              | **Port** | **Volume Mapping**                     |
| ------------------------ | -------------------------------------- | -------------- | -------------------------------------------- |
| **Portainer**      | `portainer/portainer-ce:latest`      | `9000:9000`  | `/var/run/docker.sock`                     |
| **Nextcloud App**  | `nextcloud:latest`                   | `8085:80`    | `./nextcloud_data:/var/www/html`           |
| **PostgreSQL**     | `postgres:latest`                    | `5432:5432`  | `./postgres_data:/var/lib/postgresql/data` |
| **Cockpit Daemon** | Bawaan Debian (Trusted Proxies Active) | `9090:9090`  | Sistem internal Host Engine                  |
