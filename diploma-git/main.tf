### Создание виртуальных машин

resource "yandex_compute_instance" "wm1" {
  name = "wm1"
  hostname = "wm1"
  zone = "ru-central1-a"
  platform_id = "standard-v1"
  description = "Виртуальная машина для WEB1"
  resources {
    cores = 2
    memory = 2
    core_fraction = 20
  }
  boot_disk {
    disk_id = yandex_compute_disk.wm1disk.id
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.internal-1.id
    security_group_ids = [yandex_vpc_security_group.internal-sg.id]
    ip_address = "172.16.1.3"
  }
  metadata = { 
    user-data = "${file("./userdata.yml")}"
  }
  scheduling_policy {
    preemptible = true
  }
}

resource "yandex_compute_instance" "wm2" {
  name = "wm2"
  hostname = "wm2"
  zone = "ru-central1-b"
  platform_id = "standard-v1"
  description = "Виртуальная машина для WEB2"
  resources {
    cores = 2
    memory = 2
    core_fraction = 20
  }
  boot_disk {
    disk_id = yandex_compute_disk.wm2disk.id
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.internal-2.id
    security_group_ids = [yandex_vpc_security_group.internal-sg.id]
    ip_address = "172.16.2.3"
  }
  metadata = { 
    user-data = "${file("./userdata.yml")}"
  }
  scheduling_policy {
    preemptible = true
  }
}

resource "yandex_compute_instance" "elasticsearch" {
  name = "elasticsearch"
  hostname = "elasticsearch"
  zone = "ru-central1-d"
  platform_id = "standard-v2"
  description = "Виртуальная машина для elasticsearch"
  resources {
    cores = 2
    memory = 2
    core_fraction = 20
  }
  boot_disk {
    disk_id = yandex_compute_disk.elasticdisk.id
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.internal-3.id
    security_group_ids = [yandex_vpc_security_group.internal-sg.id]
    ip_address = "172.16.3.3"
  }
  metadata = { 
    user-data = "${file("./userdata.yml")}"
  }
  scheduling_policy {
    preemptible = true
  }
}

resource "yandex_compute_instance" "kibana" {
  name = "kibana"
  hostname = "kibana"
  zone = "ru-central1-d"
  platform_id = "standard-v2"
  description = "Виртуальная машина для kibana"
  resources {
    cores = 2
    memory = 2
    core_fraction = 20
  }
  boot_disk {
    disk_id = yandex_compute_disk.kibanadisk.id
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.external-1.id
    security_group_ids = [yandex_vpc_security_group.kibana-sg.id, yandex_vpc_security_group.internal-sg.id]
    nat = true
    ip_address = "172.16.4.5"
  }
  metadata = { 
    user-data = "${file("./userdata.yml")}"
  }
  scheduling_policy {
    preemptible = true
  }
}

resource "yandex_compute_instance" "zabbix" {
  name = "zabbix"
  hostname = "zabbix"
  zone = "ru-central1-d"
  platform_id = "standard-v2"
  description = "Виртуальная машина для zabbix"
  resources {
    cores = 2
    memory = 2
    core_fraction = 20
  }
  boot_disk {
    disk_id = yandex_compute_disk.zabbixdisk.id
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.external-1.id
    security_group_ids = [yandex_vpc_security_group.zabbix-sg.id, yandex_vpc_security_group.internal-sg.id]
    nat = true
    ip_address = "172.16.4.3"
  }
  metadata = { 
    user-data = "${file("./userdata.yml")}"
  }
  scheduling_policy {
    preemptible = true
  }
}

resource "yandex_compute_instance" "bastion" {
  name = "bastion"
  hostname = "bastion"
  zone = "ru-central1-d"
  platform_id = "standard-v2"
  description = "Виртуальная машина для bastion host"
  resources {
    cores = 2
    memory = 2
    core_fraction = 20
  }
  boot_disk {
    disk_id = yandex_compute_disk.bastiondisk.id
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.external-1.id
    security_group_ids = [yandex_vpc_security_group.bastion-sg.id, yandex_vpc_security_group.internal-sg.id]
    nat = true
    ip_address = "172.16.4.4"
  }
  metadata = { 
    user-data = "${file("./userdata.yml")}"
  }
  scheduling_policy {
    preemptible = true
  }
}



