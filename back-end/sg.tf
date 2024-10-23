# Security Group para o Elastic Beanstalk
resource "aws_security_group" "beanstalk_sg" {
  name        = "${var.backend_app}-sg-${terraform.workspace}"
  description = "Security Group for Elastic Beanstalk Environment"
  vpc_id      = var.vpc_id  # Referência à VPC do seu módulo

  # Regra de entrada para HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP inbound traffic"
  }

  # Regra de entrada para HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS inbound traffic"
  }

  # Regra de saída - permite todo tráfego de saída
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "${var.backend_app}-sg-${terraform.workspace}"
    Environment = terraform.workspace
  }
}