# External load balancer
resource "aws_lb" "alb_external" {
  name               = "ALB-PUBLIC-${var.app}-${var.environment}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_groups_external_lb
  subnets            = var.sn_public
  enable_deletion_protection = false
  tags = {
    Name = "ALB-PUBLIC-${var.app}-${var.environment}"
  }
}

#HTTP listener for External Load Balancer
resource "aws_lb_listener" "listener_external_lb" {
  load_balancer_arn = aws_lb.alb_external.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_external_lb_80.arn
  }
}

#Target Group for External load balancer
resource "aws_lb_target_group" "tg_external_lb_80" {
  name     = "TG-EXTERNAL-LB-${var.app}-${var.environment}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

# Internal load balancer
resource "aws_lb" "alb_internal" {
  name               = "ALB-PRIVATE-${var.app}-${var.environment}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_groups_internal_lb
  subnets            = var.sn_private
  enable_deletion_protection = false
  tags = {
    Name = "ALB-PRIVATE-${var.app}-${var.environment}"
  }
}

#HTTP listener for Internal Load Balancer
resource "aws_lb_listener" "listener_internal_lb" {
  load_balancer_arn = aws_lb.alb_internal.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_internal_lb_80.arn
  }
}

#Target Group for Internal load balancer
resource "aws_lb_target_group" "tg_internal_lb_80" {
  name     = "TG-INTERNAL-LB-${var.app}-${var.environment}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

#Get latest al2 image
data "aws_ami" "amazon_linux_2" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

#Launch template for front end instances
resource "aws_launch_template" "lt_frontend" {
  name = "LT-FRONTEND-${var.app}-${var.environment}"
  block_device_mappings {
    device_name = "/dev/sdf"
    ebs {
      volume_size = var.frontend_storage
    }
  }
  instance_type = var.frontend_instance_type
  image_id      = data.aws_ami.amazon_linux_2.id
  network_interfaces {
    associate_public_ip_address = false
    security_groups             = var.security_groups_frontend_instances
  }
  user_data = base64encode(templatefile("${path.module}/../scripts/userdata_frontend.sh", {
    lb_internal = aws_lb.alb_internal.dns_name
  }))
  depends_on = [ aws_lb.alb_external ]
}

#Launch template for backend instances
resource "aws_launch_template" "lt_backend" {
  name = "LT-BACKEND-${var.app}-${var.environment}"
  block_device_mappings {
    device_name = "/dev/sdf"
    ebs {
      volume_size = var.backend_storage
    }
  }
  instance_type = var.backend_instance_type
  image_id      = data.aws_ami.amazon_linux_2.id
  network_interfaces {
    associate_public_ip_address = false
    security_groups             = var.security_groups_backend_instances
  }
  user_data = base64encode(templatefile("${path.module}/../scripts/userdata_backend.sh", {
    host     = var.db_host
    user     = var.db_user
    password = var.db_password
    db       = var.database
  }))
  depends_on = [ aws_lb.alb_internal ]
}

#Auto Scaling Group for frontend instances
resource "aws_autoscaling_group" "asg_frontend" {
  name                      = "ASG-FRONTEND-${var.app}-${var.environment}"
  max_size                  = var.max_frontend_instances
  min_size                  = var.min_frontend_instances
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = var.desired_frontend_capacity
  vpc_zone_identifier       = var.sn_private

  launch_template {
    id      = aws_launch_template.lt_frontend.id
    version = "$Latest"
  }

  lifecycle {
    ignore_changes = [load_balancers, target_group_arns]
  }
}

#Auto Scaling Group for backend instances
resource "aws_autoscaling_group" "asg_backend" {
  name                      = "ASG-BACKEND-${var.app}-${var.environment}"
  max_size                  = var.max_backend_instances
  min_size                  = var.min_backend_instances
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = var.desired_backend_capacity
  vpc_zone_identifier       = var.sn_private

  launch_template {
    id      = aws_launch_template.lt_backend.id
    version = "$Latest"
  }

  lifecycle {
    ignore_changes = [load_balancers, target_group_arns]
  }
}

#Attachment to Target Group frontend
resource "aws_autoscaling_attachment" "tga_external" {
  autoscaling_group_name = aws_autoscaling_group.asg_frontend.id
  lb_target_group_arn    = aws_lb_target_group.tg_external_lb_80.arn
}

#Attachment to Target Group backend
resource "aws_autoscaling_attachment" "tga_internal" {
  autoscaling_group_name = aws_autoscaling_group.asg_backend.id
  lb_target_group_arn    = aws_lb_target_group.tg_internal_lb_80.arn
}