# Переменная для пути файла публичного ключа SSH
variable "public_key_file"{
  type        = string
  default     = "/home/user/.ssh/id_rsa.pub"
}

# Образ Ubuntu
data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts" 
}

# Создание VPС, подсети и адресса
resource "yandex_vpc_network" "this" {
  name = "network"
}
resource "yandex_vpc_subnet" "subnet" {
  name           = "subnet"
  zone           = "ru-central1-a"
  v4_cidr_blocks = ["192.168.10.0/24"]
  network_id     = yandex_vpc_network.this.id
}
resource "yandex_vpc_address" "addr" {
  name           = "address"
  external_ipv4_address {
    zone_id = "ru-central1-a"
  }
}

# Создание виртуальной машины
resource "yandex_compute_instance" "this" {
  name                      = "linux-vm"
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
    subnet_id = yandex_vpc_subnet.subnet.id
    nat = true
    nat_ip_address = yandex_vpc_address.addr.external_ipv4_address[0].address
  }
  
  metadata = {
    ssh-keys = "ubuntu:${file(var.public_key_file)}"
  }
}

# Вывод ip адреса
output "ansible_host"{
  value = yandex_compute_instance.this.network_interface[0].nat_ip_address
}

