#!/bin/bash
# This script will install docker, minikube, kubectl, terraform and helm

# Colors
GREEN='\033[0;32m'
NC='\033[0m' 
RED='\033[0;31m'

divider="============================================"

# Function to print formated text
echo_text () {

    echo -e "${GREEN}$divider${NC}"
    echo -e "${NC} $(printf "${1}")"
    echo -e "${GREEN}${divider}${NC}"
}

# Update and install prerequisites
echo_text "Updating and installing prerequisites"
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release gnupg2 software-properties-common


# Check if docker is installed
if [ -x "$(command -v docker)" ]; then
    echo_text "Docker is already installed"

else
    echo_text "Docker is not installed"
    # Install docker
    #Add docker GPG key
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg


    echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
fi


# Install minikube if not already installed
if [ -x "$(command -v minikube)" ]; then
    echo_text "Minikube is already installed"
else
    echo_text "Minikube is not installed. Installing it now.."
    # Install minikube
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    sudo install minikube-linux-amd64 /usr/local/bin/minikube
fi

minikube start
echo_text "Minikube is started"

# Install kubectl if not already installed
if [ -x "$(command -v kubectl)" ]; then
    echo_text "Kubectl is already installed"
else
    echo_text "Kubectl is not installed. Installing it now.."
    # Install kubectl
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
    
    # Validate checksum
    # If checksum is ok continue, else exit
    if echo "$(cat kubectl.sha256) kubectl" | sha256sum --check | grep -q OK 
    then
        echo "Checksum is ok"    
        sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
        # Verify installation
        if [-x "$(command -v kubectl)" ]; then
            echo_text "Kubectl is installed"
        else
            echo_text "Kubectl is not installed"
            exit 1
        fi
    else
        echo "${RED}Checksum is not ok"
        exit 1
    fi
fi

#Install terraform
if [ -x "$(command -v terraform)" ]; then
    echo_text "Terraform is already installed"
else
    echo_text "Terraform is not installed. Installing it now.."
    # Install terraform
    sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
    
    #Install hashicorp GPG key
    wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
    # Verify key fingerprint
    gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/hashicorp.list
    # Install terraform
    sudo apt update
    sudo apt-get install terraform
fi


#Install helm 
if [ -x "$(command -v helm)" ]; then
    echo_text "Helm is already installed"
else
    echo_text "Helm is not installed. Installing it now.."
    # Install helm
    curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
    sudo apt-get install apt-transport-https --yes
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
    sudo apt-get update
    sudo apt-get install helm
fi

echo_text "Enabling nginx ingress addon"
minikube addons enable ingress

echo_text "Deploying ingress for SonarQube"
kubectl apply -f ingress.yaml

echo_text "Initializing terraform and applying templates"
terraform init
terraform apply -auto-approve


echo_text "Waiting 30 secounds for sonarqube to startup"
sleep 30
echo_text "Testing page"
curl http://$(minikube ip)/sonarqube/








