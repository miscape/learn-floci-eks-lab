# 04 - EKS access and Kubernetes RBAC

## Obiettivo

Il laboratorio originale usa una IAM access entry per accedere al cluster EKS.

In questo laboratorio locale con Floci, le vere EKS access entries non sono implementate. Per questo motivo il modello viene sostituito con:

- kubeconfig admin creato tramite `aws eks update-kubeconfig`
- ServiceAccount Kubernetes limitata
- Role namespaced
- RoleBinding
- kubeconfig dedicato per l'identità limitata

## Identità create

Namespace:

```bash
dev-team
```