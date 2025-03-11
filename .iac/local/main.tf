provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "random_string" "secret_key_base" {
  length           = 12
  special          = true
  override_special = "#@!"
}

resource "helm_release" "lovevery-hello" {
  name       = "lovevery-app"
  namespace  = "lovevery"
  repository = "oci://docker.io/atilarmao"
  version    = "0.0.1"
  chart      = "lovevery"
  create_namespace = true

  set {
    name  = "env[0].name"
    value = "SECRET_KEY_BASE"
  }
  set {
    name  = "env[0].value"
    value = random_string.secret_key_base.result
  }
}