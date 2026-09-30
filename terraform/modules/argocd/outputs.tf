output "namespace" {
  value = var.namespace
}

output "release_name" {
  value = helm_release.argocd.name
}

output "application_name" {
  value = var.bootstrap_application ? "myapp-${var.environment}" : null
}

output "gitops_path" {
  value = local.gitops_path
}

output "access_hint" {
  value = <<-EOT
    # Port-forward Argo CD UI
    kubectl -n ${var.namespace} port-forward svc/argocd-server 8080:443
    # Initial admin password
    kubectl -n ${var.namespace} get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
  EOT
}
