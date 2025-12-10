
#############################
# Kafka-UI Helm Release
#############################
resource "helm_release" "kafka_ui" {
  name       = "kafka-ui"
  namespace  = kubernetes_namespace.kafka.metadata[0].name
  repository = "https://provectus.github.io/kafka-ui-charts"
  chart      = "kafka-ui"

  values = [
    yamlencode({
      yamlApplicationConfig = {
        kafka = {
          clusters = [
            {
              name             = "local"
              bootstrapServers = "kafka.kafka.svc.cluster.local:9092"
            }
          ]
        }
        auth = {
          type = "disabled"
        }
      }

      service = {
        type     = "NodePort"
        port     = 8080
        nodePort = 30090
      }
    })
  ]

  depends_on = [kubernetes_stateful_set.kafka]
}
