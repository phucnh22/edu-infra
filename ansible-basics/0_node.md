## To run the project:

#### In AWS:
- Create an Elastic IP in AWS > VPC services > Elastic IPs
- Create a SSH key pair in AWS > EC2 services > Key pair -> Save the private key (file_name.pem) in your local machine

#### In your local development machine:
- Install Ansibles in ubuntu
```
$ sudo apt-get update
$ sudo apt-get install software-properties-common
$ sudo apt-add-repository ppa:ansible/ansible
$ sudo apt-get update
$ sudo apt-get install ansible -y
```
- Copy the SSH key to ansible folder
```
cp /mnt/C/Users/Admin/.ssh/phuc-edu.pem /home/phucnh22/edu-infra/ansible-basics/ghost-blog/ansible/ssh_keys/phuc-edu.pem
```

#### In `/terraform` folder:
- Fill in the prod.tfvars (or staging if you so prefer)
  - Edit the necessary variables to suit with your AWS set up
- Execute `terraform init`
- Execute `terraform plan -var-file=prod.tfvars` to verify changes
- Execute `terraform apply -var-file=prod.tfvars` to apply to AWS

#### In `/ansible` folder:
- Fill in the ansible variables found in ansible/group_vars/all
- Write your application ansible role by filling in ansible/roles/application. The current contents are an example of setting up a ghost blog and serving
it behind an nginx reverse proxy
- Fill in any ssh public keys for admins in the ansible/ssh_keys/authorized_keys
- Fill in the ip address of the host (refering to the elastic IP you generated) in the ansible/hosts

#### Workflow
1. Run initial setup
- Running the setup_instance role
```
ansible-playbook -i hosts machine-initial-setup.yml
```
  - Update apt for Ubuntu
  - Install packages: [htop, git]
  - Add ssh_keys

- Running the nginx roles to install nginx and certificate
```
ansible-playbook -i hosts install-nginx-and-certs.yml
```


# 1. Ansibles
#### Used modules:
- `apt`: Manages apt packages (Ubuntu)
(https://docs.ansible.com/ansible/latest/collections/ansible/builtin/apt_module.html)
  - `dist-upgrade`: performs an apt-get dist-upgrade
  - `cache_valid_time`: 3600 => run if the last one is more than 3600 seconds aws_db_subnet_group
  - `pkg`: A list of package names to install
- `blockinfile`:  insert/update/remove a block of multi-line text surrounded by customizable marker lines
  - `block`: The text to insert inside the marker lines
  - `dest/path`: The file to modify
