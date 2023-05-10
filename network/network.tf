# VPC for the application
resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr
  tags = {
    Name = "VPC-${var.app}-${var.environment}"
  }
}

#Public subnets for the external/public facing load balancer
resource "aws_subnet" "sn_public" {
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
resource "aws_subnet" "sn_private" {
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

#   ingress {
#     description     = "HTTP from frontend instances"
#     from_port       = 80
#     to_port         = 80
#     protocol        = "tcp"
#     security_groups = [aws_security_group.sgp_frontend_instances.id]
#   }

#   ingress {
#     description     = "HTTPS from frontend instances"
#     from_port       = 443
#     to_port         = 443
#     protocol        = "tcp"
#     security_groups = [aws_security_group.sgp_frontend_instances.id]
#   }
#   egress {
#     description     = "HTTP to backend instances"
#     from_port       = 80
#     to_port         = 80
#     protocol        = "tcp"
#     security_groups = [aws_security_group.sgp_backend_instances.id]
#   }
#   egress {
#     description     = "HTTPS to backend instances"
#     from_port       = 443
#     to_port         = 443
#     protocol        = "tcp"
#     security_groups = [aws_security_group.sgp_backend_instances.id]
#   }

  tags = {
    Name = "SGP-INTERNAL-LB-${var.app}-${var.environment}"
  }
}

#Security group rules for internal load balancer

resource "aws_security_group_rule" "sgp_rule_internal_lb_inbound_80" {
    type = "ingress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_group_id = aws_security_group.sgp_internal_lb.id
    source_security_group_id = aws_security_group.sgp_frontend_instances.id
}

resource "aws_security_group_rule" "sgp_rule_internal_lb_inbound_443" {
    type = "ingress"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    security_group_id = aws_security_group.sgp_internal_lb.id
    source_security_group_id = aws_security_group.sgp_frontend_instances.id
}

resource "aws_security_group_rule" "sgp_rule_internal_lb_outbound_80" {
    type = "egress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_group_id = aws_security_group.sgp_internal_lb.id
    source_security_group_id = aws_security_group.sgp_backend_instances.id
}

resource "aws_security_group_rule" "sgp_rule_internal_lb_outbound_443" {
    type = "egress"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    security_group_id = aws_security_group.sgp_internal_lb.id
    source_security_group_id = aws_security_group.sgp_backend_instances.id
}

#Security Group for frontend instances
resource "aws_security_group" "sgp_frontend_instances" {
  name        = "SGP-FRONTEND-INSTANCES-${var.app}-${var.environment}"
  description = "Security Group for Frontend Instances"
  vpc_id      = aws_vpc.vpc.id

#   ingress {
#     description     = "HTTP from external load balancer"
#     from_port       = 80
#     to_port         = 80
#     protocol        = "tcp"
#     security_groups = [aws_security_group.sgp_external_lb.id]
#   }

#   ingress {
#     description     = "HTTPS from external load balancer"
#     from_port       = 443
#     to_port         = 443
#     protocol        = "tcp"
#     security_groups = [aws_security_group.sgp_external_lb.id]
#   }
#   egress {
#     description     = "HTTP to internal load balancer"
#     from_port       = 80
#     to_port         = 80
#     protocol        = "tcp"
#     security_groups = [aws_security_group.sgp_internal_lb.id]
#   }
#   egress {
#     description     = "HTTPS to internal load balancer"
#     from_port       = 443
#     to_port         = 443
#     protocol        = "tcp"
#     security_groups = [aws_security_group.sgp_internal_lb.id]
#   }

  tags = {
    Name = "SGP-FRONTEND-INSTANCES-${var.app}-${var.environment}"
  }
}

#Security group rules for frontend instance

resource "aws_security_group_rule" "sgp_rule_frontend_inbound_80" {
    type = "ingress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_group_id = aws_security_group.sgp_frontend_instances.id
    source_security_group_id = aws_security_group.sgp_external_lb.id
}

resource "aws_security_group_rule" "sgp_rule_frontend_inbound_443" {
    type = "ingress"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    security_group_id = aws_security_group.sgp_frontend_instances.id
    source_security_group_id = aws_security_group.sgp_external_lb.id
}

resource "aws_security_group_rule" "sgp_rule_frontend_outbound_80" {
    type = "egress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_group_id = aws_security_group.sgp_frontend_instances.id
    source_security_group_id = aws_security_group.sgp_internal_lb.id
}

resource "aws_security_group_rule" "sgp_rule_frontend_outbound_443" {
    type = "egress"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    security_group_id = aws_security_group.sgp_frontend_instances.id
    source_security_group_id = aws_security_group.sgp_internal_lb.id
}


#Security Group for backend instances
resource "aws_security_group" "sgp_backend_instances" {
  name        = "SGP-BACKEND-INSTANCES-${var.app}-${var.environment}"
  description = "Security Group for Backend Instances"
  vpc_id      = aws_vpc.vpc.id

#   ingress {
#     description     = "HTTP from internal load balancer"
#     from_port       = 80
#     to_port         = 80
#     protocol        = "tcp"
#     security_groups = [aws_security_group.sgp_internal_lb.id]
#   }

#   ingress {
#     description     = "HTTPS from internal load balancer"
#     from_port       = 443
#     to_port         = 443
#     protocol        = "tcp"
#     security_groups = [aws_security_group.sgp_internal_lb.id]
#   }
#   egress {
#     description     = "Allow connection to database"
#     from_port       = 0
#     to_port         = 3306
#     protocol        = "tcp"
#     security_groups = [aws_security_group.sgp_database.id]
#   }

  tags = {
    Name = "SGP-BACKEND-INSTANCES-${var.app}-${var.environment}"
  }
}


#Security group rules for backend instance

resource "aws_security_group_rule" "sgp_rule_backend_inbound_80" {
    type = "ingress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_group_id = aws_security_group.sgp_backend_instances.id
    source_security_group_id = aws_security_group.sgp_internal_lb.id
}

resource "aws_security_group_rule" "sgp_rule_backend_inbound_443" {
    type = "ingress"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    security_group_id = aws_security_group.sgp_backend_instances.id
    source_security_group_id = aws_security_group.sgp_internal_lb.id
}

resource "aws_security_group_rule" "sgp_rule_backend_outbound_80" {
    type = "egress"
    from_port = 0
    to_port = 3306
    protocol = "tcp"
    security_group_id = aws_security_group.sgp_backend_instances.id
    source_security_group_id = aws_security_group.sgp_database.id
}

#Security Group for Database
resource "aws_security_group" "sgp_database" {
  name        = "SGP-DATABASE-${var.app}-${var.environment}"
  description = "Security Group for Database Instance"
  vpc_id      = aws_vpc.vpc.id

#   ingress {
#     description     = "Allow connection from backend instances"
#     from_port       = 0
#     to_port         = 3306
#     protocol        = "tcp"
#     security_groups = [aws_security_group.sgp_backend_instances.id]
#   }

  tags = {
    Name = "SGP-DATABASE-${var.app}-${var.environment}"
  }
}

#Security group rule for database
resource "aws_security_group_rule" "sgp_rule_database_inbound_3306" {
    type = "ingress"
    from_port = 0
    to_port = 3306
    protocol = "tcp"
    security_group_id = aws_security_group.sgp_database.id
    source_security_group_id = aws_security_group.sgp_backend_instances.id
}



#Route Table for public subnets
resource "aws_route_table" "rtb_public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "RTB-PUBLIC-${var.app}-${var.environment}"
  }
}

#Route table association for public subnets
resource "aws_route_table_association" "rtb_asso_public" {
  count          = length(var.public_cidr_blocks)
  subnet_id      = aws_subnet.sn_public[count.index].id
  route_table_id = aws_route_table.rtb_public.id
}

#Route table for private subnets
resource "aws_route_table" "rtb_private" {
  count  = length(aws_subnet.sn_private)
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw[count.index].id
  }

  tags = {
    Name = "RTB-PRIVATE-${var.app}-${var.environment}-0${count.index + 1}"
  }
}

#Route table association for private subnets
resource "aws_route_table_association" "private-route" {
  count          = length(var.private_cidr_blocks)
  subnet_id      = aws_subnet.sn_private[count.index].id
  route_table_id = aws_route_table.rtb_private[count.index].id
}

#Elastic Ips for Nat Gateways
resource "aws_eip" "eip_nat" {
  count      = length(aws_subnet.sn_public)
  tags = {
    "Name" = "EIP-NAT-${var.app}-${var.environment}-0${count.index + 1}"
  }
}

#NAT Gateaway
resource "aws_nat_gateway" "ngw" {
  count         = length(aws_subnet.sn_public)
  allocation_id = aws_eip.eip_nat[count.index].id
  subnet_id     = aws_subnet.sn_public[count.index].id
  tags = {
    "Name" = "NGW-${var.app}-${var.environment}-0${count.index + 1}"
  }
}

#Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "IGW-${var.app}-${var.environment}"
  }
}