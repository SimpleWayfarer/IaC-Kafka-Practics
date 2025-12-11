#!/bin/bash

#terraform часть
cd terraform
export YC_TOKEN=$(yc iam create-token)
export YC_CLOUD_ID=$(yc config get cloud-id)
export YC_FOLDER_ID=$(yc config get folder-id)
echo "Запуск Terraform"
terraform init
terraform plan
echo "yes" | terraform apply

#создание файла с хостом для ansible
ip_adress=$(terraform output | tr -d ' "')
private_key_file="/home/user/.ssh/id_rsa"
touch ../ansible/hosts.ini
echo "ubuntu $ip_adress ansible_user=ubuntu ansible_private_key_file=$private_key_file ansible_become=yes" > ../ansible/hosts.ini
echo "Файл hosts.ini создан"

#ansible часть
sleep 60
echo "Запуск Ansible"
cd ../ansible
sudo ansible all -m ping
sudo ansible-playbook playbook.yaml
