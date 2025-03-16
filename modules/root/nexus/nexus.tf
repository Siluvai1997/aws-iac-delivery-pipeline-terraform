# Security Groups
# Create a security group for Nexus elastic load balancer
resource "aws_security_group" "nexus_elb_sg" {

  name = "sonatypenexus-elb-sg"
  vpc_id  = "vpc-0853f07c56d69c3fc"

  ingress {
    from_port       = 8081
    to_port         = 8081
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

}

## Load Balancer Configuration
# Create a load balancer 
resource "aws_lb" "nexus_loadbalancer" {

  name               = "sonatypenexus-alb"
  internal           = true
  load_balancer_type = "application"
  subnets            = ["subnet-01e4577b6b1f4e06d","subnet-0e499c24278b14da1"]
  enable_deletion_protection = false
  #availability_zones = "${var.zones[var.region]}"

  security_groups = ["${aws_security_group.nexus_elb_sg.id}"]
}

# Create a Target group
resource "aws_lb_target_group" "nexus_targetgroup" {
  name        = "sonatype-nexus-targetgroup"
  port        = 8081
  protocol    = "HTTP"
  vpc_id      = "vpc-0853f07c56d69c3fc"
  target_type = "ip"
}

# Create a listener for Application Load Balancer
resource "aws_lb_listener" "nexus_listener" {
    load_balancer_arn = aws_lb.nexus_loadbalancer.arn
    port     = "8081"
    protocol = "HTTP"

    default_action {
    target_group_arn =  aws_lb_target_group.nexus_targetgroup.id
    type             = "forward"
  }
}

### ECS Configuration
# Create ECS cluster 
resource "aws_ecs_cluster" "nexus_ecs_cluster" {

  name = "sonatype-nexus-cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# Create Task definition for ECS
resource "aws_ecs_task_definition" "nexus_web" {

  family                   = "nexus-web"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  task_role_arn            = aws_iam_role.nexus_ecs.arn
  execution_role_arn       = aws_iam_role.nexus_ecs.arn
  

  container_definitions = <<DEFINITION
[
  {
    "essential": true,
    "image": "495637283141.dkr.ecr.ca-central-1.amazonaws.com/nexus:latest",
    "name": "nexus",
    "portMappings": [
      { 
        "hostPort": 8081,
        "containerPort": 8081,
        "protocol": "tcp"
      }
    ],
    "environment": [ 
      {
        "name": "NEXUS_SECURITY_RANDOMPASSWORD",
        "value": "false"
      },
      { 
        "name": "/etc/karaf/system.properties",
        "value": "storage.diskCache.diskFreeSpaceLimit=2703"
      },
      { 
        "name": "INSTALL4J_ADD_VM_PARAMS",
        "value": "-Dstorage.diskCache.diskFreeSpaceLimit=2703"
      },
      {
        "name": "-Dstorage.diskCache.diskFreeSpaceLimit",
        "value": "2703"
      }
    ],
    "ulimits": [
    {
    "name": "nofile",
    "softLimit": 65536,
    "hardLimit": 65536
    }
   ],
   "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
            "awslogs-group": "ecs-nexus-web-task",
            "awslogs-region": "ca-central-1",
            "awslogs-stream-prefix": "ecs"
          }
    }
  }
]
DEFINITION

}


# Create ECS service
resource "aws_ecs_service" "nexus_service" {

  name            = "sonatype-nexus-ecs"
  task_definition = aws_ecs_task_definition.nexus_web.arn
  cluster         = aws_ecs_cluster.nexus_ecs_cluster.id
  desired_count   = 1
  launch_type     = "FARGATE"

  #iam_role        = aws_iam_role.sonarqube_ecs.arn # required for elb

  network_configuration {
    security_groups = ["${aws_security_group.nexus_elb_sg.id}"]
    subnets         = ["subnet-01e4577b6b1f4e06d","subnet-0e499c24278b14da1"]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.nexus_targetgroup.arn
    container_name = "nexus"
    container_port = "8081"
  }
}


# IAM Configuration
# AmazonECSContainerServiceforRole
resource "aws_iam_role" "nexus_ecs" {

  name = "sonatypenexus-ecs"

  assume_role_policy = <<ROLE
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ecs.amazonaws.com", "ecs-tasks.amazonaws.com", "ec2.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
ROLE

}

# Attach policy to ECS service
resource "aws_iam_role_policy_attachment" "nexus_ecs_service" {
  policy_arn  = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role        = aws_iam_role.nexus_ecs.name
}

resource "aws_iam_role_policy_attachment" "nexus_ecs_full" {
  role        = aws_iam_role.nexus_ecs.name
  policy_arn  = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}
