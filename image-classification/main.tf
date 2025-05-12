provider "aws" {
  region = var.aws_region
}

################################################################################
#  Create S3 buckets
################################################################################

resource "aws_s3_bucket" "xray" {
  bucket = var.xray_bucket
}

resource "aws_s3_bucket" "ctscan" {
  bucket = var.ctscan_bucket
}

resource "aws_s3_bucket" "general" {
  bucket = var.general_bucket
}


resource "aws_s3_bucket" "source_bucket" {
  bucket = var.source_bucket  #  

 
}
################################################################################
# Lambda execution role
################################################################################

resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "rekognition_access" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRekognitionFullAccess"
}

resource "aws_iam_role_policy_attachment" "s3_access" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

################################################################################
#  Create Lambda function using the created buckets and S3 ARN for Lambda code
################################################################################

resource "aws_lambda_function" "image_classifier" {
  function_name = "imageClassifier"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"

  ################################################################################
  # Using ARN for the S3 bucket and key as variables
  ################################################################################


  s3_bucket = var.lambda_code_s3_bucket
  s3_key    = var.lambda_code_s3_key

  environment {
    variables = {
      XRAY_BUCKET      = aws_s3_bucket.xray.bucket
      CTSCAN_BUCKET    = aws_s3_bucket.ctscan.bucket
      GENERAL_BUCKET   = aws_s3_bucket.general.bucket
      CONFIDENCE_LEVEL = var.confidence_level
    }
  }

  publish = true
}

################################################################################
#  S3 Bucket Notification to trigger Lambda function on ObjectCreated (Put) event
################################################################################

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.source_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.image_classifier.arn
    events              = ["s3:ObjectCreated:*"]
    
  }

  depends_on = [aws_lambda_function.image_classifier,aws_lambda_permission.allow_bucket]
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.image_classifier.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.source_bucket.arn
}