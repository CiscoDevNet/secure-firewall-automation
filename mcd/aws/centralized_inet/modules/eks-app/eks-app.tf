resource "kubernetes_manifest" "namespace_sock_shop" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Namespace"
    "metadata" = {
      "name" = "sock-shop"
    }
  }
}

resource "kubernetes_manifest" "deployment_sock_shop_carts" {
  depends_on = [kubernetes_manifest.namespace_sock_shop]
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "Deployment"
    "metadata" = {
      "labels" = {
        "name" = "carts"
      }
      "name" = "carts"
      "namespace" = "sock-shop"
    }
    "spec" = {
      "replicas" = 1
      "selector" = {
        "matchLabels" = {
          "name" = "carts"
        }
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "name" = "carts"
          }
        }
        "spec" = {
          "containers" = [
            {
              "env" = [
                {
                  "name" = "JAVA_OPTS"
                  "value" = "-Xms64m -Xmx128m -XX:+UseG1GC -Djava.security.egd=file:/dev/urandom -Dspring.zipkin.enabled=false"
                },
              ]
              "image" = "weaveworksdemos/carts:0.4.8"
              "name" = "carts"
              "ports" = [
                {
                  "containerPort" = 80
                },
              ]
              "resources" = {
                "limits" = {
                  "cpu" = "300m"
                  "memory" = "500Mi"
                }
                "requests" = {
                  "cpu" = "100m"
                  "memory" = "200Mi"
                }
              }
              "securityContext" = {
                "capabilities" = {
                  "add" = [
                    "NET_BIND_SERVICE",
                  ]
                  "drop" = [
                    "all",
                  ]
                }
                "readOnlyRootFilesystem" = true
                "runAsNonRoot" = true
                "runAsUser" = 10001
              }
              "volumeMounts" = [
                {
                  "mountPath" = "/tmp"
                  "name" = "tmp-volume"
                },
              ]
            },
          ]
          "nodeSelector" = {
            "beta.kubernetes.io/os" = "linux"
          }
          "volumes" = [
            {
              "emptyDir" = {
                "medium" = "Memory"
              }
              "name" = "tmp-volume"
            },
          ]
        }
      }
    }
  }
}

resource "kubernetes_manifest" "service_sock_shop_carts" {
  depends_on = [kubernetes_manifest.namespace_sock_shop]
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Service"
    "metadata" = {
      "annotations" = {
        "prometheus.io/scrape" = "true"
      }
      "labels" = {
        "name" = "carts"
      }
      "name" = "carts"
      "namespace" = "sock-shop"
    }
    "spec" = {
      "ports" = [
        {
          "port" = 80
          "targetPort" = 80
        },
      ]
      "selector" = {
        "name" = "carts"
      }
    }
  }
}

resource "kubernetes_manifest" "deployment_sock_shop_carts_db" {
  depends_on = [kubernetes_manifest.namespace_sock_shop]
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "Deployment"
    "metadata" = {
      "labels" = {
        "name" = "carts-db"
      }
      "name" = "carts-db"
      "namespace" = "sock-shop"
    }
    "spec" = {
      "replicas" = 1
      "selector" = {
        "matchLabels" = {
          "name" = "carts-db"
        }
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "name" = "carts-db"
          }
        }
        "spec" = {
          "containers" = [
            {
              "image" = "mongo"
              "name" = "carts-db"
              "ports" = [
                {
                  "containerPort" = 27017
                  "name" = "mongo"
                },
              ]
              "securityContext" = {
                "capabilities" = {
                  "add" = [
                    "CHOWN",
                    "SETGID",
                    "SETUID",
                  ]
                  "drop" = [
                    "all",
                  ]
                }
                "readOnlyRootFilesystem" = true
              }
              "volumeMounts" = [
                {
                  "mountPath" = "/tmp"
                  "name" = "tmp-volume"
                },
              ]
            },
          ]
          "nodeSelector" = {
            "beta.kubernetes.io/os" = "linux"
          }
          "volumes" = [
            {
              "emptyDir" = {
                "medium" = "Memory"
              }
              "name" = "tmp-volume"
            },
          ]
        }
      }
    }
  }
}

resource "kubernetes_manifest" "service_sock_shop_carts_db" {
  depends_on = [kubernetes_manifest.namespace_sock_shop]
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Service"
    "metadata" = {
      "labels" = {
        "name" = "carts-db"
      }
      "name" = "carts-db"
      "namespace" = "sock-shop"
    }
    "spec" = {
      "ports" = [
        {
          "port" = 27017
          "targetPort" = 27017
        },
      ]
      "selector" = {
        "name" = "carts-db"
      }
    }
  }
}

resource "kubernetes_manifest" "deployment_sock_shop_catalogue" {
  depends_on = [kubernetes_manifest.namespace_sock_shop]
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "Deployment"
    "metadata" = {
      "labels" = {
        "name" = "catalogue"
      }
      "name" = "catalogue"
      "namespace" = "sock-shop"
    }
    "spec" = {
      "replicas" = 1
      "selector" = {
        "matchLabels" = {
          "name" = "catalogue"
        }
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "name" = "catalogue"
          }
        }
        "spec" = {
          "containers" = [
            {
              "args" = [
                "-port=80",
              ]
              "command" = [
                "/app",
              ]
              "image" = "weaveworksdemos/catalogue:0.3.5"
              "livenessProbe" = {
                "httpGet" = {
                  "path" = "/health"
                  "port" = 80
                }
                "initialDelaySeconds" = 300
                "periodSeconds" = 3
              }
              "name" = "catalogue"
              "ports" = [
                {
                  "containerPort" = 80
                },
              ]
              "readinessProbe" = {
                "httpGet" = {
                  "path" = "/health"
                  "port" = 80
                }
                "initialDelaySeconds" = 180
                "periodSeconds" = 3
              }
              "resources" = {
                "limits" = {
                  "cpu" = "200m"
                  "memory" = "200Mi"
                }
                "requests" = {
                  "cpu" = "100m"
                  "memory" = "100Mi"
                }
              }
              "securityContext" = {
                "capabilities" = {
                  "add" = [
                    "NET_BIND_SERVICE",
                  ]
                  "drop" = [
                    "all",
                  ]
                }
                "readOnlyRootFilesystem" = true
                "runAsNonRoot" = true
                "runAsUser" = 10001
              }
            },
          ]
          "nodeSelector" = {
            "beta.kubernetes.io/os" = "linux"
          }
        }
      }
    }
  }
}

resource "kubernetes_manifest" "service_sock_shop_catalogue" {
  depends_on = [kubernetes_manifest.namespace_sock_shop]
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Service"
    "metadata" = {
      "annotations" = {
        "prometheus.io/scrape" = "true"
      }
      "labels" = {
        "name" = "catalogue"
      }
      "name" = "catalogue"
      "namespace" = "sock-shop"
    }
    "spec" = {
      "ports" = [
        {
          "port" = 80
          "targetPort" = 80
        },
      ]
      "selector" = {
        "name" = "catalogue"
      }
    }
  }
}

resource "kubernetes_manifest" "deployment_sock_shop_catalogue_db" {
  depends_on = [kubernetes_manifest.namespace_sock_shop]
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "Deployment"
    "metadata" = {
      "labels" = {
        "name" = "catalogue-db"
      }
      "name" = "catalogue-db"
      "namespace" = "sock-shop"
    }
    "spec" = {
      "replicas" = 1
      "selector" = {
        "matchLabels" = {
          "name" = "catalogue-db"
        }
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "name" = "catalogue-db"
          }
        }
        "spec" = {
          "containers" = [
            {
              "env" = [
                {
                  "name" = "MYSQL_ROOT_PASSWORD"
                  "value" = "fake_password"
                },
                {
                  "name" = "MYSQL_DATABASE"
                  "value" = "socksdb"
                },
              ]
              "image" = "weaveworksdemos/catalogue-db:0.3.0"
              "name" = "catalogue-db"
              "ports" = [
                {
                  "containerPort" = 3306
                  "name" = "mysql"
                },
              ]
            },
          ]
          "nodeSelector" = {
            "beta.kubernetes.io/os" = "linux"
          }
        }
      }
    }
  }
}

resource "kubernetes_manifest" "service_sock_shop_catalogue_db" {
  depends_on = [kubernetes_manifest.namespace_sock_shop]
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Service"
    "metadata" = {
      "labels" = {
        "name" = "catalogue-db"
      }
      "name" = "catalogue-db"
      "namespace" = "sock-shop"
    }
    "spec" = {
      "ports" = [
        {
          "port" = 3306
          "targetPort" = 3306
        },
      ]
      "selector" = {
        "name" = "catalogue-db"
      }
    }
  }
}

resource "kubernetes_manifest" "deployment_sock_shop_front_end" {
  depends_on = [kubernetes_manifest.namespace_sock_shop]
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "Deployment"
    "metadata" = {
      "name" = "front-end"
      "namespace" = "sock-shop"
    }
    "spec" = {
      "replicas" = 1
      "selector" = {
        "matchLabels" = {
          "name" = "front-end"
        }
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "name" = "front-end"
          }
        }
        "spec" = {
          "containers" = [
            {
              "env" = [
                {
                  "name" = "SESSION_REDIS"
                  "value" = "true"
                },
              ]
              "image" = "weaveworksdemos/front-end:0.3.12"
              "livenessProbe" = {
                "httpGet" = {
                  "path" = "/"
                  "port" = 8079
                }
                "initialDelaySeconds" = 300
                "periodSeconds" = 3
              }
              "name" = "front-end"
              "ports" = [
                {
                  "containerPort" = 8079
                },
              ]
              "readinessProbe" = {
                "httpGet" = {
                  "path" = "/"
                  "port" = 8079
                }
                "initialDelaySeconds" = 30
                "periodSeconds" = 3
              }
              "resources" = {
                "limits" = {
                  "cpu" = "300m"
                  "memory" = "1000Mi"
                }
                "requests" = {
                  "cpu" = "100m"
                  "memory" = "300Mi"
                }
              }
              "securityContext" = {
                "capabilities" = {
                  "drop" = [
                    "all",
                  ]
                }
                "readOnlyRootFilesystem" = true
                "runAsNonRoot" = true
                "runAsUser" = 10001
              }
            },
          ]
          "nodeSelector" = {
            "beta.kubernetes.io/os" = "linux"
          }
        }
      }
    }
  }
}

resource "kubernetes_manifest" "service_sock_shop_front_end" {
  depends_on = [kubernetes_manifest.namespace_sock_shop]
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Service"
    "metadata" = {
      "annotations" = {
        "prometheus.io/scrape" = "true"
      }
      "labels" = {
        "name" = "front-end"
      }
      "name" = "front-end"
      "namespace" = "sock-shop"
    }
    "spec" = {
      "ports" = [
        {
          "nodePort" = 30001
          "port" = 80
          "targetPort" = 8079
        },
      ]
      "selector" = {
        "name" = "front-end"
      }
      "type" = "NodePort"
    }
  }
}

resource "kubernetes_manifest" "deployment_sock_shop_orders" {
  depends_on = [kubernetes_manifest.namespace_sock_shop]
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "Deployment"
    "metadata" = {
      "labels" = {
        "name" = "orders"
      }
      "name" = "orders"
      "namespace" = "sock-shop"
    }
    "spec" = {
      "replicas" = 1
      "selector" = {
        "matchLabels" = {
          "name" = "orders"
        }
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "name" = "orders"
          }
        }
        "spec" = {
          "containers" = [
            {
              "env" = [
                {
                  "name" = "JAVA_OPTS"
                  "value" = "-Xms64m -Xmx128m -XX:+UseG1GC -Djava.security.egd=file:/dev/urandom -Dspring.zipkin.enabled=false"
                },
              ]
              "image" = "weaveworksdemos/orders:0.4.7"
              "name" = "orders"
              "ports" = [
                {
                  "containerPort" = 80
                },
              ]
              "resources" = {
                "limits" = {
                  "cpu" = "500m"
                  "memory" = "500Mi"
                }
                "requests" = {
                  "cpu" = "100m"
                  "memory" = "300Mi"
                }
              }
              "securityContext" = {
                "capabilities" = {
                  "add" = [
                    "NET_BIND_SERVICE",
                  ]
                  "drop" = [
                    "all",
                  ]
                }
                "readOnlyRootFilesystem" = true
                "runAsNonRoot" = true
                "runAsUser" = 10001
              }
              "volumeMounts" = [
                {
                  "mountPath" = "/tmp"
                  "name" = "tmp-volume"
                },
              ]
            },
          ]
          "nodeSelector" = {
            "beta.kubernetes.io/os" = "linux"
          }
          "volumes" = [
            {
              "emptyDir" = {
                "medium" = "Memory"
              }
              "name" = "tmp-volume"
            },
          ]
        }
      }
    }
  }
}

resource "kubernetes_manifest" "service_sock_shop_orders" {
  depends_on = [kubernetes_manifest.namespace_sock_shop]
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Service"
    "metadata" = {
      "annotations" = {
        "prometheus.io/scrape" = "true"
      }
      "labels" = {
        "name" = "orders"
      }
      "name" = "orders"
      "namespace" = "sock-shop"
    }
    "spec" = {
      "ports" = [
        {
          "port" = 80
          "targetPort" = 80
        },
      ]
      "selector" = {
        "name" = "orders"
      }
    }
  }
}

resource "kubernetes_manifest" "deployment_sock_shop_orders_db" {
  depends_on = [kubernetes_manifest.namespace_sock_shop]
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "Deployment"
    "metadata" = {
      "labels" = {
        "name" = "orders-db"
      }
      "name" = "orders-db"
      "namespace" = "sock-shop"
    }
    "spec" = {
      "replicas" = 1
      "selector" = {
        "matchLabels" = {
          "name" = "orders-db"
        }
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "name" = "orders-db"
          }
        }
        "spec" = {
          "containers" = [
            {
              "image" = "mongo"
              "name" = "orders-db"
              "ports" = [
                {
                  "containerPort" = 27017
                  "name" = "mongo"
                },
              ]
              "securityContext" = {
                "capabilities" = {
                  "add" = [
                    "CHOWN",
                    "SETGID",
                    "SETUID",
                  ]
                  "drop" = [
                    "all",
                  ]
                }
                "readOnlyRootFilesystem" = true
              }
              "volumeMounts" = [
                {
                  "mountPath" = "/tmp"
                  "name" = "tmp-volume"
                },
              ]
            },
          ]
          "nodeSelector" = {
            "beta.kubernetes.io/os" = "linux"
          }
          "volumes" = [
            {
              "emptyDir" = {
                "medium" = "Memory"
              }
              "name" = "tmp-volume"
            },
          ]
        }
      }
    }
  }
}

resource "kubernetes_manifest" "service_sock_shop_orders_db" {
  depends_on = [kubernetes_manifest.namespace_sock_shop]
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Service"
    "metadata" = {
      "labels" = {
        "name" = "orders-db"
      }
      "name" = "orders-db"
      "namespace" = "sock-shop"
    }
    "spec" = {
      "ports" = [
        {
          "port" = 27017
          "targetPort" = 27017
        },
      ]
      "selector" = {
        "name" = "orders-db"
      }
    }
  }
}

resource "kubernetes_manifest" "deployment_sock_shop_payment" {
  depends_on = [kubernetes_manifest.namespace_sock_shop]
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "Deployment"
    "metadata" = {
      "labels" = {
        "name" = "payment"
      }
      "name" = "payment"
      "namespace" = "sock-shop"
    }
    "spec" = {
      "replicas" = 1
      "selector" = {
        "matchLabels" = {
          "name" = "payment"
        }
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "name" = "payment"
          }
        }
        "spec" = {
          "containers" = [
            {
              "image" = "weaveworksdemos/payment:0.4.3"
              "livenessProbe" = {
                "httpGet" = {
                  "path" = "/health"
                  "port" = 80
                }
                "initialDelaySeconds" = 300
                "periodSeconds" = 3
              }
              "name" = "payment"
              "ports" = [
                {
                  "containerPort" = 80
                },
              ]
              "readinessProbe" = {
                "httpGet" = {
                  "path" = "/health"
                  "port" = 80
                }
                "initialDelaySeconds" = 180
                "periodSeconds" = 3
              }
              "resources" = {
                "limits" = {
                  "cpu" = "200m"
                  "memory" = "200Mi"
                }
                "requests" = {
                  "cpu" = "99m"
                  "memory" = "100Mi"
                }
              }
              "securityContext" = {
                "capabilities" = {
                  "add" = [
                    "NET_BIND_SERVICE",
                  ]
                  "drop" = [
                    "all",
                  ]
                }
                "readOnlyRootFilesystem" = true
                "runAsNonRoot" = true
                "runAsUser" = 10001
              }
            },
          ]
          "nodeSelector" = {
            "beta.kubernetes.io/os" = "linux"
          }
        }
      }
    }
  }
}

resource "kubernetes_manifest" "service_sock_shop_payment" {
  depends_on = [kubernetes_manifest.namespace_sock_shop]
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Service"
    "metadata" = {
      "annotations" = {
        "prometheus.io/scrape" = "true"
      }
      "labels" = {
        "name" = "payment"
      }
      "name" = "payment"
      "namespace" = "sock-shop"
    }
    "spec" = {
      "ports" = [
        {
          "port" = 80
          "targetPort" = 80
        },
      ]
      "selector" = {
        "name" = "payment"
      }
    }
  }
}

resource "kubernetes_manifest" "deployment_sock_shop_queue_master" {
  depends_on = [kubernetes_manifest.namespace_sock_shop]
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "Deployment"
    "metadata" = {
      "labels" = {
        "name" = "queue-master"
      }
      "name" = "queue-master"
      "namespace" = "sock-shop"
    }
    "spec" = {
      "replicas" = 1
      "selector" = {
        "matchLabels" = {
          "name" = "queue-master"
        }
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "name" = "queue-master"
          }
        }
        "spec" = {
          "containers" = [
            {
              "env" = [
                {
                  "name" = "JAVA_OPTS"
                  "value" = "-Xms64m -Xmx128m -XX:+UseG1GC -Djava.security.egd=file:/dev/urandom -Dspring.zipkin.enabled=false"
                },
              ]
              "image" = "weaveworksdemos/queue-master:0.3.1"
              "name" = "queue-master"
              "ports" = [
                {
                  "containerPort" = 80
                },
              ]
              "resources" = {
                "limits" = {
                  "cpu" = "300m"
                  "memory" = "500Mi"
                }
                "requests" = {
                  "cpu" = "100m"
                  "memory" = "300Mi"
                }
              }
            },
          ]
          "nodeSelector" = {
            "beta.kubernetes.io/os" = "linux"
          }
        }
      }
    }
  }
}

resource "kubernetes_manifest" "service_sock_shop_queue_master" {
  depends_on = [kubernetes_manifest.namespace_sock_shop]
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Service"
    "metadata" = {
      "annotations" = {
        "prometheus.io/scrape" = "true"
      }
      "labels" = {
        "name" = "queue-master"
      }
      "name" = "queue-master"
      "namespace" = "sock-shop"
    }
    "spec" = {
      "ports" = [
        {
          "port" = 80
          "targetPort" = 80
        },
      ]
      "selector" = {
        "name" = "queue-master"
      }
    }
  }
}

resource "kubernetes_manifest" "deployment_sock_shop_rabbitmq" {
  depends_on = [kubernetes_manifest.namespace_sock_shop]
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "Deployment"
    "metadata" = {
      "labels" = {
        "name" = "rabbitmq"
      }
      "name" = "rabbitmq"
      "namespace" = "sock-shop"
    }
    "spec" = {
      "replicas" = 1
      "selector" = {
        "matchLabels" = {
          "name" = "rabbitmq"
        }
      }
      "template" = {
        "metadata" = {
          "annotations" = {
            "prometheus.io/scrape" = "false"
          }
          "labels" = {
            "name" = "rabbitmq"
          }
        }
        "spec" = {
          "containers" = [
            {
              "image" = "rabbitmq:3.6.8-management"
              "name" = "rabbitmq"
              "ports" = [
                {
                  "containerPort" = 15672
                  "name" = "management"
                },
                {
                  "containerPort" = 5672
                  "name" = "rabbitmq"
                },
              ]
              "securityContext" = {
                "capabilities" = {
                  "add" = [
                    "CHOWN",
                    "SETGID",
                    "SETUID",
                    "DAC_OVERRIDE",
                  ]
                  "drop" = [
                    "all",
                  ]
                }
                "readOnlyRootFilesystem" = true
              }
            },
            {
              "image" = "kbudde/rabbitmq-exporter"
              "name" = "rabbitmq-exporter"
              "ports" = [
                {
                  "containerPort" = 9090
                  "name" = "exporter"
                },
              ]
            },
          ]
          "nodeSelector" = {
            "beta.kubernetes.io/os" = "linux"
          }
        }
      }
    }
  }
}

resource "kubernetes_manifest" "service_sock_shop_rabbitmq" {
  depends_on = [kubernetes_manifest.namespace_sock_shop]
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Service"
    "metadata" = {
      "annotations" = {
        "prometheus.io/port" = "9090"
        "prometheus.io/scrape" = "true"
      }
      "labels" = {
        "name" = "rabbitmq"
      }
      "name" = "rabbitmq"
      "namespace" = "sock-shop"
    }
    "spec" = {
      "ports" = [
        {
          "name" = "rabbitmq"
          "port" = 5672
          "targetPort" = 5672
        },
        {
          "name" = "exporter"
          "port" = 9090
          "protocol" = "TCP"
          "targetPort" = "exporter"
        },
      ]
      "selector" = {
        "name" = "rabbitmq"
      }
    }
  }
}

resource "kubernetes_manifest" "deployment_sock_shop_session_db" {
  depends_on = [kubernetes_manifest.namespace_sock_shop]
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "Deployment"
    "metadata" = {
      "labels" = {
        "name" = "session-db"
      }
      "name" = "session-db"
      "namespace" = "sock-shop"
    }
    "spec" = {
      "replicas" = 1
      "selector" = {
        "matchLabels" = {
          "name" = "session-db"
        }
      }
      "template" = {
        "metadata" = {
          "annotations" = {
            "prometheus.io.scrape" = "false"
          }
          "labels" = {
            "name" = "session-db"
          }
        }
        "spec" = {
          "containers" = [
            {
              "image" = "redis:alpine"
              "name" = "session-db"
              "ports" = [
                {
                  "containerPort" = 6379
                  "name" = "redis"
                },
              ]
              "securityContext" = {
                "capabilities" = {
                  "add" = [
                    "CHOWN",
                    "SETGID",
                    "SETUID",
                  ]
                  "drop" = [
                    "all",
                  ]
                }
                "readOnlyRootFilesystem" = true
              }
            },
          ]
          "nodeSelector" = {
            "beta.kubernetes.io/os" = "linux"
          }
        }
      }
    }
  }
}

resource "kubernetes_manifest" "service_sock_shop_session_db" {
  depends_on = [kubernetes_manifest.namespace_sock_shop]
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Service"
    "metadata" = {
      "labels" = {
        "name" = "session-db"
      }
      "name" = "session-db"
      "namespace" = "sock-shop"
    }
    "spec" = {
      "ports" = [
        {
          "port" = 6379
          "targetPort" = 6379
        },
      ]
      "selector" = {
        "name" = "session-db"
      }
    }
  }
}

resource "kubernetes_manifest" "deployment_sock_shop_shipping" {
  depends_on = [kubernetes_manifest.namespace_sock_shop]
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "Deployment"
    "metadata" = {
      "labels" = {
        "name" = "shipping"
      }
      "name" = "shipping"
      "namespace" = "sock-shop"
    }
    "spec" = {
      "replicas" = 1
      "selector" = {
        "matchLabels" = {
          "name" = "shipping"
        }
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "name" = "shipping"
          }
        }
        "spec" = {
          "containers" = [
            {
              "env" = [
                {
                  "name" = "ZIPKIN"
                  "value" = "zipkin.jaeger.svc.cluster.local"
                },
                {
                  "name" = "JAVA_OPTS"
                  "value" = "-Xms64m -Xmx128m -XX:+UseG1GC -Djava.security.egd=file:/dev/urandom -Dspring.zipkin.enabled=false"
                },
              ]
              "image" = "weaveworksdemos/shipping:0.4.8"
              "name" = "shipping"
              "ports" = [
                {
                  "containerPort" = 80
                },
              ]
              "resources" = {
                "limits" = {
                  "cpu" = "300m"
                  "memory" = "500Mi"
                }
                "requests" = {
                  "cpu" = "100m"
                  "memory" = "300Mi"
                }
              }
              "securityContext" = {
                "capabilities" = {
                  "add" = [
                    "NET_BIND_SERVICE",
                  ]
                  "drop" = [
                    "all",
                  ]
                }
                "readOnlyRootFilesystem" = true
                "runAsNonRoot" = true
                "runAsUser" = 10001
              }
              "volumeMounts" = [
                {
                  "mountPath" = "/tmp"
                  "name" = "tmp-volume"
                },
              ]
            },
          ]
          "nodeSelector" = {
            "beta.kubernetes.io/os" = "linux"
          }
          "volumes" = [
            {
              "emptyDir" = {
                "medium" = "Memory"
              }
              "name" = "tmp-volume"
            },
          ]
        }
      }
    }
  }
}

resource "kubernetes_manifest" "service_sock_shop_shipping" {
  depends_on = [kubernetes_manifest.namespace_sock_shop]
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Service"
    "metadata" = {
      "annotations" = {
        "prometheus.io/scrape" = "true"
      }
      "labels" = {
        "name" = "shipping"
      }
      "name" = "shipping"
      "namespace" = "sock-shop"
    }
    "spec" = {
      "ports" = [
        {
          "port" = 80
          "targetPort" = 80
        },
      ]
      "selector" = {
        "name" = "shipping"
      }
    }
  }
}

resource "kubernetes_manifest" "deployment_sock_shop_user" {
  depends_on = [kubernetes_manifest.namespace_sock_shop]
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "Deployment"
    "metadata" = {
      "labels" = {
        "name" = "user"
      }
      "name" = "user"
      "namespace" = "sock-shop"
    }
    "spec" = {
      "replicas" = 1
      "selector" = {
        "matchLabels" = {
          "name" = "user"
        }
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "name" = "user"
          }
        }
        "spec" = {
          "containers" = [
            {
              "env" = [
                {
                  "name" = "mongo"
                  "value" = "user-db:27017"
                },
              ]
              "image" = "weaveworksdemos/user:0.4.7"
              "livenessProbe" = {
                "httpGet" = {
                  "path" = "/health"
                  "port" = 80
                }
                "initialDelaySeconds" = 300
                "periodSeconds" = 3
              }
              "name" = "user"
              "ports" = [
                {
                  "containerPort" = 80
                },
              ]
              "readinessProbe" = {
                "httpGet" = {
                  "path" = "/health"
                  "port" = 80
                }
                "initialDelaySeconds" = 180
                "periodSeconds" = 3
              }
              "resources" = {
                "limits" = {
                  "cpu" = "300m"
                  "memory" = "200Mi"
                }
                "requests" = {
                  "cpu" = "100m"
                  "memory" = "100Mi"
                }
              }
              "securityContext" = {
                "capabilities" = {
                  "add" = [
                    "NET_BIND_SERVICE",
                  ]
                  "drop" = [
                    "all",
                  ]
                }
                "readOnlyRootFilesystem" = true
                "runAsNonRoot" = true
                "runAsUser" = 10001
              }
            },
          ]
          "nodeSelector" = {
            "beta.kubernetes.io/os" = "linux"
          }
        }
      }
    }
  }
}

resource "kubernetes_manifest" "service_sock_shop_user" {
  depends_on = [kubernetes_manifest.namespace_sock_shop]
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Service"
    "metadata" = {
      "annotations" = {
        "prometheus.io/scrape" = "true"
      }
      "labels" = {
        "name" = "user"
      }
      "name" = "user"
      "namespace" = "sock-shop"
    }
    "spec" = {
      "ports" = [
        {
          "port" = 80
          "targetPort" = 80
        },
      ]
      "selector" = {
        "name" = "user"
      }
    }
  }
}

resource "kubernetes_manifest" "deployment_sock_shop_user_db" {
  depends_on = [kubernetes_manifest.namespace_sock_shop]
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "Deployment"
    "metadata" = {
      "labels" = {
        "name" = "user-db"
      }
      "name" = "user-db"
      "namespace" = "sock-shop"
    }
    "spec" = {
      "replicas" = 1
      "selector" = {
        "matchLabels" = {
          "name" = "user-db"
        }
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "name" = "user-db"
          }
        }
        "spec" = {
          "containers" = [
            {
              "image" = "weaveworksdemos/user-db:0.3.0"
              "name" = "user-db"
              "ports" = [
                {
                  "containerPort" = 27017
                  "name" = "mongo"
                },
              ]
              "securityContext" = {
                "capabilities" = {
                  "add" = [
                    "CHOWN",
                    "SETGID",
                    "SETUID",
                  ]
                  "drop" = [
                    "all",
                  ]
                }
                "readOnlyRootFilesystem" = true
              }
              "volumeMounts" = [
                {
                  "mountPath" = "/tmp"
                  "name" = "tmp-volume"
                },
              ]
            },
          ]
          "nodeSelector" = {
            "beta.kubernetes.io/os" = "linux"
          }
          "volumes" = [
            {
              "emptyDir" = {
                "medium" = "Memory"
              }
              "name" = "tmp-volume"
            },
          ]
        }
      }
    }
  }
}

resource "kubernetes_manifest" "service_sock_shop_user_db" {
  depends_on = [kubernetes_manifest.namespace_sock_shop]
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Service"
    "metadata" = {
      "labels" = {
        "name" = "user-db"
      }
      "name" = "user-db"
      "namespace" = "sock-shop"
    }
    "spec" = {
      "ports" = [
        {
          "port" = 27017
          "targetPort" = 27017
        },
      ]
      "selector" = {
        "name" = "user-db"
      }
    }
  }
}


resource "kubernetes_manifest" "ingress_sock_sock_shop" {
  depends_on = [kubernetes_manifest.namespace_sock_shop]
  manifest = {
    "apiVersion" = "networking.k8s.io/v1"
    "kind" = "Ingress"
    "metadata" = {
      "annotations" = {
        "alb.ingress.kubernetes.io/group.name" = "eks-alb-ingress"
        "alb.ingress.kubernetes.io/load-balancer-name" = "eks-alb-ingress"
        "alb.ingress.kubernetes.io/scheme" = "internal"
        "alb.ingress.kubernetes.io/target-type" = "ip"
        "alb.ingress.kubernetes.io/subnets" = "${var.spoke_subnets[0].id}, ${var.spoke_subnets[1].id}"
      }
      "name" = "sock-shop"
      "namespace" = "sock-shop"
    }
    "spec" = {
      "ingressClassName" = "alb"
      "rules" = [
        {
          "http" = {
            "paths" = [
              {
                "backend" = {
                  "service" = {
                    "name" = "front-end"
                    "port" = {
                      "number" = 80
                    }
                  }
                }
                "path" = "/"
                "pathType" = "Prefix"
              },
            ]
          }
        },
      ]
    }
  }
}

#resource "time_sleep" "subnets" {
#  create_duration = "40s"
#
#  depends_on = [kubernetes_manifest.ingress_sock_sock_shop]
#}