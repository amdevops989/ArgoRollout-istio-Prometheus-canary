resource "helm_release" "postgres" {
  name       = "postgres"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  namespace  = kubernetes_namespace.pg.metadata[0].name
  version    = "18.1.13"  # ✅ Latest stable chart # optional pin — adjust or remove to use latest

  # Use a small inline values file rendered from variables
  values = [
    yamlencode({

    #   global = {
    #   imageRegistry   = "docker.io"
    #   imagePullSecrets = []
    #   }

      primary = {
        image = {
          registry   = "docker.io"
          repository = "bitnami/postgresql"
          tag        = "latest"         # ✅ explicitly set
          digest     = ""               # ✅ explicitly set
          pullPolicy = "IfNotPresent"  # ✅ explicitly set
        }
      }
    
        
      auth = {
        postgresPassword = var.postgres_password
        username         = var.appuser_username
        password         = var.appuser_password
        database         = var.database_name
      }

      primary = {
        service = {
          type = "ClusterIP"
          ports = {
            postgresql = 5432
          }
        }

        persistence = {
          enabled      = true
          size         = var.pvc_size
          storageClass = var.storage_class
        }

        extendedConfiguration = <<-EOT
          wal_level = logical
          max_replication_slots = 10
          max_wal_senders = 10
          max_wal_size = 1GB
        EOT

        # instruct Bitnami chart to read init scripts from the ConfigMap
        initdbScriptsConfigMap = "postgres-init-sql"

        extraEnvVars = [
          {
            name  = "POSTGRESQL_REPLICATION_MODE"
            value = "master"
          },
          {
            name  = "POSTGRESQL_REPLICATION_USER"
            value = var.dbz_replication_user
          },
          {
            name  = "POSTGRESQL_REPLICATION_PASSWORD"
            value = var.dbz_replication_password
          }
        ]

        pgHbaConfiguration = <<-EOT
          host all all 0.0.0.0/0 md5
        EOT
      }

      # Optionally tune resources (small for Minikube)
      resources = {
        limits = {
          cpu    = "500m"
          memory = "512Mi"
        }
        requests = {
          cpu    = "250m"
          memory = "256Mi"
        }
      }
    })
  ]

  # ensure ConfigMap exists before installing
  depends_on = [kubernetes_config_map.postgres_init]
}
