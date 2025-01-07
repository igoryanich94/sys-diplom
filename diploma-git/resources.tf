### Создание Сети

resource "yandex_vpc_network" "network_diploma" {
  name = "network_diploma"
  description = "Главная сеть всего"
}

### Создание подсетей

resource "yandex_vpc_subnet" "internal-1" {
  name = "internal-1"
  network_id = yandex_vpc_network.network_diploma.id
  v4_cidr_blocks = ["172.16.1.0/24"]
  route_table_id = yandex_vpc_route_table.rouretable.id
  zone = "ru-central1-a"
  description = "подсеть для WM1"
}

resource "yandex_vpc_subnet" "internal-2" {
  name = "internal-2"
  network_id = yandex_vpc_network.network_diploma.id
  v4_cidr_blocks = ["172.16.2.0/24"]
  route_table_id = yandex_vpc_route_table.rouretable.id
  zone = "ru-central1-b"
  description = "подсеть для WM2"
}

resource "yandex_vpc_subnet" "internal-3" {
  name = "internal-3"
  network_id = yandex_vpc_network.network_diploma.id
  v4_cidr_blocks = ["172.16.3.0/24"]
  route_table_id = yandex_vpc_route_table.rouretable.id
  zone = "ru-central1-d"
  description = "подсеть для elasticsearch"
}

resource "yandex_vpc_subnet" "external-1" {
  name = "external-1"
  network_id = yandex_vpc_network.network_diploma.id
  v4_cidr_blocks = ["172.16.4.0/24"]
  zone = "ru-central1-d"
  description = "подсеть для zabbix, kibana"
}

### Создание NAT шлюза и таблицы маршрутизации

resource "yandex_vpc_gateway" "gateway" {
    name = "gateway"
    shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "rouretable" {
  name       = "routetable"
  network_id = yandex_vpc_network.network_diploma.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.gateway.id
  }
}


### Создание дисков

resource "yandex_compute_disk" "wm1disk" {
    name = "wm1disk"
    size = 10
    image_id = var.image_id
    zone = "ru-central1-a"
    description = "Загрузочный диск для WM1"
  }

resource "yandex_compute_disk" "wm2disk" {
    name = "wm2disk"
    size = 10
    image_id = var.image_id
    zone = "ru-central1-b"
    description = "Загрузочный диск для WM2"
  }

resource "yandex_compute_disk" "elasticdisk" {
    name = "elasticdisk"
    size = 10
    image_id = var.image_id
    zone = "ru-central1-d"
    description = "Загрузочный диск для elasticsearch"
  }

resource "yandex_compute_disk" "kibanadisk" {
    name = "kibanadisk"
    size = 10
    image_id = var.image_id
    zone = "ru-central1-d"
    description = "Загрузочный диск для kibana"
  }

resource "yandex_compute_disk" "zabbixdisk" {
    name = "zabbixdisk"
    size = 10
    image_id = var.image_id
    zone = "ru-central1-d"
    description = "Загрузочный диск для zabbix"
  }

resource "yandex_compute_disk" "bastiondisk" {
    name = "bastiiondisk"
    size = 10
    image_id = var.image_id
    zone = "ru-central1-d"
    description = "Загрузочный диск для bastion-wm"
  }


  ### Создание и настройка балансировщика 
  # Создание Target групп

  resource "yandex_alb_target_group" "target-group-wms" {
  name      = "target-group-ms"

  target {
    subnet_id = yandex_vpc_subnet.internal-1.id
    ip_address   = yandex_compute_instance.wm1.network_interface.0.ip_address
  }

  target {
    subnet_id = yandex_vpc_subnet.internal-2.id
    ip_address   = yandex_compute_instance.wm2.network_interface.0.ip_address
  }
}

# Создание Backend групп

resource "yandex_alb_backend_group" "backend-group" {
  name      = "backend-group"

    http_backend {
    name = "http-backend"
    weight = 1
    port = 80
    target_group_ids = [yandex_alb_target_group.target-group-wms.id]
    
    load_balancing_config {
      panic_threshold = 90
    }    
    healthcheck {
      timeout             = "10s"
      interval            = "3s"
      healthy_threshold   = 10
      unhealthy_threshold = 15
      http_healthcheck {
        path  = "/"
      }
    }
  }
}


# Создание http-router

resource "yandex_alb_http_router" "http-router" {
  name      = "http-router"
}

resource "yandex_alb_virtual_host" "router-host" {
  name           = "router-host"
  http_router_id = yandex_alb_http_router.http-router.id
  route {
    name = "route"
    http_route {
      http_match {
        path {
          prefix = "/"
        }
      }
      http_route_action {
        backend_group_id = yandex_alb_backend_group.backend-group.id
        timeout          = "3s"
      }
    }
  }
}

# Создание Application load balancer

resource "yandex_alb_load_balancer" "applb" {
  name        = "applb"

  network_id  = yandex_vpc_network.network_diploma.id  
  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.internal-1.id
    }
    
    location {
      zone_id   = "ru-central1-b"
      subnet_id = yandex_vpc_subnet.internal-2.id
    }
  }
  
  listener {
    name = "my-listener"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [ 80 ]
    }    
    http {
      handler {
        http_router_id = yandex_alb_http_router.http-router.id
      }
    }
  }
}

### Создание security groups

resource "yandex_vpc_security_group" "bastion-sg" {
  name        = "bastion-sg"
  description = "security group for bastion host"
  network_id  = yandex_vpc_network.network_diploma.id

  ingress {
    protocol       = "TCP"
    description    = "access SSH only"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  ingress {
    protocol       = "ICMP"
    description    = "ICMP access"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    description    = "outputs access"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "zabbix-sg" {
  name       = "zabbix-sg"
  description = "security group for zabbix server host"
  network_id = yandex_vpc_network.network_diploma.id

  ingress {
    protocol       = "TCP"
    description    = "zabbix connections from internet"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port = 10050
    to_port = 10051
  }
  
  ingress {
    protocol       = "TCP"
    description    = "zabbix connections to web-interface from internet"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  } 

  ingress {
    protocol       = "ICMP"
    description    = "ICMP access"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    description    = "allow any outputs connection"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "kibana-sg" {
  name       = "kibana-sg"
  description = "security group for kibana server host"
  network_id = yandex_vpc_network.network_diploma.id

  ingress {
    protocol       = "TCP"
    description    = "kibana connections from internet"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 5601
  }

  ingress {
    protocol       = "ICMP"
    description    = "ICMP access"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    description    = "allow any outputs connection"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "internal-sg" {
  name       = "internal-sg"
  description = "security group for internal subnets"
  network_id = yandex_vpc_network.network_diploma.id
  ingress {
    protocol       = "ANY"
    description    = "access from internal subnets"
    v4_cidr_blocks = ["172.16.1.0/24", "172.16.2.0/24", "172.16.3.0/24", "172.16.4.0/24"]
  }

  egress {
    protocol       = "ANY"
    description    = "outputs"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
