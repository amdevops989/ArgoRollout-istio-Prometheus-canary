resource "kubernetes_namespace" "pg" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_config_map" "postgres_init" {
  metadata {
    name      = "postgres-init-sql"
    namespace = kubernetes_namespace.pg.metadata[0].name
  }

  data = {
    # key must be the script filename Bitnami recognizes; using 'initdb.sql'
    "initdb.sql" = file("${path.module}/sql/init-db.sql")
  }

  depends_on = [kubernetes_namespace.pg]
}
