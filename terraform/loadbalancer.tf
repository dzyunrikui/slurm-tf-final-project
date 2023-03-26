resource "yandex_alb_load_balancer" "this" {
  name        = "practicum-balancer"

  network_id  = yandex_vpc_network.this.id
 
  allocation_policy {
    location {
       for_each = toset(var.az)
       zone_id   = each.value
       subnet_id = var.vpc_id != "" ? var.vpc_id : yandex_vpc_network.this.id
     }
  }
 
  listener {
    name = "my-listener"
    endpoint {
    address {
  external_ipv4_address {
  }
    }
      ports = [ 8080 ]
    }
    http {
      handler {
           http_router_id = yandex_alb_http_router.this.id
      }
    }
  }
 
  log_options {
    discard_rule {
       http_code_intervals = ["2XX"]
       discard_percent = 75
     }
  }
}

resource "yandex_alb_http_router" "this" {
  name   = "practicum-router"
  labels = {
    tf-label    = "tf-label-value"
    empty-label = ""
  }
}

resource "yandex_alb_virtual_host" "this" {
  name           = "tf-virtual-host"
  http_router_id = yandex_alb_http_router.this.id
  route {
    name = "tf-route"
    http_route {
      http_route_action {
        backend_group_id = "slurm-backend-group"
        timeout          = "3s"
      }
    }
  }
}
resource "yandex_alb_backend_group" "this" {
  name                     = "slurm-backend-group"
  session_affinity {
    connection {
      source_ip = true
    }
  }

  http_backend {
    name                   = "slurm_backend"
    weight                 = 1
    port                   = 80
    target_group_ids       = ["slurm-target-group"]
    load_balancing_config {
      panic_threshold      = 90
    }    
    healthcheck {
      timeout              = "10s"
      interval             = "2s"
      healthy_threshold    = 10
      unhealthy_threshold  = 15 
      http_healthcheck {
        path               = "/"
      }
    }
  }
} 

resource "yandex_alb_target_group" "this" {
  count = var.vm_count
  name           = "slurm-target-group"

  target {
    subnet_id    = ["${yandex_vpc_subnet.this[var.az[count.index % 3 ]].id }"]
    ip_address   = var.cidr_blocks[index(var.az, each.value)]
  }
}


output "yandex_vpc_address" "addr" {
  name = "exampleAddress"

  external_ipv4_address {
  for_each = toset(var.az)
   zone_id = each.value
  }
}
