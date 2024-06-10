provider "aws" {
  region = var.region
}

# S3 Backend for Terraform State
terraform {
  backend "s3" {
    bucket  = "my-terraform-state-bucket-flameflashy"
    key     = "ecs-cluster/terraform.tfstate"
    region  = "eu-central-1"
    encrypt = true
  }
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    name = "main"
  }
}

resource "aws_subnet" "main" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  map_public_ip_on_launch = true
  availability_zone       = element(["eu-central-1a", "eu-central-1b"], count.index)
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "main" {
  count          = 2
  subnet_id      = aws_subnet.main[count.index].id
  route_table_id = aws_route_table.main.id
}

# IAM Role for ECS
resource "aws_iam_role" "ecs_task_execution" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs.amazonaws.com"
        }
      },
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecr.amazonaws.com"
        }
      },
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "fargate.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_ecr_access" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecsInstanceProfile"
  role = aws_iam_role.ecs_task_execution.name
}

resource "aws_security_group" "main" {
  name        = "ecs-sg"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "allow_internal_communication" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.main.id
  source_security_group_id = aws_security_group.main.id
  description              = "Allow internal communication within the security group"
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "terraform-ecs-cluster-flameflashy"
}

# Launch Configuration for Auto Scaling Group
resource "aws_launch_configuration" "main" {
  name                 = "ecs-launch-configuration"
  image_id             = "ami-026c3177c9bd54288" # Amazon ECS-Optimized AMI
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.ecs_instance_profile.name

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "main" {
  launch_configuration = aws_launch_configuration.main.id
  min_size             = 1
  max_size             = 2
  desired_capacity     = 1
  vpc_zone_identifier  = [aws_subnet.main[0].id, aws_subnet.main[1].id]

  tag {
    key                 = "Name"
    value               = "ECS Instance"
    propagate_at_launch = true
  }

  enabled_metrics = ["GroupInServiceInstances", "GroupDesiredCapacity"]

  protect_from_scale_in = true
}

# ECS Capacity Provider
resource "aws_ecs_capacity_provider" "main" {
  name = "capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.main.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      maximum_scaling_step_size = 2
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 100
    }
  }
}

#ECS Task Definition for Frontend and Backend
resource "aws_ecs_task_definition" "main" {
  family                   = "ecs-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name  = "frontend"
      image = var.frontend_image
      portMappings = [
        {
          containerPort = 4200
          hostPort      = 4200
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/frontend"
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    },
    {
      name  = "app"
      image = var.app_image
      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
        }
      ]
      environment = [
        {
          name  = "DB_USER"
          value = var.db_user
        },
        {
          name  = "DB_PASSWORD"
          value = var.db_password
        },
        {
          name  = "DB_ENDPOINT"
          value = aws_db_instance.database.endpoint
        },
        {
          name  = "DB_NAME"
          value = var.db_name
        },
        {
          name  = "POSTGRES_HOST_AUTH_METHOD"
          value = "trust"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/app"
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

# ECS Service
resource "aws_ecs_service" "main" {
  name            = "ecs-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = [aws_subnet.main[0].id, aws_subnet.main[1].id]
    security_groups  = [aws_security_group.main.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend.arn
    container_name   = "frontend"
    container_port   = 4200
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "app"
    container_port   = 8000
  }
}

# ALB
resource "aws_lb" "main" {
  name               = "ecs-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.main.id]
  subnets            = [aws_subnet.main[0].id, aws_subnet.main[1].id]
}

resource "aws_lb_target_group" "frontend" {
  name        = "frontend"
  port        = 4200
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    interval            = 30
    path                = "/"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-299"
  }
}

resource "aws_lb_target_group" "app" {
  name        = "app"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    interval            = 30
    path                = "/api/*"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-299"
  }
}

# Listener for frontend
resource "aws_lb_listener" "frontend" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

# Listener rule for backend path
resource "aws_lb_listener_rule" "app" {
  listener_arn = aws_lb_listener.frontend.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}

resource "aws_security_group" "database" {
  name        = "database-sg"
  description = "Allow inbound traffic for database"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS PostgreSQL Database
resource "aws_db_instance" "database" {
  allocated_storage      = 10
  engine                 = "postgres"
  engine_version         = "12.15"
  instance_class         = "db.t3.micro"
  db_name                = var.db_name
  username               = var.db_user
  password               = var.db_password
  parameter_group_name   = "default.postgres12"
  skip_final_snapshot    = true
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.main.id]
  db_subnet_group_name   = aws_db_subnet_group.rds.name
}

resource "aws_db_subnet_group" "rds" {
  name       = "rds-subnet-group"
  subnet_ids = [aws_subnet.main[0].id, aws_subnet.main[1].id]

  tags = {
    Name = "rds-subnet-group"
  }
}

resource "aws_cloudwatch_log_group" "frontend" {
  name              = "/ecs/frontend"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/app"
  retention_in_days = 7
}
