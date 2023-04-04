# Version 1.0.0
# Update essential pakages
sudo apt update && sudo apt-get update

# Install Docker & Docker compose
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo service docker start

# Install Ansible
sudo apt update && sudo apt-get update
sudo apt install software-properties-common pass -y
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt install ansible -y

# Install Jenkins with 2023 version GPG key and change user mode for using Docker service
# Then restart Jenkins service
sudo apt update
sudo apt install openjdk-11-jre pass -y
curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins -y

# Install Grafana
sudo apt-get update
sudo apt-get install -y adduser libfontconfig1
wget https://dl.grafana.com/oss/release/grafana_8.0.5_amd64.deb
sudo dpkg -i grafana_8.0.5_amd64.deb
sudo systemctl start grafana-server
sudo systemctl enable grafana-server
sudo ufw allow 3000/tcp
