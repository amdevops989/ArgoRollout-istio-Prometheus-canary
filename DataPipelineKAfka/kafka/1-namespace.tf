resource "kubernetes_namespace" "kafka" {
  metadata {
    name = var.namespace
  }
}
