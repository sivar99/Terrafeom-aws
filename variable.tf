data "aws_caller_identity" "current" {}

variable "region" { 
  type	  	= string
  default 	= "us-west-2" 
  description	= "Region-Name"
} 
variable "bucket" { 
  type		= string
  default 	= "export-logs-2021" 
  description 	= "Bucket-Name"
}
variable "buffer_size" { 
  type	  	= string
  default 	= 5 
  description	= "Bucket_buffer_size"
} 
variable "buffer_interval" { 
  type		= string
  default 	= 60 
  description 	= "Bucket_buffer_interval"
}
variable "log-group" { 
  type		= string
  default 	= "/aws/lambda/generate_fake_data"
  description 	= "log-group-nmae"
}
variable "log-stream" { 
  type		= string
  default 	= "log-stream"
  description 	= "log-stream-nmae"
}
variable "stream-name" { 
  type		= string
  default 	= "cloudwatch-to-kinesis"
  description 	= "kinesis-stream-nmae"
}
variable "function-name" { 
  type		= string
  default 	= "generate_fake_data"
  description 	= "lambda-function-nmae"
}
variable "function-version" { 
  type		= string
  default 	= "3.7"
  description 	= "lambda_version"
}
