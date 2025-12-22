locals {
  kafka_cluster_name    = "kafka-cluster" 
  kafka_username        = "user" 
  kafka_password        = "password"
  kafka_version         = "3.9"
  topic_name            = "kafka-topic" 
}

# Apache Kafka® cluster
resource "yandex_mdb_kafka_cluster" "kafka_cluster" {
  description        = "Managed Service for Apache Kafka® cluster"
  environment        = "PRODUCTION"
  name               = local.kafka_cluster_name
  network_id         = yandex_vpc_network.kafka-network.id
  subnet_ids         = [yandex_vpc_subnet.kafka-subnet.id]
  

  config {
    assign_public_ip   = false
    brokers_count    = 1
    version          = local.kafka_version
    kafka {
      resources {
        disk_size          = 10 # GB
        disk_type_id       = "network-ssd"
        resource_preset_id = "s2.micro"
      }
    }

    zones = [
      "ru-central1-a"
    ]
  }
}

# Apache Kafka® user
resource "yandex_mdb_kafka_user" "kafka_user" {
  cluster_id = yandex_mdb_kafka_cluster.kafka_cluster.id
  name       = local.kafka_username
  password   = local.kafka_password

  permission {
    topic_name = "*"
    role       = "ACCESS_ROLE_CONSUMER"
  }

  permission {
    topic_name = "*"
    role       = "ACCESS_ROLE_PRODUCER"
  }

  permission {
    topic_name = "*"
    role       = "ACCESS_ROLE_ADMIN"
  }
}

# Apache Kafka® topic
resource "yandex_mdb_kafka_topic" "kafka_topic" {
  cluster_id         = yandex_mdb_kafka_cluster.kafka_cluster.id
  name               = local.topic_name
  partitions         = 1
  replication_factor = 1
}
