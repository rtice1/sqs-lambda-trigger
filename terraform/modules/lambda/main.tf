provider "aws" {
  region = "us-east-2"
}

locals {
  app_name = var.app_name
  lambda_handler = {
    basic = "basic.lambda_handler",
    sqs-send = "sqs-send.lambda_handler",
    sqs-rec = "sqs-rec.lambda_handler"
  }
  lambda_filename = {
    basic = "basic.zip",
    sqs-send = "sqs-send.zip",
    sqs-rec = "sqs-rec.zip"
  }
  lambda_variables = merge(
    {
      APP_NAME = local.app_name
    },
    var.architecture == "basic" ? null : {
      QUEUE_URL = aws_sqs_queue.queue[0].id
    }
  )
}

# Basic lambda
resource "aws_lambda_function" "lambda_function" {
  function_name = local.app_name
  role          = aws_iam_role.lambda.arn
  handler       = local.lambda_handler[var.architecture]
  runtime       = var.runtime
  filename      = local.lambda_filename[var.architecture]
  environment {
    variables = local.lambda_variables
  }
}

resource "aws_iam_role" "lambda" {
  name  = "lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com",
        },
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "lambda" {
  count      = var.architecture == "basic" ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda.name
}

# SQS

resource "aws_sqs_queue" "queue" {
  count = contains(["sqs-rec", "sqs-send"], var.architecture) ? 1 : 0 
  name  = local.app_name
}

# Architecture: sqs-send

resource "aws_iam_policy" "sqs_policy_send" {
  count       = var.architecture == "sqs-send" ? 1 : 0
  name        = "sqs_policy_send"
  description = "policy for SQS permissions"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "sqs:SendMessage",
        Effect   = "Allow",
        Resource = aws_sqs_queue.queue[count.index].arn
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "sqs_policy_send" {
  count      = var.architecture == "sqs-send" ? 1 : 0
  policy_arn = aws_iam_policy.sqs_policy_send[count.index].arn
  role       = aws_iam_role.lambda.name
}

# Architecture: sqs-rec
resource "aws_iam_policy" "sqs_policy_rec" {
  count       = var.architecture == "sqs-rec" ? 1 : 0
  name        = "sqs_policy_rec"
  description = "Policy for SQS permissions"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "sqs:ReceiveMessage",
        Effect   = "Allow",
        Resource = aws_sqs_queue.queue[count.index].arn
      },
      {
        Action   = "sqs:DeleteMessage",
        Effect   = "Allow",
        Resource = aws_sqs_queue.queue[count.index].arn
      },
    ],
  })
}


resource "aws_iam_role_policy_attachment" "sqs_policy_rec" {
  count       = var.architecture == "sqs-rec" ? 1 : 0
  policy_arn = aws_iam_policy.sqs_policy_rec[count.index].arn
  role       = aws_iam_role.lambda.name
}
