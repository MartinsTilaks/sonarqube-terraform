provider "kubernetes" {
  config_context_cluster   = "minikube"
  config_path = "~/.kube/config"
}
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}
resource "helm_release" "postgresdb" {
  name       = "postgresql"
  namespace  = "default"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  set {
    name  = "auth.database"
    value = var.sonarqube_database
  }
     set {
    name  = "auth.username"
    value = var.postgresql_user
  }

  set {
    name  = "auth.password"
    value = var.postgresql_password
  }

  set {
    name  = "persistence.enabled"
    value = "true"
  }
  set {
    name = "containerPorts.postgresql"
    value = var.db_port
  }
}

resource "helm_release" "sonarqubeapp" {
  name       = "sonarqube"
  namespace  = "default"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "sonarqube"
  depends_on = [
    helm_release.postgresdb
  ]
  

  set {
    name = "sonarqubeUsername"
    value = var.sonarqube_user
  }

  set {
    name = "sonarqubePassword"
    value = var.sonarqube_password
  }
  set {
    name  = "database.type"
    value = "postgresql"
    }
  set {
    name  = "externalDatabase.database"
    value = var.sonarqube_database
    } 

  set {
    name  = "externalDatabase.host"
    value = helm_release.postgresdb.id
    }

  set {
    name  = "externalDatabase.password"
    value = var.postgresql_password
    }

      set {
    name  = "externalDatabase.user"
    value = var.postgresql_user
    }
  set {
    name  = "livenessProbe.sonarWebContext"
    value = "/sonarqube/"
    } 

  set {
    name  = "persistence.enabled"
    value = "true"
    }

  set {
    name  = "postgresql.enabled"
    value = "false"
    }

  set {
    name  = "readinessProbe.sonarWebContext"
    value = "/sonarqube/"
    }
  set {
    name = "externalDatabase.port"
    value = var.db_port
  }

  set {
    name  = "startupProbe.initialDelaySeconds"
    value = 120
    }

  set {
    name  = "startupProbe.periodSeconds"
    value = 30
    }
  set {
    name  = "startupProbe.timeoutSeconds"
    value = 30
    }
}



