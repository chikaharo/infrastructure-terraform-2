variable domain_name {
    default = "example.com"
}
variable origin_id {}
variable frontend_endpoint {}
variable route53_zone_id {}
variable acm_certificate_arn {}
variable app_name {}
variable app_env {}
variable allowed_methods {
    type = list(string)
}
variable cached_methods {
    type = list(string)
}
variable cookie_forward {
    default = "none"
}
variable ssl_support_method {
    default =  "sni-only" 
}
variable origin_protocol_policy {
    default =  "sni-only" 
}
variable geo_restriction_type {
    default = "none"
}
variable origin_ssl_protocols {
    type = list(string)
}