provider "aws" {
  region                  = "eu-west-1"
  profile                 = "default"
}


resource "aws_s3_bucket" "foo-medopad" {
  bucket = "${var.s3-bucket}"
  acl    = "private"

  tags {
    Name = "foo-medopad"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}






resource "aws_dynamodb_table" "medopad-dynamodb-table" {
  name           = "Timestamp"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "object_name"
  range_key      = "deleted_at"

  attribute {
    name = "object_name"
    type = "S"
  }

  attribute {
    name = "deleted_at"
    type = "S"
  }


  ttl {
    attribute_name = "TimeToExist"
    enabled        = false
  }


  tags = {
    Name        = "dynamodb-table-1"
    Environment = "sandbox"
  }
}

output "arn" { value = "${aws_dynamodb_table.medopad-dynamodb-table.arn}"}


# ROLES
# IAM role which dictates what other AWS services the Lambda function
# may access.
resource "aws_iam_role" "lambda-iam-role" {
  name = "lambda_iam_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}





# POLICIES
resource "aws_iam_role_policy" "dynamodb-lambda-policy"{
  name = "dynamodb_lambda_policy"
  role = "${aws_iam_role.lambda-iam-role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:*"
      ],
      "Resource": "${aws_dynamodb_table.medopad-dynamodb-table.arn}"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cloudwatch-lambda-policy-python"{
  name = "cloudwatch-lambda-policy"
  role = "${aws_iam_role.lambda-iam-role.id}"
  policy = "${data.aws_iam_policy_document.api-gateway-logs-policy-document-python.json}"
}

data "aws_iam_policy_document" "api-gateway-logs-policy-document-python" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents"
    ],
    resources = [
      "arn:aws:logs:*:*:*"
    ]
  }
}


