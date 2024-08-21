output "s3_bucket_aurora" {
    value = aws_s3_bucket.aurora
}
output "s3_bucket_frontend" {
    value = aws_s3_bucket.frontend
}
output "frontend_website" {
    value = aws_s3_bucket_website_configuration.frontend_website
}