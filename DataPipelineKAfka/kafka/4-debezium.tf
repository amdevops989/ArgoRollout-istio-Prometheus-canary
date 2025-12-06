# --------------------------------------------------
# Debezium Connector ConfigMap
# --------------------------------------------------
resource "kubernetes_config_map" "pg_connector_config" {
  metadata {
    name      = "pg-auth-catalog-orders"
    namespace = "kafka"
  }

  data = {
    "connector.json" = jsonencode({
      name   = "pg-auth-catalog-orders"
      config = {
        "connector.class"                        = "io.debezium.connector.postgresql.PostgresConnector"
        "database.hostname"                       = "postgres-postgresql.kafka.svc.cluster.local"
        "database.port"                           = "5432"
        "database.user"                           = "dbz"
        "database.password"                       = "dbz"
        "database.dbname"                         = "mv100db"
        "topic.prefix"                            = "mv100db"
        "plugin.name"                             = "pgoutput"
        "slot.name"                               = "dbz_slot"
        "publication.name"                        = "dbz_pub"
        "table.include.list"                       = "public.users,public.orders,public.payments,public.emails,public.products"
        "snapshot.mode"                           = "always"
        "slot.drop.on.stop"                        = "false"
        "max.batch.size"                           = "2048"
        "max.queue.size"                           = "8192"
        "key.converter"                            = "org.apache.kafka.connect.json.JsonConverter"
        "value.converter"                          = "org.apache.kafka.connect.json.JsonConverter"
        "key.converter.schemas.enable"             = "false"
        "value.converter.schemas.enable"           = "false"
        "decimal.handling.mode"                    = "string"
        "tombstones.on.delete"                     = "true"
        "heartbeat.interval.ms"                    = "10000"
        "database.history.kafka.bootstrap.servers" = "kafka.kafka.svc.cluster.local:9092"
        "database.history.kafka.topic"             = "schema-changes.mv100db"
      }
    })
  }
}

# --------------------------------------------------
# Debezium Connect Deployment
# --------------------------------------------------
resource "kubernetes_deployment" "debezium_connect" {
  metadata {
    name      = "debezium-connect"
    namespace = "kafka"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "debezium-connect"
      }
    }

    template {
      metadata {
        labels = {
          app = "debezium-connect"
        }
      }

      spec {
        container {
          name  = "connect"
          image = "debezium/connect:2.6"

          port {
            container_port = 8083
          }

          volume_mount {
            name       = "connector-config"
            mount_path = "/connectors"
            read_only  = true
          }

          env {
            name  = "BOOTSTRAP_SERVERS"
            value = "kafka.kafka.svc.cluster.local:9092"
          }

          env {
            name  = "GROUP_ID"
            value = "debezium"
          }

          env {
            name  = "CONFIG_STORAGE_TOPIC"
            value = "connect-configs"
          }

          env {
            name  = "OFFSET_STORAGE_TOPIC"
            value = "connect-offsets"
          }

          env {
            name  = "STATUS_STORAGE_TOPIC"
            value = "connect-status"
          }
        }

        volume {
          name = "connector-config"

          config_map {
            name = kubernetes_config_map.pg_connector_config.metadata[0].name
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_stateful_set.kafka,
    kubernetes_service.kafka,
    kubernetes_stateful_set.postgres,
    kubernetes_service.postgres,
    kubernetes_config_map.pg_connector_config
  ]
}

# --------------------------------------------------
# Debezium Connect Service
# --------------------------------------------------
resource "kubernetes_service" "debezium_connect" {
  metadata {
    name      = "debezium-connect"
    namespace = "kafka"
  }

  spec {
    type = "NodePort"

    selector = {
      app = "debezium-connect"
    }

    port {
      port        = 8083
      target_port = 8083
      node_port   = 30083
      protocol    = "TCP"
    }
  }

  depends_on = [
    kubernetes_stateful_set.kafka,
    kubernetes_service.kafka
  ]
}
