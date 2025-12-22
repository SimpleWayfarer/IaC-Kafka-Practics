#!/bin/bash
#Получение IP-адресов
producer_ip=$(yc compute instance get producer --format json | jq .network_interfaces[0].primary_v4_address.one_to_one_nat.address -r)
consumer_ip=$(yc compute instance get consumer --format json | jq .network_interfaces[0].primary_v4_address.one_to_one_nat.address -r)

#Запись IP-адресов
touch ansible/hosts.ini
private_key_file="/home/user/.ssh/id_rsa"
echo "producer ansible_host=$producer_ip ansible_user=ubuntu ansible_private_key_file=$private_key_file ansible_become=yes" >> ansible/hosts.ini
echo "consumer ansible_host=$consumer_ip ansible_user=ubuntu ansible_private_key_file=$private_key_file ansible_become=yes" >> ansible/hosts.ini

#Получение и запись FQDN кластера
cluster_fqdn=$(yc managed-kafka cluster list-hosts kafka-cluster --format json | jq  '.[0].name' -r)
touch ansible/FQDN.yaml
echo "FQDN: $cluster_fqdn" >> ansible/FQDN.yaml

