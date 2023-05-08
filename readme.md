# Deploy Sonarqube with postgresql in Minikube
This script will install docker, minikube, kubectl, terraform, helm and deploy terraform template for sonarqube and postgresql.


## Steps

Run installation script:
```bash
source ./setup.sh
```
Note: It will prompt for password. 
User with sudo privilages is requered

To access page in browser get minikube ip by executing command

```bash
minikube ip
```
Url will be:
```bash
http://<minikube ip>/sonarqube/
```