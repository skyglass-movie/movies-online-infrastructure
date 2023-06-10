resource "kubernetes_deployment_v1" "movies_api_deployment" {
  depends_on = [kubernetes_deployment_v1.movies_mongodb_deployment]
  metadata {
    name = "movies-api"
    labels = {
      app = "movies-api"
    }
  }
 
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "movies-api"
      }
    }
    template {
      metadata {
        labels = {
          app = "movies-api"
        }
      }
      spec {
        container {
          image = "ghcr.io/skyglass-movie/movies-online-api:eab411e130afb84dc3c2fc55b9e092da3e2a900e"
          name  = "movies-api"
          image_pull_policy = "Always"
          port {
            container_port = 8081
          }
          env {
            name = "SPRING_DATA_MONGODB_URI"
            value = "mongodb://movies-mongodb:27017/moviesdb"
          }  
          env {
            name = "SPRING_KEYCLOAK_SERVER_URL"
            value = "https://keycloak.greeta.net"
          }   
           env {
            name = "MOVIES_APP_BASE_URL"
            value = "https://movies.greeta.net"
          }                                                                                                                                      
        }
      }
    }
  }
}

resource "kubernetes_horizontal_pod_autoscaler_v1" "movies_api_hpa" {
  metadata {
    name = "movies-api-hpa"
  }
  spec {
    max_replicas = 2
    min_replicas = 1
    scale_target_ref {
      api_version = "apps/v1"
      kind = "Deployment"
      name = kubernetes_deployment_v1.movies_api_deployment.metadata[0].name 
    }
    target_cpu_utilization_percentage = 50
  }
}

resource "kubernetes_service_v1" "movies_api_service" {
  metadata {
    name = "movies-api"
  }
  spec {
    selector = {
      app = "movies-api"
    }
    port {
      port = 8081
    }
  }
}
