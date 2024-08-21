output "bastion_instance" {
  value = aws_instance.ec2-bastion-host
}
output "public_ip" {
   description = "Public instance IP"
   value       = aws_instance.ec2-bastion-host.public_ip
 }

 output "private_ip" {
   description = "Private instance IP"
   value       = aws_instance.ec2-bastion-host.private_ip
 }