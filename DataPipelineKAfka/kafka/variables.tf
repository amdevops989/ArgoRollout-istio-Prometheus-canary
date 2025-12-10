# ----------------------------
# Variables
# ----------------------------

variable "namespace" {
  description = "Namespace to install Kafka/Postgres into"
  type        = string
  default     = "kafka"
}

variable "kubeconfig_path" {
  description = "Path to kubeconfig (leave empty to use default behavior)"
  type        = string
  default     = ""
}

variable "storage_class" {
  description = "Storage class for PVCs"
  type        = string
  default     = "standard"
}

variable "pvc_size" {
  description = "PVC size for PostgreSQL"
  type        = string
  default     = "5Gi"
}

variable "postgres_password" {
  description = "Postgres superuser password"
  type        = string
  default     = "postgres"
  sensitive   = true
}

variable "appuser_username" {
  description = "Application DB username"
  type        = string
  default     = "appuser"
}

variable "appuser_password" {
  description = "Application DB password"
  type        = string
  default     = "appuser"
  sensitive   = true
}

variable "dbz_replication_user" {
  description = "Debezium replication username"
  type        = string
  default     = "dbz"
}

variable "dbz_replication_password" {
  description = "Debezium replication password"
  type        = string
  default     = "dbz"
  sensitive   = true
}

variable "database_name" {
  description = "Database to create"
  type        = string
  default     = "mv100db"
}

variable "postgres_secret_name" {
  description = "Name of Kubernetes Secret holding Postgres credentials"
  type        = string
  default     = "postgres-creds"
}

variable "postgres_image_tag" {
  description = "PostgreSQL Docker image tag"
  type        = string
  default     = "15.4.0"
}

variable "kafka_pvc_size" {
  description = "PVC size for Kafka"
  type        = string
  default     = "5Gi"
}
