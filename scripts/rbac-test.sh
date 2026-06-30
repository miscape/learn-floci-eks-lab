#!/usr/bin/env bash
set -euo pipefail

KUBECONFIG_PATH="${KUBECONFIG_PATH:-.kube/devops-user.kubeconfig}"

if [[ ! -f "${KUBECONFIG_PATH}" ]]; then
  echo "Missing kubeconfig: ${KUBECONFIG_PATH}"
  echo "Run: ./scripts/create-dev-kubeconfig.sh"
  exit 1
fi

echo "Current identity:"
KUBECONFIG="${KUBECONFIG_PATH}" kubectl config current-context

echo
echo "Allowed checks:"
echo -n "Can list pods in dev-team? "
KUBECONFIG="${KUBECONFIG_PATH}" kubectl auth can-i list pods -n dev-team

echo -n "Can create deployments in dev-team? "
KUBECONFIG="${KUBECONFIG_PATH}" kubectl auth can-i create deployments -n dev-team

echo
echo "Denied checks:"
echo -n "Can list pods in default? "
KUBECONFIG="${KUBECONFIG_PATH}" kubectl auth can-i list pods -n default

echo -n "Can get nodes? "
KUBECONFIG="${KUBECONFIG_PATH}" kubectl auth can-i get nodes

echo
echo "Trying allowed deployment apply:"
KUBECONFIG="${KUBECONFIG_PATH}" kubectl create deployment nginx-rbac \
  --image=nginx:alpine \
  --dry-run=client \
  -o yaml | KUBECONFIG="${KUBECONFIG_PATH}" kubectl apply -f -

echo
echo "Resources in dev-team:"
KUBECONFIG="${KUBECONFIG_PATH}" kubectl get deployments,pods

echo
echo "Trying forbidden cluster-scope command:"
set +e
KUBECONFIG="${KUBECONFIG_PATH}" kubectl get nodes
set -e

echo
echo "RBAC test completed."
