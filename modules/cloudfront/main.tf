module "acm" {  
  source  = "terraform-aws-modules/acm/aws"  
  version = "~> 4.0"  
  
  domain_name               = var.domain_name  
  create_route53_records    = true  
  zone_id                   = var.route53_zone_id  
  
  validation_method         = "DNS"  
  
  subject_alternative_names = ["*.${var.domain_name}"]  
  
  wait_for_validation       = true  
  
  tags = {
    Name = "${var.app_name}-acm"
    Environment = "${var.app_env}-acm"
  }
}

resource "aws_cloudfront_distribution" "frontend_distribution" {  
  enabled = true  
  aliases = [var.domain_name, "www.${var.domain_name}", "*.${var.domain_name}"]  
  
  viewer_certificate {  
    acm_certificate_arn      = var.acm_certificate_arn  
    ssl_support_method       = var.ssl_support_method 

  }  
  
  origin {  
    domain_name = var.frontend_endpoint  
    origin_id   = var.origin_id
  
    custom_origin_config {  
      http_port              = 80  
      https_port             = 443  
      origin_protocol_policy = var.origin_protocol_policy
      origin_ssl_protocols   = var.origin_ssl_protocols
    }  
  }  
  
  restrictions {  
    geo_restriction {  
      restriction_type = var.geo_restriction_type
    }  
  }  
  
  default_cache_behavior {  
    allowed_methods        = var.allowed_methods 
    cached_methods         = var.cached_methods
    target_origin_id       = var.origin_id
    viewer_protocol_policy = "redirect-to-https"  
  
    forwarded_values {  
      query_string = false  
  
      cookies {  
        forward = var.cookie_forward
      }  
    }  
  }  
}