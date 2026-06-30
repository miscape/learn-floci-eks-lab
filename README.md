# learn-floci-eks-lab

Laboratorio DevOps locale per simulare un workflow AWS/EKS senza account AWS e senza costi.

## Obiettivo

Questo progetto replica, in locale, i concetti di un laboratorio AWS basato su:

1. Launch and connect to an EC2 instance
2. Create a Kubernetes cluster
3. Monitor cluster creation with CloudFormation
4. Access the cluster using an IAM-style authentication flow

## Stack usato

- Git / GitHub
- Docker
- Docker Compose
- Floci
- AWS CLI
- CloudFormation template
- EKS-like cluster via Floci
- kubectl
- Kubernetes RBAC

## Nota

Floci emula servizi AWS localmente su `http://localhost:4566`.

Il supporto EKS di Floci usa k3s in modalità real mode. Le vere EKS access entries e access policies non sono ancora supportate; nel laboratorio verranno sostituite con autenticazione EKS-like e RBAC Kubernetes.

## Stato laboratorio

- [ ] Setup repository
- [ ] Avvio Floci
- [ ] Configurazione AWS CLI locale
- [ ] Creazione risorse via CloudFormation
- [ ] Creazione cluster EKS-like
- [ ] Accesso con kubectl
- [ ] RBAC Kubernetes

