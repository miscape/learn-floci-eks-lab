#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-dev-team}"
SERVICE_ACCOUNT="${SERVICE_ACCOUNT:-devops-user}"
KUBECONFIG_PATH="${KUBECONFIG_PATH:-.kube/devops-user.kubeconfig}"
TOKEN_DURATION="${TOKEN_DURATION:-24h}"

mkdir -p "$(dirname "${KUBECONFIG_PATH}")"

SERVER="$(kubectl config view --minify --raw -o jsonpath='{.clusters[0].cluster.server}')"
CA_DATA="$(kubectl config view --minify --raw -o jsonpath='{.clusters[0].cluster.certificate-authority-data}')"

TOKEN="$(kubectl -n "${NAMESPACE}" create token "${SERVICE_ACCOUNT}" --duration="${TOKEN_DURATION}")"

cat > "${KUBECONFIG_PATH}" <<KUBECONFIG
apiVersion: v1
kind: Config
clusters:
  - name: floci-eks-lab
    cluster:
      server: ${SERVER}
      certificate-authority-data: ${CA_DATA}
users:
  - name: ${SERVICE_ACCOUNT}
    user:
      token: ${TOKEN}
contexts:
  - name: ${SERVICE_ACCOUNT}@floci-eks-lab
    context:
      cluster: floci-eks-lab
      user: ${SERVICE_ACCOUNT}
      namespace: ${NAMESPACE}
current-context: ${SERVICE_ACCOUNT}@floci-eks-lab
KUBECONFIG

chmod 600 "${KUBECONFIG_PATH}"

echo "Created kubeconfig: ${KUBECONFIG_PATH}"
echo
echo "Test with:"
echo "KUBECONFIG=${KUBECONFIG_PATH} kubectl get pods"
