/*
resource "aws_iam_role" "cloud-watch-role" {
  name = "CWLtoKinesisFirehoseRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "logs.${var.region}.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
} 

resource "aws_iam_policy" "cloudwatch-policy" {
     name      	 = "CWLtoKinesisFirehoseRolePolicy"
     path        = "/"
     description = " IAM policy for cloudwatch"
     policy = <<POLICY
     {
       "Statement":[
        {
         "Effect":"Allow",
         "Action":["firehose:*"],
         "Resource":["arn:aws:firehose:${var.region}:${data.aws_caller_identity.current.account_id}:*"]
        },
        {
        "Effect":"Allow",
        "Action":["iam:PassRole"],
        "Resource":["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/CWLtoKinesisFirehoseRole"]
        }
     ]
   }
 POLICY
}
*/

data "aws_iam_policy_document" "cloudwatch_logs_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["logs.${var.region}.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "cloudwatch_logs_assume_policy" {
  statement {
    effect    = "Allow"
    actions   = ["firehose:*"]
    resources = [aws_kinesis_firehose_delivery_stream.firehose_stream.arn]
  }
}

resource "aws_iam_role" "cloudwatch_logs_role" {
  name               = "cloudwatch_logs_role"
  assume_role_policy = data.aws_iam_policy_document.cloudwatch_logs_assume_role.json
}

resource "aws_iam_role_policy" "cloudwatch_logs_policy" {
  name   = "cloudwatch_logs_policy"
  role   = aws_iam_role.cloudwatch_logs_role.name
  policy = data.aws_iam_policy_document.cloudwatch_logs_assume_policy.json
}


resource "aws_cloudwatch_log_group" "cloudwatch_logging_group" {
  name = var.log-group
}
resource "aws_cloudwatch_log_stream" "cloudwatch_logging_stream" {
  log_group_name = aws_cloudwatch_log_group.cloudwatch_logging_group.name
  name           = "S3Delivery"
}
resource "aws_cloudwatch_log_subscription_filter" "cloudwatch-subscription" {
  name            = "CWLtoKinesisFirehose"
  role_arn        = aws_iam_role.cloudwatch_logs_role.arn
  log_group_name  = var.log-group
  filter_pattern  = "name"
  destination_arn = aws_kinesis_firehose_delivery_stream.firehose_stream.arn
  distribution    = "Random"
}
