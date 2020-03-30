resource "aws_kinesis_firehose_delivery_stream" "firehose_stream" {

  name        = var.stream-name
  destination = "s3"

  s3_configuration {
    role_arn   		=  aws_iam_role.firehose_role.arn
    bucket_arn 		=  aws_s3_bucket.bucket.arn
    buffer_size         =  var.buffer_size
    buffer_interval     =  var.buffer_interval

    cloudwatch_logging_options {
        enabled         = true
        log_group_name  = aws_cloudwatch_log_group.cloudwatch_logging_group.name
        log_stream_name = aws_cloudwatch_log_stream.cloudwatch_logging_stream.name
      }
    }
}

resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket
  acl    = "private"
}


resource "aws_iam_role" "firehose_role" {
  name = "firehose_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
resource "aws_iam_policy" "firehose-policy" {
  name = "firehose-delivery-policy"
  description = "Kinesis Firehose delivery policy"
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": [
                "${aws_s3_bucket.bucket.arn}",
                "${aws_s3_bucket.bucket.arn}/*"
            ]
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:${var.log-group}/%FIREHOSE_STREAM_NAME%:log-stream:*"
            ]
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "kinesis:DescribeStream",
                "kinesis:GetShardIterator",
                "kinesis:GetRecords"
            ],
            "Resource": "arn:aws:kinesis:${var.region}:${data.aws_caller_identity.current.account_id}:stream/%FIREHOSE_STREAM_NAME%"
        }
    ]
}
POLICY
}


resource "aws_iam_role_policy_attachment" "attach_delivery_policy" {
  role       = aws_iam_role.firehose_role.name
  policy_arn = aws_iam_policy.firehose-policy.arn
}
