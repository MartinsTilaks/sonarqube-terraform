# Deploy Sonarqube with postgresql in Minikube

## Steps

Install minikube in your environment
Link to documentation: https://minikube.sigs.k8s.io/docs/start/

Installation commands for Linux environment:
```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
``` 

Start minikube cluster:
```bash
minikube start
```

Install helm:
Documentation: https://helm.sh/docs/intro/install/
```bash
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm
```
Create kubectl alias:
```bash
echo "alias kubectl=\"minikube kubectl --\"" >> ~/.bash_aliases
```

Install nginx Ingress Controller:
```bash
minikube addons enable ingress
```

Expose Sonarqube loadbalancer in minikube we need to create a tunnel
**Note: Execute this command in seperate windown and leave open
Link to documentation: https://minikube.sigs.k8s.io/docs/handbook/accessing/#example-of-loadbalancer


```bash
minikube tunnel
```

Initialize terraform in the directory:

```bash
terraform init
```

Check variables defined in especially credentials:
```bash
cat ./variables.tf
```

Replace username and password if needed
```bash
nano ./variables.tf
```

*Note: I would recomend using some kind of credential vault like aws kms to store sensitive information and access them when deploying terraform, but for proof of concept and deploying terrafom in local cluster, storing credentials in variables file is sufficient.*

Create resources defined in terraform:
```bash
terraform apply
```

Check external ip of the loadbalancer:
```bash
kubectl get svc
```
Output:
```bash
NAME            TYPE           CLUSTER-IP       EXTERNAL-IP    PORT(S)                       AGE
kubernetes      ClusterIP      10.96.0.1        <none>         443/TCP                       10h
postgresql      ClusterIP      10.108.226.157   <none>         5432/TCP                      8m48s
postgresql-hl   ClusterIP      None             <none>         5432/TCP                      8m48s
sonarqube       LoadBalancer   10.101.3.113     10.101.3.113   80:30761/TCP,9001:30083/TCP   8m28s
```
Connect to the ip in browser:
`http://REPLACE_WITH_EXTERNAL_IP:80`

`http://10.101.3.113:80`

