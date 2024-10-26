provider "aws" {
  region  = var.aws_region
  profile = var.profile
}

### Role
resource "aws_iam_role" "beanstalk_ec2_role" {
  name = "aws-elasticbeanstalk-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "beanstalk_web_tier" {
  role       = aws_iam_role.beanstalk_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

resource "aws_iam_role_policy_attachment" "beanstalk_multicontainer" {
  role       = aws_iam_role.beanstalk_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker"
}

resource "aws_iam_role_policy_attachment" "beanstalk_worker_tier" {
  role       = aws_iam_role.beanstalk_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier"
}

resource "aws_iam_instance_profile" "beanstalk_instance_profile" {
  name  = "aws-elasticbeanstalk-ec2-role"
  role  = aws_iam_role.beanstalk_ec2_role.name
  count = 1
}

data "aws_elastic_beanstalk_hosted_zone" "current" {}

data "aws_elastic_beanstalk_solution_stack" "php_latest" {
  most_recent = true
  name_regex = "^64bit Amazon Linux (.*) running PHP 8.2$"
}

# Create Launch Template
resource "aws_launch_template" "beanstalk_launch_template" {
  name_prefix   = "${var.backend_app}-lt-"
  instance_type = "t4g.large"

  iam_instance_profile {
    name = aws_iam_instance_profile.beanstalk_instance_profile[0].name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups            = [aws_security_group.beanstalk_sg.id]
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.backend_app}-instance"
      Environment = terraform.workspace
    }
  }
}

resource "aws_elastic_beanstalk_application" "backend_app" {
  name = "${var.backend_app}-app-${terraform.workspace}"
}

resource "aws_elastic_beanstalk_environment" "backend_env" {
  depends_on = [
    aws_security_group.beanstalk_sg,
    aws_launch_template.beanstalk_launch_template
  ]

  wait_for_ready_timeout = "60m"
  name                   = "${var.backend_app}-env-${terraform.workspace}"
  application            = aws_elastic_beanstalk_application.backend_app.name
  solution_stack_name    = data.aws_elastic_beanstalk_solution_stack.php_latest.name
  tier                  = "WebServer"

  # VPC Configuration
  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = var.vpc_id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", [var.subnet_id1, var.subnet_id2])
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "AssociatePublicIpAddress"
    value     = "true"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBScheme"
    value     = "public"
  }

  # Launch Template Configuration
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "LaunchTemplateId"
    value     = aws_launch_template.beanstalk_launch_template.id
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "LaunchTemplateVersion"
    value     = aws_launch_template.beanstalk_launch_template.latest_version
  }

  # Auto Scaling Configuration
  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = "1"
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = "2"
  }
}

resource "aws_s3_bucket" "backend_bucket" {
  bucket = "${var.backend_app}-source"
}

resource "aws_s3_bucket_policy" "backend_bucket_policy" {
  bucket = aws_s3_bucket.backend_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowElasticBeanstalkServiceAccess"
        Effect    = "Allow"
        Principal = {
          Service = [
            "elasticbeanstalk.amazonaws.com",
            "elasticloadbalancing.amazonaws.com"
          ]
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "${aws_s3_bucket.backend_bucket.arn}",
          "${aws_s3_bucket.backend_bucket.arn}/*"
        ]
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = "796973515412"
          }
        }
      }
    ]
  })
}

