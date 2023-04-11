# Readme Mock

<!-- <img src="https://devops4solutions.com/wp-content/uploads/2020/09/CI-CD-using-Jenkins-and-Docker.png"> -->

![Screenshot](diagram_update.jpg)

Dev code golang đẩy lên github, Jenkins nghe chạy pipeline build image đẩy lên Docker hub, Ansible deploy image từ hub lên instance EC2 dưới dạng Docker container, code K6 tích hợp với InfluxDB và Grafana được orchestra bới Docker-compose .
