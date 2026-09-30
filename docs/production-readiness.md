# Production Readiness Checklist

```text
[ ] Terraform state secured (versioned GCS, restricted IAM)
[ ] GCP APIs enabled
[ ] VPC created
[ ] PSA configured
[ ] Cloud NAT configured
[ ] Firewall configured (no 0.0.0.0/0 allow-all)
[ ] Private GKE cluster
[ ] Workload Identity enabled
[ ] Artifact Registry created
[ ] Cloud SQL private IP
[ ] Cloud SQL HA (stage/prod)
[ ] Backup/PITR enabled
[ ] Secret Manager configured
[ ] GitHub OIDC / WIF configured
[ ] GitHub Actions CI
[ ] Container scanning (Trivy)
[ ] Terraform scanning (Checkov)
[ ] GitOps repository / paths
[ ] Argo CD installed
[ ] Kustomize overlays per env
[ ] Gateway API configured
[ ] HTTPS / Certificate Manager configured
[ ] DNS delegated
[ ] Monitoring alerts configured
[ ] Logging enabled on GKE
[ ] External Secrets (no secrets in Git)
[ ] NetworkPolicies applied
[ ] Pod Security labels set
[ ] Prod GitHub Environment approvals
[ ] DR documented
[ ] Rollback documented
[ ] End-to-end smoke test completed
```
