# Terraform cmds
terraform init
terraform plan
terraform apply --auto-approve

# Ansible cmds

ansible-playbook -i hosts bootstrap.yml --key-file ~/.ssh/id_rsa
ansible-playbook -i hosts terraform.yml --key-file ~/.ssh/id_rsa
ansible-playbook -i hosts jenkins.yml --key-file ~/.ssh/id_rsa
