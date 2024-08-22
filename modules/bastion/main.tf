resource "aws_eip" "ec2-bastion-host-eip" {
    vpc = true
    tags = {
    Name = "${var.app_name}-bastion-host-eip"
    Environment = "${var.app_env}-bastion-host-eip"
  }
}

resource "aws_key_pair" "ec2-bastion-host-key-pair" {
  key_name = var.bastion_host_key_name
  public_key = file(var.ec2-bastion-public-key-path)
}
resource "aws_instance" "ec2-bastion-host" {
    ami = "ami-00c79d83cf718a893"
    instance_type = var.bastion_host_instance_type
    key_name = aws_key_pair.ec2-bastion-host-key-pair.key_name
    vpc_security_group_ids = [ var.bastion_sg_id ]
    subnet_id = var.subnet_id
    associate_public_ip_address = false
    # user_data                   = file(var.bastion-bootstrap-script-path)
    root_block_device {
      volume_size = 8
      delete_on_termination = true
      volume_type = "gp2"
      encrypted = true
      tags = {
        Name = "${var.app_name}-bastion-host-root-volume"
        Environment = "${var.app_env}-bastion-host-root-volume"
      }
    }
    credit_specification {
      cpu_credits = "standard"
    }
    tags = {
        Name = "${var.app_name}-bastion-host-instace"
        Environment = "${var.app_env}-bastion-host-instace"
    }
    lifecycle {
      ignore_changes = [ 
        associate_public_ip_address,
       ]
    }

    depends_on = [
      aws_key_pair.ec2-bastion-host-key-pair
    ]
}

resource "aws_eip_association" "ec2-bastion-host-eip-association" {
    instance_id = aws_instance.ec2-bastion-host.id
    allocation_id = aws_eip.ec2-bastion-host-eip.id
}
