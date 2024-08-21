output "route53_zone_id" {
    value = aws_route53_zone.main.zone_id
}
# output "route53_cert-validation-record" {
#     value = aws_route53_zone.main.cert-validation-record
# }
output "aws_acm_certificate" {
    value = aws_acm_certificate.cert-my-domain
}