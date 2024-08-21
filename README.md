# Infrastructure using Terraform

## Create VPC

- VPC: ap-norheast-1 (Tokyo)
- 3 subnets: 2 public, 1 private
- Route table
- NAT gateway with Elastic IP
- Internet gateway
  ![alt text](image-3.png)

## Create Bastion Host

### Generating SSH Key Pair

First we need to create the SSH Key Pair using following command:
`ssh-keygen -t rsa -C "you.email@example.com" -b 4096`
`chmod 600 path-to-repo/terraform-iac/aws/infrastructure/secrets/ec2-bastion-key-pair`

### Create ec2 instance for bastion host and elastic IP

![alt text](image.png)

### Security group to allow ssh port 22 from infra admin

![alt text](image-1.png)

### Bastion host ready

![alt text](image-2.png)
