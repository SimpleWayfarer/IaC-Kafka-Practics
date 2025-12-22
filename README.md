Данный пример создает с помощью Terraform виртуальную машину в Yandex Cloud и устаналивает на ней веб-сервер nginx с помощью Ansible.

# Установка компонентов 
1) [Установка и инициализация интерфейса командной строки Yandex Cloud](https://yandex.cloud/ru/docs/cli/quickstart)
2) [Установка Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
3) [Установка Ansible](https://docs.ansible.com/projects/ansible/latest/installation_guide/intro_installation.html)

# Запуск
1) [Создать SSH ключи для подключения к облаку](https://yandex.cloud/ru/docs/organization/operations/add-ssh)
2) Сохранить ключи в папке /home/user/.ssh Имя id_rsa для приватного, id_rsa.pub для публичного. Публичный ключ нужен terraform при создании виртуальных машин (локальная переменная public_key_file в terraform/main.tf), приватный ключ используется Ansible для подключения к созданным виртуальным машинам (переменная private_key_file в ansible-init.sh)
3) Создание виртуальных машин и кластера Apache Kafka с пользователем и топиком
```
chmod +x ./terraform/create.sh
./terraform/create.sh
```
4) Получение данных (IP-адреса ВМ и FQDN кластера Kafka) для Ansible
```
chmod +x ansible-init.sh
./ansible-init.sh
```
5) Запуск Ansible плейбука для конфигурирования ВМ
```
sudo ansible-playbook ansible/playbook.yaml 
```

# Удаление кластера и виртуальных машин 
```
chmod +x ./terraform/destroy.sh
./terraform/destroy.sh
```
