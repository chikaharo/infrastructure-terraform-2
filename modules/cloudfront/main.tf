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
    ssl_support_method       = "sni-only"  

  }  
  
  origin {  
    domain_name = var.frontend_endpoint  
    origin_id   = var.origin_id
  
    custom_origin_config {  
      http_port              = 80  
      https_port             = 443  
      origin_protocol_policy = "http-only"  
      origin_ssl_protocols   = ["TLSv1.2"]  
    }  
  }  
  
  restrictions {  
    geo_restriction {  
      restriction_type = "none"  
    }  
  }  
  
  default_cache_behavior {  
    allowed_methods        = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]  
    cached_methods         = ["GET", "HEAD", "OPTIONS"]  
    target_origin_id       = var.origin_id
    viewer_protocol_policy = "redirect-to-https"  
  
    forwarded_values {  
      query_string = false  
  
      cookies {  
        forward = "none"  
      }  
    }  
  }  
}