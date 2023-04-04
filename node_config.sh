# Version 1.0.0
# Update essential pakages
sudo apt update && sudo apt-get update

# Install Java 11 jre
sudo apt update && sudo apt-get update
sudo apt install software-properties-common pass -y
sudo apt install openjdk-11-jre pass -y

# Install Node using nvm command
curl -sL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh -o install_nvm.sh
bash install_nvm.sh
export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
source ~/.profile
nvm install 18.13.0
nvm use 18.13.0
