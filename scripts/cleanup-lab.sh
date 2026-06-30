#!/usr/bin/env bash
set -euo pipefail

echo "Starting lab cleanup..."

echo
echo "[1/6] Deleting Kubernetes demo resources..."
kubectl delete namespace demo --ignore-not-found=true || true
kubectl delete namespace dev-team --ignore-not-found=true || true

echo
echo "[2/6] Removing generated kubeconfig..."
rm -f .kube/devops-user.kubeconfig

echo
echo "[3/6] Terminating EC2-like instances..."
INSTANCE_IDS="$(./scripts/aws-local.sh ec2 describe-instances \
  --query "Reservations[].Instances[?State.Name!='terminated'].InstanceId" \
  --output text 2>/dev/null || true)"

if [[ -n "${INSTANCE_IDS}" ]]; then
  ./scripts/aws-local.sh ec2 terminate-instances --instance-ids ${INSTANCE_IDS} || true
else
  echo "No running/stopped EC2-like instances found."
fi

echo
echo "[4/6] Deleting CloudFormation stack..."
./scripts/aws-local.sh cloudformation delete-stack \
  --stack-name floci-eks-lab-stack 2>/dev/null || true

echo
echo "[5/6] Stopping Floci containers..."
docker compose down || true

echo
echo "[6/6] Optional runtime data cleanup skipped."
echo "Runtime data directory './data' was kept."
echo "To remove it manually: rm -rf data"

echo
echo "Cleanup completed."
