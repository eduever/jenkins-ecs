# Terraform cmds
terraform init
terraform plan
terraform apply --auto-approve

# Ansible cmds

ansible-playbook -i hosts bootstrap.yml --key-file ~/.ssh/id_rsa
ansible-playbook -i hosts terraform.yml --key-file ~/.ssh/id_rsa
ansible-playbook -i hosts jenkins.yml --key-file ~/.ssh/id_rsa

# Docker commands
docker build -t app:v5 .
docker run --name test -p 8080:8080 -d app:v5
docker logs -t test
docker stop ddf853d2c49c

# AWS ECR LOGIN & PUSH

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 175546642044.dkr.ecr.us-east-1.amazonaws.com/myapp-ecr-repo

docker build -t myapp-ecr-repo:v1 .
docker tag myapp-ecr-repo:v1 175546642044.dkr.ecr.us-east-1.amazonaws.com/myapp-ecr-repo:v1
docker push 175546642044.dkr.ecr.us-east-1.amazonaws.com/myapp-ecr-repo:v1

aws ecs register-task-definition --family myapp-task --network-mode awsvpc --requires-compatibilities FARGATE --execution-role-arn arn:aws:iam::175546642044:role/myEcsTaskExecutionRole --cpu 1024 --memory 2048 --cli-input-json file:///Users/rbhar1/self/self-github/jenkins-ecs/task-definition.json
aws ecs update-service --cluster myapp-cluster --service myapp-service --task-definition myapp-task --force-new-deployment
