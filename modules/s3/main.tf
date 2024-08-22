resource "aws_s3_bucket" "frontend" {  
  bucket = var.s3_frontend_bucket 
}  

resource "aws_s3_bucket_public_access_block" "frontend_public_access_block" {  
  bucket = aws_s3_bucket.frontend.bucket  
  
    block_public_acls       = false  
    block_public_policy     = false  
    ignore_public_acls      = false  
    restrict_public_buckets = false  
}  

resource "aws_s3_bucket_website_configuration" "frontend_website" {  
  bucket = aws_s3_bucket.frontend.bucket  
  
  index_document {  
    suffix = "index.html"  
  }  
  
  error_document {  
    key = "index.html"  # for SPA
  }  
}  

resource "aws_s3_bucket_policy" "frontend_bucket_policy" {  
  bucket = aws_s3_bucket.frontend.bucket  
  policy = data.aws_iam_policy_document.allow_public_access_to_s3_bucket.json  
}  
  
data "aws_iam_policy_document" "allow_public_access_to_s3_bucket" {  
  statement {  
    actions   = ["s3:GetObject"]  
    resources = ["${aws_s3_bucket.frontend.arn}/*"]  
  
    principals {  
      type        = "AWS"  
      identifiers = ["*"]  
    }  
  }  
}

resource "aws_s3_bucket" "aurora" {
  bucket = var.s3_aurora_bucket
  acl    = "private"
}
