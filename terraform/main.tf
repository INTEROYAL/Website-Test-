provider "aws" {
  region = "us-east-2"  # Adjust to your preferred region
}

resource "aws_s3_bucket" "bucket" {
  bucket        = "testttting9878888"
  force_destroy = true
}

resource "aws_s3_bucket_website_configuration" "site" {
  bucket = aws_s3_bucket.bucket.id

  index_document {
    suffix = "index7latest.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket                   = aws_s3_bucket.bucket.id
  block_public_acls        = false
  block_public_policy      = false
  ignore_public_acls       = false
  restrict_public_buckets  = false
}

resource "aws_s3_bucket_policy" "site" {
  depends_on = [
    aws_s3_bucket.bucket,
    aws_s3_bucket_public_access_block.public_access_block,
  ]

  bucket = aws_s3_bucket.bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = ["${aws_s3_bucket.bucket.arn}/*"],
      },
    ]
  })
}

resource "aws_s3_object" "website_files" {
  for_each = fileset("${path.module}/../public", "*.*")

  bucket        = aws_s3_bucket.bucket.id
  key           = each.value
  source        = "${path.module}/../public/${each.value}"
  etag          = filemd5("${path.module}/../public/${each.value}")
  content_type  = lookup({
    ".html" = "text/html",
    ".css"  = "text/css",
    ".js"   = "application/javascript",
    ".png"  = "image/png",
    ".jpg"  = "image/jpeg",
    ".gif"  = "image/gif",
    ".mp4"  = "video/mp4",
    ".webm" = "video/webm",
  }, substr(each.value, length(each.value) - 4, 4), "application/octet-stream")
}
