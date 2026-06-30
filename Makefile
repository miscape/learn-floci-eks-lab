.PHONY: help check up down logs ps env aws-test smoke clean ec2-key ec2-run ec2-list

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

clean:
	docker compose down -v
	rm -rf data
