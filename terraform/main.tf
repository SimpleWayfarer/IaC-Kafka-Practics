locals {
  public_key_file       = "/home/user/.ssh/id_rsa.pub"
  network_name          = "kafka-network" 
  subnet_name           = "kafka-subnet" 
}

# Образ Ubuntu
data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts" 
}

# Создание VPС, подсети и адрессов
resource "yandex_vpc_network" "kafka-network" {
  name = local.network_name
}
resource "yandex_vpc_subnet" "kafka-subnet" {
  name           = local.subnet_name
  zone           = "ru-central1-a"
  v4_cidr_blocks = ["192.168.10.0/24"]
  network_id     = yandex_vpc_network.kafka-network.id
}
resource "yandex_vpc_address" "consumer-address" {
  name           = "consumer-address"
  external_ipv4_address {
    zone_id = "ru-central1-a"
  }
}
resource "yandex_vpc_address" "producer-address" {
  name           = "producer-address"
  external_ipv4_address {
    zone_id = "ru-central1-a"
  }
}

# Создание виртуальной машины продюсера
resource "yandex_compute_instance" "producer" {
  name                      = "producer"
  allow_stopping_for_update = true
  platform_id               = "standard-v3"
  zone                      = "ru-central1-a"

  resources {
    cores  = "2"
    memory = "4"
  }
  
  boot_disk {
    initialize_params {
    image_id = data.yandex_compute_image.ubuntu.id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.kafka-subnet.id
    nat = true
    nat_ip_address = yandex_vpc_address.producer-address.external_ipv4_address[0].address
  }
  
  metadata = {
    ssh-keys = "ubuntu:${file(local.public_key_file)}"
  }
}

# Создание виртуальной машины консюмера
resource "yandex_compute_instance" "consumer" {
  name                      = "consumer"
  allow_stopping_for_update = true
  platform_id               = "standard-v3"
  zone                      = "ru-central1-a"

  resources {
    cores  = "2"
    memory = "4"
  }
  
  boot_disk {
    initialize_params {
    image_id = data.yandex_compute_image.ubuntu.id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.kafka-subnet.id
    nat = true
    nat_ip_address = yandex_vpc_address.consumer-address.external_ipv4_address[0].address
  }
  
  metadata = {
    ssh-keys = "ubuntu:${file(local.public_key_file)}"
  }
}



