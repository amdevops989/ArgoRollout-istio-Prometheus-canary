resource "kubernetes_stateful_set" "kafka" {
  metadata {
    name      = "kafka"
    namespace = "kafka"
    labels = {
      app = "kafka-app"
    }
  }

  spec {
    service_name = "kafka"
    replicas     = 1

    selector {
      match_labels = {
        app = "kafka-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "kafka-app"
        }
      }

      spec {
        container {
          name  = "kafka-container"
          image = "doughgle/kafka-kraft"

          port {
            container_port = 9092
          }

          port {
            container_port = 9093
          }

          env {
            name  = "REPLICAS"
            value = "1"
          }
          env {
            name  = "SERVICE"
            value = "kafka"
          }
          env {
            name  = "NAMESPACE"
            value = "kafka"
          }
          env {
            name  = "SHARE_DIR"
            value = "/mnt/kafka"
          }
          env {
            name  = "CLUSTER_ID"
            value = "bXktY2x1c3Rlci0xMjM0NQ=="
          }
          env {
            name  = "DEFAULT_REPLICATION_FACTOR"
            value = "1"
          }
          env {
            name  = "DEFAULT_MIN_INSYNC_REPLICAS"
            value = "1"
          }
          env {
            name  = "KAFKA_ADVERTISED_LISTENERS"
            value = "PLAINTEXT://kafka.kafka.svc.cluster.local:9092"
          }
          env {
            name  = "KAFKA_LISTENERS"
            value = "PLAINTEXT://0.0.0.0:9092"
          }

          volume_mount {
            name       = "data"
            mount_path = "/mnt/kafka"
          }
        }
      }
    }

    volume_claim_template {
      metadata {
        name = "data"
      }

      spec {
        access_modes = ["ReadWriteOnce"]

        resources {
          requests = {
            storage = var.kafka_pvc_size
          }
        }

        storage_class_name = var.storage_class
      }
    }
  }
    depends_on = [kubernetes_stateful_set.postgres]
}


resource "kubernetes_service" "kafka" {
  metadata {
    name      = "kafka"
    namespace = "kafka"
    labels = {
      app = "kafka-app"
    }
  }

  spec {
    type = "NodePort"

    selector = {
      app = "kafka-app"
    }

    port {
      name        = "9092"
      port        = 9092
      target_port = 9092
      node_port   = 30092
      protocol    = "TCP"
    }
  }
  depends_on = [kubernetes_stateful_set.kafka]
}
