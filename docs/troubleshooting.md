# Troubleshooting

## Terraform

| Symptom | Likely cause | Fix |
|---------|--------------|-----|
| State lock | Concurrent apply | Wait or carefully remove lock after confirming no apply running |
| 403 on APIs | API not enabled / wrong SA | Re-run project-services; check WIF SA roles |
| PSA / SQL private IP fails | PSA not ready | Apply `private_service_access` before Cloud SQL; retry |
| Bucket name taken | Global GCS namespace | Change `state_bucket_name` |

## GKE / kubectl

| Symptom | Likely cause | Fix |
|---------|--------------|-----|
| `Unable to connect to the server` | Master authorized networks | Add your IP/CIDR to `gke_master_authorized_networks` |
| Pods Pending | No app nodes / taint | Check app pool autoscaling; don't schedule apps on system taint without toleration |
| ImagePullBackOff | AR IAM / wrong image | Verify `gke-nodes` reader; image SHA exists |

## Gateway / TLS

| Symptom | Likely cause | Fix |
|---------|--------------|-----|
| Cert PROVISIONING | DNS not delegated | Delegate NS; wait for DNS auth CNAME |
| 404 on `/` | HTTPRoute/hostname mismatch | Align hostname patches with `app_hostname` |
| 502 | Backend not ready | Check `/ready`, NetworkPolicy, Cloud SQL connectivity |

## Argo CD

| Symptom | Likely cause | Fix |
|---------|--------------|-----|
| Unknown sync | Repo private | Add repo credentials |
| Sync fail CRD | ESO/Gateway CRDs missing | Enable ESO module; ensure Gateway API channel on cluster |
| App OutOfSync loop | Manual cluster edits | Let Git win; disable manual kubectl changes |

## Database

| Symptom | Likely cause | Fix |
|---------|--------------|-----|
| `/ready` 503 | DB_HOST/password wrong | Check ExternalSecret; private IP; SSL mode |
| Connection timeout | NetworkPolicy / PSA | Allow 10/8:5432 egress; confirm SQL private IP |

## CI

| Symptom | Likely cause | Fix |
|---------|--------------|-----|
| WIF auth failed | Wrong provider/repo condition | Match bootstrap `github_*_repo` and `WIF_PROVIDER` |
| Trivy fails job | High/Crit vulns | Patch base image or set temporary ignore with ticket |
