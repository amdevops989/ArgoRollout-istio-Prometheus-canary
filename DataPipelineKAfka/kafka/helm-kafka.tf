# resource "helm_release" "kafka" {
#   name       = "kafka"
#   repository = "https://charts.bitnami.com/bitnami"
#   chart      = "kafka"
#   namespace  = kubernetes_namespace.kafka.metadata[0].name
#   version    = "32.4.0"

#   values = [
#     yamlencode({
#       image = {
#         registry   = "docker.io"
#         repository = "bitnami/kafka"
#         tag        = "4.0.0-debian-12-r5"
#         pullPolicy = "IfNotPresent"
#       }

#       zookeeper = {
#         enabled = false
#       }

#       kraft = {
#         enabled    = true
#         nodeId     = 1
#         controller = true
#         broker     = true
#         # Bitnami expects listener configs as a map
#         listeners = {
#           plaintext  = "PLAINTEXT://:9092"
#         }
#       }

#       service = {
#         type  = "ClusterIP"
#         ports = {
#           kafka = 9092
#         }
#       }

#       persistence = {
#         enabled      = true
#         size         = var.kafka_pvc_size
#         storageClass = var.storage_class
#       }

#       resources = {
#         limits = {
#           cpu    = "1000m"
#           memory = "1024Mi"
#         }
#         requests = {
#           cpu    = "500m"
#           memory = "512Mi"
#         }
#       }
#     })
#   ]
#   depends_on = [kubernetes_namespace.kafka]
# }
