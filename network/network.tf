# VPC for the application
resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr
  tags = {
    Name = "VPC-${var.app}-${var.environment}"
  }
}

#Public subnets for the external/public facing load balancer
resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_cidr_blocks)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_cidr_blocks[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "SN-PUBLIC-${var.app}-${var.environment}-0${count.index + 1}"
  }
}

#Private subnets for the internal load balancer and application instances
resource "aws_subnet" "public_subnets" {
  count                   = length(var.private_cidr_blocks)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_cidr_blocks[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "SN-PRIVATE-${var.app}-${var.environment}-0${count.index + 1}"
  }
}

#Security Group for External Load Balancer
resource "aws_security_group" "sgp_external_lb" {
  name        = "SGP-EXTERNAL-LB-${var.app}-${var.environment}"
  description = "Security Group for External Load Balancer"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description     = "HTTP from anywhere"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description     = "HTTP from anywhere"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SGP-EXTERNAL-LB-${var.app}-${var.environment}"
  }
}

#Security Group for Internal Load Balancer
resource "aws_security_group" "sgp_internal_lb" {
  name        = "SGP-INTERNAL-LB-${var.app}-${var.environment}"
  description = "Security Group for Internal Load Balancer"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description     = "HTTP from frontend instances"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.sgp_frontend_instances.id]
  }

  ingress {
    description     = "HTTPS from frontend instances"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.sgp_frontend_instances.id]
  }
  egress {
    description     = "HTTP to backend instances"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.sgp_backend_instances.id]
  }
  egress {
    description     = "HTTPS to backend instances"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.sgp_backend_instances.id]
  }

  tags = {
    Name = "SGP-INTERNAL-LB-${var.app}-${var.environment}"
  }
}

#Seccurity Group for frontend instances
resource "aws_security_group" "sgp_frontend_instances" {
  name        = "SGP-FRONTEND-INSTANCES-${var.app}-${var.environment}"
  description = "Security Group for Frontend Instances"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description     = "HTTP from external load balancer"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.sgp_external_lb.id]
  }

  ingress {
    description     = "HTTPS from external load balancer"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.sgp_external_lb.id]
  }
  egress {
    description     = "HTTP to internal load balancer"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.sgp_internal_lb.id]
  }
  egress {
    description     = "HTTPS to internal load balancer"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.sgp_internal_lb.id]
  }

  tags = {
    Name = "SGP-FRONTEND-INSTANCES-${var.app}-${var.environment}"
  }
}

#Security Group for backend instances
resource "aws_security_group" "sgp_backend_instances" {
  name        = "SGP-BACKEND-INSTANCES-${var.app}-${var.environment}"
  description = "Security Group for Backend Instances"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description     = "HTTP from internal load balancer"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.sgp_internal_lb.id]
  }

  ingress {
    description     = "HTTPS from internal load balancer"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.sgp_internal_lb.id]
  }
  egress {
    description     = "Allow connection to database"
    from_port       = -1
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.sgp_database.id]
  }

  tags = {
    Name = "SGP-BACKEND-INSTANCES-${var.app}-${var.environment}"
  }
}

#Security Group for Database
resource "aws_security_group" "sgp_database" {
  name        = "SGP-DATABASE-${var.app}-${var.environment}"
  description = "Security Group for Database Instance"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description     = "HTTP from internal load balancer"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.sgp_internal_lb.id]
  }

  ingress {
    description     = "HTTPS from internal load balancer"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.sgp_internal_lb.id]
  }
  egress {
    description     = "Allow connection to database"
    from_port       = -1
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.sgp_database.id]
  }

  tags = {
    Name = "SGP-BACKEND-INSTANCES-${var.app}-${var.environment}"
  }
}