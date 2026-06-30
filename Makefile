.PHONY: help check up down logs ps env aws-test smoke clean ec2-key ec2-run ec2-list cfn-validate cfn-create cfn-status cfn-events cfn-resources cfn-delete eks-describe eks-kubeconfig k8s-nodes rbac-apply rbac-kubeconfig rbac-test rbac-clean cleanup reset

help:
	@echo "Available targets:"
	@echo "  make check     - Check local tools"
	@echo "  make up        - Start Floci"
	@echo "  make down      - Stop Floci"
	@echo "  make logs      - Show Floci logs"
	@echo "  make ps        - Show running containers"
	@echo "  make aws-test  - Test AWS CLI against Floci using STS"
	@echo "  make smoke     - Run a simple S3 smoke test"
	@echo "  make ec2-key   - Create/import local SSH key pair into Floci EC2"
	@echo "  make ec2-run   - Launch a local EC2-like container"
	@echo "  make ec2-list  - List EC2-like instances"
	@echo "  make clean     - Stop Floci and remove local runtime data"

check:
	./scripts/check-tools.sh

up:
	docker compose up -d

down:
	docker compose down

logs:
	docker compose logs -f floci

ps:
	docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"

aws-test:
	./scripts/aws-local.sh sts get-caller-identity

smoke:
	./scripts/aws-local.sh s3 mb s3://floci-lab-bucket || true
	echo "hello floci" | ./scripts/aws-local.sh s3 cp - s3://floci-lab-bucket/hello.txt
	./scripts/aws-local.sh s3 ls s3://floci-lab-bucket

ec2-key:
	mkdir -p ssh
	test -f ssh/floci-lab-key || ssh-keygen -t ed25519 -f ssh/floci-lab-key -N ""
	./scripts/aws-local.sh ec2 import-key-pair \
		--key-name floci-lab-key \
		--public-key-material fileb://ssh/floci-lab-key.pub || true

ec2-run:
	./scripts/aws-local.sh ec2 run-instances \
		--image-id ami-amazonlinux2023 \
		--instance-type t2.micro \
		--count 1 \
		--key-name floci-lab-key

ec2-list:
	./scripts/aws-local.sh ec2 describe-instances \
		--query "Reservations[].Instances[].{InstanceId:InstanceId,State:State.Name,ImageId:ImageId,PublicIp:PublicIpAddress,PrivateIp:PrivateIpAddress}" \
		--output table

cfn-validate:
	./scripts/aws-local.sh cloudformation validate-template \
		--template-body file://cloudformation/eks-cluster.yaml

cfn-create:
	./scripts/aws-local.sh cloudformation create-stack \
		--stack-name floci-eks-lab-stack \
		--template-body file://cloudformation/eks-cluster.yaml \
		--capabilities CAPABILITY_NAMED_IAM

cfn-status:
	./scripts/aws-local.sh cloudformation describe-stacks \
		--stack-name floci-eks-lab-stack \
		--query "Stacks[].{StackName:StackName,Status:StackStatus,CreationTime:CreationTime,Outputs:Outputs}" \
		--output table

cfn-events:
	./scripts/aws-local.sh cloudformation describe-stack-events \
		--stack-name floci-eks-lab-stack \
		--query "StackEvents[].{Time:Timestamp,LogicalId:LogicalResourceId,Type:ResourceType,Status:ResourceStatus,Reason:ResourceStatusReason}" \
		--output table

cfn-resources:
	./scripts/aws-local.sh cloudformation describe-stack-resources \
		--stack-name floci-eks-lab-stack \
		--query "StackResources[].{LogicalId:LogicalResourceId,Type:ResourceType,PhysicalId:PhysicalResourceId,Status:ResourceStatus}" \
		--output table

cfn-delete:
	./scripts/aws-local.sh cloudformation delete-stack \
		--stack-name floci-eks-lab-stack

eks-describe:
	./scripts/aws-local.sh eks describe-cluster \
		--name floci-eks-lab \
		--query "cluster.{Name:name,Status:status,Endpoint:endpoint,Arn:arn,Version:version}" \
		--output table

eks-kubeconfig:
	./scripts/aws-local.sh eks update-kubeconfig \
		--name floci-eks-lab \
		--region us-east-1 \
		--alias floci-eks-lab

k8s-nodes:
	. ./scripts/env.sh >/dev/null && kubectl get nodes -o wide

rbac-apply:
	kubectl apply -f k8s/rbac/dev-team-rbac.yaml

rbac-kubeconfig:
	./scripts/create-dev-kubeconfig.sh

rbac-test:
	./scripts/rbac-test.sh

rbac-clean:
	kubectl delete namespace dev-team --ignore-not-found=true
	rm -f .kube/devops-user.kubeconfig

clean:
	docker compose down -v
	rm -rf data

cleanup:
	./scripts/cleanup-lab.sh

reset:
	./scripts/cleanup-lab.sh
	rm -rf data