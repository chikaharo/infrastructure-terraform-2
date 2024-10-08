resource "aws_route53_zone" "main" {
  name = var.domain_name
}

resource "aws_route53_record" "frontend" {  
  zone_id = aws_route53_zone.main.zone_id  
  name    = var.domain_name  
  type    = var.dns_type
  
  alias {  
    name                   = var.cloudfront_domain_name  
    zone_id                = var.cloudfront_hosted_zone_id  
    evaluate_target_health = false  
  }  
  lifecycle {  
    create_before_destroy = true  
  }  

}

resource "aws_acm_certificate" "cert-my-domain" {
  domain_name       = var.domain_name
  validation_method = "DNS"
    subject_alternative_names = ["www.${var.domain_name}", "${var.domain_name}"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "cert-validation" {
  certificate_arn         = aws_acm_certificate.cert-my-domain.arn
  validation_record_fqdns = [for record in aws_route53_record.cert-validation-record : record.fqdn]
}


resource "aws_route53_record" "cert-validation-record" {
  for_each = {
    for dvo in aws_acm_certificate.cert-my-domain.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.main.zone_id
}
