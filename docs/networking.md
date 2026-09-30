# Networking Design

## 1. Topology

```text
VPC: myapp-{env}-vpc  (custom mode)
 │
 ├── Subnet: myapp-{env}-gke          Primary nodes CIDR
 │     ├── Secondary: gke-pods        Pod alias IPs
 │     └── Secondary: gke-services    Service ClusterIPs
 │
 ├── Subnet: myapp-{env}-mgmt         Bastion / break-glass (optional, private)
 │
 ├── Cloud Router + Cloud NAT         Egress for private GKE nodes
 │
 └── Private Service Access (PSA)
       └── Allocated range → Cloud SQL private IP
```

GKE nodes have **no public IPs**. Outbound internet (image pulls beyond Artifact Registry via Private Google Access, OS updates, external APIs) goes through **Cloud NAT**.

Private Google Access is enabled on all subnets so Google APIs are reachable without public IPs.

---

## 2. CIDR Plan (non-overlapping)

Each environment uses a dedicated `/16` from RFC 1918 `10.0.0.0/8` so VPCs can later be peered or connected via Shared VPC / HA VPN without collision.

| Environment | VPC supernet | Purpose |
|-------------|--------------|---------|
| shared (bootstrap only; no app VPC required) | N/A | State / WIF live in project, not a full app VPC |
| dev | `10.10.0.0/16` | Development |
| stage | `10.20.0.0/16` | Staging |
| prod | `10.30.0.0/16` | Production |

### Per-environment allocation (example: prod `10.30.0.0/16`)

| Range | CIDR | Size | Use |
|-------|------|------|-----|
| GKE nodes (primary) | `10.30.0.0/20` | 4,096 | Node VMs |
| GKE pods (secondary) | `10.30.16.0/18` | 16,384 | Pod IPs (VPC-native) |
| GKE services (secondary) | `10.30.80.0/20` | 4,096 | ClusterIP services |
| Management | `10.30.96.0/24` | 256 | Optional private bastion / ops |
| PSA / Cloud SQL | `10.30.100.0/24` | 256 | Allocated for Service Networking |
| Reserved | `10.30.101.0`–`10.30.255.255` | — | Future (proxy-only, PSC, etc.) |

### Dev (`10.10.0.0/16`) and Stage (`10.20.0.0/16`)

Same relative offsets:

| Purpose | Dev | Stage | Prod |
|---------|-----|-------|------|
| Nodes | `10.10.0.0/20` | `10.20.0.0/20` | `10.30.0.0/20` |
| Pods | `10.10.16.0/18` | `10.20.16.0/18` | `10.30.16.0/18` |
| Services | `10.10.80.0/20` | `10.20.80.0/20` | `10.30.80.0/20` |
| Mgmt | `10.10.96.0/24` | `10.20.96.0/24` | `10.30.96.0/24` |
| PSA | `10.10.100.0/24` | `10.20.100.0/24` | `10.30.100.0/24` |

**Master authorized networks / control plane:** GKE private cluster uses a Google-managed control plane endpoint. The control-plane CIDR (Google-assigned `/28`) is separate and must not overlap VPC ranges — Terraform will set `master_ipv4_cidr_block` to:

| Env | Control plane CIDR |
|-----|--------------------|
| dev | `172.16.0.0/28` |
| stage | `172.16.0.16/28` |
| prod | `172.16.0.32/28` |

These are outside the VPC `10.x` space and do not overlap each other.

### Capacity notes

- Pod `/18` supports large node counts with default max-pods-per-node (110) for a regional cluster of this size.
- Service `/20` is ample for ClusterIP/LoadBalancer Service objects.
- PSA `/24` is sufficient for Cloud SQL (+ room for future private services).

See [phase-1/cidr-plan.md](./phase-1/cidr-plan.md) for the authoritative table used by Terraform variables.

---

## 3. Cloud NAT / Router

- One Cloud Router per region per VPC.
- Cloud NAT: auto IP allocation initially; production may pin static NAT IPs later for egress allowlisting.
- Logging: errors + translations sampled (cost-aware).

---

## 4. Private Service Access (PSA)

```text
GKE Pod (backend)
   → Pod IP in VPC
   → VPC routing
   → Private Service Access connection (servicenetworking.googleapis.com)
   → Cloud SQL private IP in allocated PSA range
```

Cloud SQL has **no public IP**. This eliminates internet exposure of the database and forces traffic to stay on Google's private network path via PSA.

---

## 5. Firewall Strategy (least privilege)

Rules will be Terraform-managed. Categories:

| Rule intent | Direction | Source | Dest | Ports |
|-------------|-----------|--------|------|-------|
| GKE nodes ↔ control plane | Ingress | Master CIDR | Nodes | TCP 443,10250 + UDP 51820 (Dataplane V2) |
| Health checks (GCP LB) | Ingress | `35.191.0.0/16`, `130.211.0.0/22` | Nodes / NEGs | Health-check ports |
| Internal frontend → backend | Ingress | Frontend pod range | Backend pods | App port (8080) |
| Backend → Cloud SQL | (implicit via VPC/PSA; no 0.0.0.0/0) | Backend pods | PSA range | TCP 5432 |
| Deny high-risk defaults | Prefer deny-by-default VPC; only allow listed rules | — | — | — |

**Explicitly not created:** `0.0.0.0/0` allow-all.

Full rule names and priorities ship in Phase 3 (`modules/firewall`). Implementation notes: [phase-3/networking-impl.md](./phase-3/networking-impl.md).

---

## 6. DNS and TLS (preview)

| Item | Decision |
|------|----------|
| Public DNS | Cloud DNS public zone: `myapp.example.com` (user supplies real domain in tfvars) |
| Hostnames | `dev.myapp.example.com`, `stage.myapp.example.com`, `myapp.example.com` (prod) |
| TLS | Google-managed certificates via Certificate Manager / Gateway cert binding |
| HTTP | Redirect to HTTPS at Gateway / LB |

Exact GatewayClass (`gke-l7-global-external-managed` vs regional) is chosen in Phase 8; default: **global external managed** for multi-zone frontend HA.
