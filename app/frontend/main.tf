provider "aws" {
  region = var.aws_region 
}

# Cria o bucket S3
resource "aws_s3_bucket" "frontend_bucket" {
  bucket = var.bucket_name
  # acl = "private"

  tags = {
    Name        = var.bucket_name
    Environment = "Production"
  }
}


# Bloqueia o acesso público, isto aparentemente é uma boa prática, porque devo expor via cloudfront
resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket = aws_s3_bucket.frontend_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

### --------------------------------
### Integrar com CloudFront 
### --------------------------------
# Cria a Origin Access Identity (OAI) para CloudFront
# permite com que o CloudFront aceda ao bucket S3, que é privado
resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI para frontend"
}

# Política do S3 para permitir CloudFront
resource "aws_s3_bucket_policy" "cloudfront_access" {
  bucket = aws_s3_bucket.frontend_bucket.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"
        Principal = {
          CanonicalUser = aws_cloudfront_origin_access_identity.oai.s3_canonical_user_id # ID para o OAI
        }
        Action   = "s3:GetObject" # Só para leitura
        Resource = "${aws_s3_bucket.frontend_bucket.arn}/*" # acesso a todos os objetos no bucket
      }
    ]
  })
}

# CloudFront Distribution. É o que serve o conteúdo do S3
resource "aws_cloudfront_distribution" "frontend_distribution" {
  enabled             = true
  default_root_object = "index.html"
  price_class         = "PriceClass_100" # Usa só as regiões mais baratas

  # Define a origem do S3
  origin {
    domain_name = aws_s3_bucket.frontend_bucket.bucket_regional_domain_name
    origin_id   = "S3-${var.bucket_name}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  # Define o comportamento padrão do cache
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-${var.bucket_name}"
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  # Tratamento de erros para SPA
  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html" # em caso de erro 404 vai para o index (não quero criar outro html)
  }

  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html" # a mesma coisa  aqui mas para o erro 403
  }

  # Tirar todas as restrições geográficas
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # Configuração do certificado SSL para ser HTTPS
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name        = "${var.bucket_name}-distribution"
    Environment = "Production"
  }
}

### ----------------------------------
### Upload dos ficheiros
### ----------------------------------

# Upload do ficheiro HTML
resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.frontend_bucket.id
  key          = "index.html"
  source       = "./src/index.html"
  content_type = "text/html"
  etag         = filemd5("./src/index.html") # isto garante atualizações caso o ficheiro mude
}

# Upload do ficheiro CSS
resource "aws_s3_object" "styles_css" {
  bucket       = aws_s3_bucket.frontend_bucket.id
  key          = "styles.css"
  source       = "./src/styles.css"
  content_type = "text/css"
  etag         = filemd5("./src/styles.css")
}

# Upload do ficheiro JS
resource "aws_s3_object" "index_js" {
  bucket       = aws_s3_bucket.frontend_bucket.id
  key          = "index.js"
  source       = "./src/index.js"
  content_type = "application/javascript"
  etag         = filemd5("./src/index.js")
}


### Outputs (úteis para saber o url do site)
output "cloudfront_url" {
  value       = aws_cloudfront_distribution.frontend_distribution.domain_name
  description = "URL do CloudFront para aceder ao site"
}

output "cloudfront_distribution_id" {
  value       = aws_cloudfront_distribution.frontend_distribution.id
  description = "ID da distribuição CloudFront (útil para invalidações)"
}