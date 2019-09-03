provider "aws" {
    region = "${var.aws_region}"
}

# Cloudwatch event rule
resource "aws_cloudwatch_event_rule" "check-file-event" {
    name = "check-file-event"
    description = "check-file-event"
    schedule_expression = "cron(0 1 ? * * *)"
}

# Cloudwatch event target
resource "aws_cloudwatch_event_target" "check-file-event-lambda-target" {
    target_id = "check-file-event-lambda-target"
    rule = "${aws_cloudwatch_event_rule.check-file-event.name}"
    arn = "${aws_lambda_function.file_check_lambda.arn}"
    input = <<EOF
{
  "bucket": "my_bucket",
  "file_path": "the_path"
}
EOF
}

# IAM Role for Lambda function
resource "aws_iam_role" "file_check_lambda" {
    name = "file_check_lambda"
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

data "aws_iam_policy_document" "s3-access-ro" {
    statement {
        actions = [
               "s3:PutObject",
	        "s3:GetObject",
                "s3:DeleteObject",
	        "s3:ListBucket",
        ]
        resources = [
            "arn:aws:s3:::*",
        ]
    }
}

resource "aws_iam_policy" "s3-access-ro" {
    name = "s3-access-ro"
    path = "/"
    policy = "${data.aws_iam_policy_document.s3-access-ro.json}"
}

resource "aws_iam_role_policy_attachment" "s3-access-ro" {
    role       = "${aws_iam_role.file_check_lambda.name}"
    policy_arn = "${aws_iam_policy.s3-access-ro.arn}"
}

resource "aws_iam_role_policy_attachment" "basic-exec-role" {
    role       = "${aws_iam_role.file_check_lambda.name}"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# AWS Lambda function
resource "aws_lambda_function" "file_check_lambda" {
    filename = "file_check_lambda-64b3c683-45f7-48e8-988a-23beb8bb8a15.zip"
    function_name = "file_check_lambda"
    role = "${aws_iam_role.file_check_lambda.arn}"
    handler = "file_check_lambda-64b3c683-45f7-48e8-988a-23beb8bb8a15.handler"
    runtime = "python3.7"
    timeout = 10
    source_code_hash = "${base64sha256(file("file_check_lambda-64b3c683-45f7-48e8-988a-23beb8bb8a15.zip"))}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_file_check" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.file_check_lambda.function_name}"
    principal = "events.amazonaws.com"
    source_arn = "${aws_cloudwatch_event_rule.check-file-event.arn}"
}
