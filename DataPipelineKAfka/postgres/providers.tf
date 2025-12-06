terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.10"
    }
  }
}

provider "kubernetes" {
  config_path = pathexpand("~/.kube/config") # minikube's kubeconfig
}

provider "helm" {
  kubernetes {
    config_path = pathexpand("~/.kube/config")
  }
}

