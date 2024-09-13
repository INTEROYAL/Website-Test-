resource "aws_s3_bucket" "bucket" {
  bucket        = "testttting838980"
  force_destroy = true
}

resource "aws_s3_bucket_website_configuration" "site" {
  bucket = aws_s3_bucket.bucket.id

  index_document {
    suffix = "index7latest.html"
  }

  # ... other configurations ...
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

resource "aws_s3_object" "upload_html" {
  for_each     = fileset("${path.module}/", "*.html")
  bucket       = aws_s3_bucket.bucket.id
  key          = each.value
  source       = "${path.module}/${each.value}"
  etag         = filemd5("${path.module}/${each.value}")
  content_type = "text/html"
}

resource "aws_s3_object" "upload_images" {
  for_each     = fileset("${path.module}/", "*.png")
  bucket       = aws_s3_bucket.bucket.id
  key          = each.value
  source       = "${path.module}/${each.value}"
  etag         = filemd5("${path.module}/${each.value}")
  content_type = "image/png"
}

resource "aws_s3_object" "upload_videos" {
  for_each     = fileset("${path.module}/", "*.mp4")
  bucket       = aws_s3_bucket.bucket.id
  key          = each.value
  source       = "${path.module}/${each.value}"
  etag         = filemd5("${path.module}/${each.value}")
  content_type = "video/mp4"
}
