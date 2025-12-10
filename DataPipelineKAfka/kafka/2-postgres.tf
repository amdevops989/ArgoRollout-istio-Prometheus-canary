# ----------------------------
# ConfigMap for init SQL
# ----------------------------
resource "kubernetes_config_map" "postgres_init" {
  metadata {
    name      = "postgres-init-sql"
    namespace = kubernetes_namespace.kafka.metadata[0].name
  }

  data = {
    "init-db.sql" = file("${path.module}/sql/init-db.sql")
  }

  depends_on = [kubernetes_namespace.kafka]
}

# ----------------------------
# Secret for Postgres password
# ----------------------------
resource "kubernetes_secret" "postgres_creds" {
  metadata {
    name      = "postgres-creds"
    namespace = kubernetes_namespace.kafka.metadata[0].name
  }

  data = {
    "postgres-password" = var.postgres_password
  }

  type = "Opaque"
}

# ----------------------------
# StatefulSet for Postgres
# ----------------------------
resource "kubernetes_stateful_set" "postgres" {
  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace.kafka.metadata[0].name
    labels = {
      app = "postgres"
    }
  }

  spec {
    service_name = "postgres"
    replicas     = 1

    selector {
      match_labels = {
        app = "postgres"
      }
    }

    template {
      metadata {
        labels = {
          app = "postgres"
        }
      }

      spec {
        container {
          name  = "postgres"
          image = "postgres:16.11-alpine3.23"

          port {
            container_port = 5432
          }

          env {
            name  = "POSTGRES_USER"
            value = "postgres"
          }

          env {
            name = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgres_creds.metadata[0].name
                key  = "postgres-password"
              }
            }
          }

          env {
            name  = "POSTGRES_DB"
            value = var.database_name
          }

          env {
            name  = "PGDATA"
            value = "/var/lib/postgresql/data/pgdata"
          }

          # Ensure logical replication is enabled
          command = [
            "sh", "-c",
            <<EOT
            # If first start, append replication config
            if [ ! -f /var/lib/postgresql/data/pgdata/PG_VERSION ]; then
              echo "wal_level=logical" >> /var/lib/postgresql/data/postgresql.conf
              echo "max_replication_slots=10" >> /var/lib/postgresql/data/postgresql.conf
              echo "max_wal_senders=10" >> /var/lib/postgresql/data/postgresql.conf
              echo "max_wal_size=1GB" >> /var/lib/postgresql/data/postgresql.conf
            fi

            # Start Postgres
            docker-entrypoint.sh postgres
            EOT
          ]

          # Volume mounts
          volume_mount {
            name       = "data"
            mount_path = "/var/lib/postgresql/data"
          }

          volume_mount {
            name       = "init-sql"
            mount_path = "/docker-entrypoint-initdb.d"
          }

          resources {
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "256Mi"
            }
          }

          # Liveness probe
          liveness_probe {
            exec {
              command = ["pg_isready", "-U", "postgres"]
            }
            initial_delay_seconds = 5
            period_seconds        = 5
            failure_threshold     = 10
          }
        }

        # Mount ConfigMap as volume
        volume {
          name = "init-sql"
          config_map {
            name = kubernetes_config_map.postgres_init.metadata[0].name
          }
        }
      }
    }

    # PVC template
    volume_claim_template {
      metadata {
        name = "data"
      }

      spec {
        access_modes = ["ReadWriteOnce"]

        resources {
          requests = {
            storage = var.pvc_size
          }
        }

        storage_class_name = var.storage_class
      }
    }
  }

  depends_on = [kubernetes_config_map.postgres_init, kubernetes_secret.postgres_creds]
}

# ----------------------------
# Postgres Service
# ----------------------------
resource "kubernetes_service" "postgres" {
  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace.kafka.metadata[0].name
    labels = {
      app = "postgres"
    }
  }

  spec {
    type = "ClusterIP"

    selector = {
      app = "postgres"
    }

    port {
      port        = 5432
      target_port = 5432
      protocol    = "TCP"
    }
  }

  depends_on = [kubernetes_stateful_set.postgres]
}
