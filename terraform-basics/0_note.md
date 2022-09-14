
#### Requirements:
- Ports 80, 443, and 22 are open to the world. All else are closed.
- The ec2 machine has access to the postgres RDS. The RDS is not publicly available.

How to test:
- SSH to the EC2 instance remotely through 1 of the ports [80, 443, 22]
- Access to the postgres RDS intance through the EC2 instance

#### Desired architecture:
![image](https://miro.medium.com/max/700/1*Oxp7FZT4Z9RWqpnJn-hHqw.png)
Reference: https://medium.com/strategio/using-terraform-to-create-aws-vpc-ec2-and-rds-instances-c7f3aa416133
## 1. Create IAM User
Reference:
- https://www.devopshint.com/how-to-create-iam-user-in-aws-step-by-step/
- https://registry.terraform.io/providers/hashicorp/aws/latest/docs

Get your AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY at **IAM services** in AWS Console

For Windows user using WSL2:
1. Leave aws resource as empty:
`provider "aws" {}`
1. Set environment variables:
```
$ export AWS_ACCESS_KEY_ID="accesskey"
$ export AWS_SECRET_ACCESS_KEY="secretkey"
$ export AWS_REGION="us-west-2"
$ terraform plan
```

## 2. Create VPC in AWS

#### Key concepts:
##### Reference:
- https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html
- https://romandc.com/zappa-django-guide/aws_network_primer/
- https://linuxhint.com/create-aws-vpc-using-terraform/
- https://medium.com/@aliatakan/terraform-create-a-vpc-subnets-and-more-6ef43f0bf4c1


![Infrastructure](https://linuxhint.com/wp-content/uploads/2022/06/image1-44.png)

##### VPC
- Virtual Private Cloud or VPC is the boundary of your networks that isolates it from the Internet
- The private network spaces for IPv4 are:
  - 10.0.0.0 - 10.255.255.255 (10/8 prefix)
  - 172.16.0.0 - 172.31.255.255 (172.16/12 prefix)
  - 192.168.0.0 - 192.168.255.255 (192.168/16 prefix)

##### Subnets
 - Subnets are the smaller isolations within the VPC that allows users to create different chunks
 - Benefit: functionality and security
 - Example: web application servers in a public subnet and database servers in a private subnet
 - Notable:
   - The size of the subnets must be a power of 2
   - The subnets must be contiguous

##### Route tables
- Define communication between Subnets and within themselves

##### IGW - Internet Gateway
- Used to connect your VPC to the Internet in AWS

##### EIP - Elastic IP
- An Elastic IP address is a static, public IPv4 address designed for dynamic cloud computing. You can associate an Elastic IP address with any instance or network interface in any VPC in your account. With an Elastic IP address, you can mask the failure of an instance by rapidly remapping the address to another instance in your VPC.

##### NAT gateways
  - A NAT gateway is a Network Address Translation (NAT) service. You can use a NAT gateway so that instances in a private subnet can connect to services outside your VPC but external services cannot initiate a connection with those instances.
  - Creates a NAT Gateway to enable private subnets to reach out to the internet without needing an externally routable IP address assigned to each resource.

##### CIDR
- CIDR (Classless Inter-Domain Routing) -- also known as supernetting -- is a method of assigning Internet Protocol (IP) addresses that improves the efficiency of address distribution and replaces the previous system based on Class A, Class B and Class C networks.

##### Used variables:
- shared_credentials_file: It is the path of the file containing the credentials of the AWS users.
- profile: It specifies the user’s profile to be used for working with AWS.
- aws_vpc: Resource for building a VPC.
- cidr_block: Provides an IPv4 CIDR block for the VPC.
 -aws_internet_gateway: Resource for creating an internet gateway for the VPC.
- aws_eip: Resource for producing an Elastic IP (EIP).
- aws_nat_gateway: Resource for creating a NAT gateway for the VPC.
- Allocation_id: Attribute for allocation id of the above-generated EIP.
- subnet_id: Attribute for subnet id of the subnet where NAT gateway is deployed.
- aws_subnet: Resource for creating a VPC subnet.
- aws_route_table: Resource for creating a VPC route table.
- route: Argument that contains a list of route objects.
- nat_gateway_id: Argument denoting the ID of the VPC NAT gateway.
- gateway_id: Optional argument for VPC internet gateway.
- aws_route_table_association: Resource for creating an association between route table (public or private) and 1) internet gateway and 2) virtual private gateway.
- route_table_id: The route table ID with which we are associating the subnet.


# 3. Create EC2 instance:

Reference:
- https://medium.com/@aliatakan/terraform-create-a-vpc-subnets-and-more-6ef43f0bf4c1
- https://adamtheautomator.com/terraform-windows/
- https://www.techtarget.com/searchcloudcomputing/tip/How-to-launch-an-EC2-instance-using-Terraform
- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
- https://medium.com/strategio/using-terraform-to-create-aws-vpc-ec2-and-rds-instances-c7f3aa416133

Generate key pair:
```
ssh-keygen -t rsa -b 4096 -m pem -f _file_name_ && openssl rsa -in _file_name_ -outform pem && chmod 400 _file_name_
```
ssh-keygen -t rsa -b 4096 -m pem -f phuc_edu && openssl rsa -in phuc_edu -outform pem && chmod 400 phuc_edu

SSH to the instance:
```
 ssh -i "aws_server" ubuntu@ec2-13-41-211-7.eu-west-2.compute.amazonaws.com
```
Install package
```
sudo apt update &&
sudo apt-get install postgresql-client
```
# 4. Create an RDS instance

Reference:
- https://learn.hashicorp.com/tutorials/terraform/aws-rds?in=terraform/aws
- https://github.com/joelparkerhenderson/demo-terraform-aws/blob/master/aws_db_instance.tf

Connect to RDS db
```
psql -h db_end_point -p 5432 -U user_name db_name -W
----
psql -h terraform-20220912213721523400000001.ckdgfnbbqfx6.eu-west-2.rds.amazonaws.com -p 5432 -U edu_phuc_db postgres_db -W
```

# 5. Move everything to remote state
https://learn.hashicorp.com/tutorials/terraform/aws-remote?in=terraform/aws-get-started
