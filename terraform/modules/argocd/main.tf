locals {
  gitops_path = coalesce(var.gitops_path, "gitops/environments/${var.environment}")
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.chart_version
  namespace        = var.namespace
  create_namespace = true
  atomic           = true
  wait             = true
  timeout          = 600

  lifecycle {
    precondition {
      condition     = length(var.git_repo_url) > 0
      error_message = "argocd_git_repo_url must be set when enable_argocd=true."
    }
  }

  values = [
    yamlencode({
      global = {
        domain = "argocd.${var.environment}.local"
      }
      configs = {
        params = {
          "server.insecure" = var.server_insecure
        }
      }
      server = {
        replicas = 1
        service = {
          type = "ClusterIP"
        }
        tolerations = [
          {
            key      = "CriticalAddonsOnly"
            operator = "Exists"
            effect   = "NoSchedule"
          }
        ]
        nodeSelector = {
          role = "system"
        }
      }
      controller = {
        tolerations = [
          {
            key      = "CriticalAddonsOnly"
            operator = "Exists"
            effect   = "NoSchedule"
          }
        ]
        nodeSelector = {
          role = "system"
        }
      }
      repoServer = {
        tolerations = [
          {
            key      = "CriticalAddonsOnly"
            operator = "Exists"
            effect   = "NoSchedule"
          }
        ]
        nodeSelector = {
          role = "system"
        }
      }
      applicationSet = {
        tolerations = [
          {
            key      = "CriticalAddonsOnly"
            operator = "Exists"
            effect   = "NoSchedule"
          }
        ]
        nodeSelector = {
          role = "system"
        }
      }
      redis = {
        tolerations = [
          {
            key      = "CriticalAddonsOnly"
            operator = "Exists"
            effect   = "NoSchedule"
          }
        ]
        nodeSelector = {
          role = "system"
        }
      }
    })
  ]
}

resource "kubernetes_manifest" "appproject" {
  count = var.bootstrap_application ? 1 : 0

  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "AppProject"
    metadata = {
      name      = "myapp"
      namespace = var.namespace
      labels = {
        "app.kubernetes.io/part-of" = "myapp"
      }
    }
    spec = {
      description = "myapp ${var.environment} project"
      sourceRepos = [
        var.git_repo_url,
        "*"
      ]
      destinations = [
        {
          namespace = "*"
          server    = "https://kubernetes.default.svc"
        }
      ]
      clusterResourceWhitelist = [
        {
          group = "*"
          kind  = "*"
        }
      ]
      namespaceResourceWhitelist = [
        {
          group = "*"
          kind  = "*"
        }
      ]
    }
  }

  depends_on = [helm_release.argocd]
}

resource "kubernetes_manifest" "application" {
  count = var.bootstrap_application ? 1 : 0

  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "myapp-${var.environment}"
      namespace = var.namespace
      labels = {
        "app.kubernetes.io/part-of" = "myapp"
        environment                 = var.environment
      }
      finalizers = [
        "resources-finalizer.argocd.argoproj.io"
      ]
    }
    spec = {
      project = "myapp"
      source = {
        repoURL        = var.git_repo_url
        targetRevision = var.git_target_revision
        path           = local.gitops_path
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "default"
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = [
          "CreateNamespace=true",
          "PruneLast=true",
          "ServerSideApply=true"
        ]
        retry = {
          limit = 5
          backoff = {
            duration    = "5s"
            factor      = 2
            maxDuration = "3m"
          }
        }
      }
    }
  }

  depends_on = [
    helm_release.argocd,
    kubernetes_manifest.appproject,
  ]
}
