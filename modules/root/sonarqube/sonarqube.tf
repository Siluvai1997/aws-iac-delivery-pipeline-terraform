# Security Groups
# Create a security group for SonarQube elastic load balancer
resource "aws_security_group" "sonarqube_elb_sg" {

  name = "sonar-elb-sg"
  vpc_id  = "vpc-0853f07c56d69c3fc"

  ingress {
    from_port       = 9000
    to_port         = 9000
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

# Create a security group for Database
resource "aws_security_group" "sonarqube_db_sg" {

  name = "sonar-db-sg"
  vpc_id  = "vpc-0853f07c56d69c3fc"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp" # FIXME figure out what the correct port is
    #security_groups = ["${aws_security_group.sonarqube_ecs_instance_sg.id}"]
    cidr_blocks     = ["0.0.0.0/0"]
  }

}

# Create a security group for ECS instance
/*
resource "aws_security_group" "sonarqube_ecs_instance_sg" {

  name = "sonarqube-ecs-instance-sg"
  vpc_id  = "vpc-0853f07c56d69c3fc"

  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    security_groups = ["${aws_security_group.sonarqube_elb_sg.id}"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

}
*/

### Database instance
resource "aws_db_subnet_group" "sonarqube_db_subnet" {
  name       = "sonar-subnet-grp"
  subnet_ids = ["subnet-01e4577b6b1f4e06d","subnet-0e499c24278b14da1"]

  tags = {
    Name = "My DB subnet group"
  }
}

# Create a database instance
resource "aws_db_instance" "sonarqube_db" {
  allocated_storage               = var.allocated_storage
  engine                          = "postgres"
  engine_version                  = var.engine_version
  identifier                      = "sonarqubepostgres"
  instance_class                  = var.instance_type
  storage_type                    = var.storage_type
  iops                            = var.iops
  name                            = "sonarqubepostgres"
  password                        = "sonariets"
  username                        = "sonariets"
  final_snapshot_identifier       = var.final_snapshot_identifier
  skip_final_snapshot             = var.skip_final_snapshot
  port                            = var.database_port
  vpc_security_group_ids          = ["${aws_security_group.sonarqube_db_sg.id}"]
  db_subnet_group_name            = "sonar-subnet-grp"
  parameter_group_name            = var.parameter_group
  storage_encrypted               = var.storage_encrypted
  deletion_protection             = var.deletion_protection
  enabled_cloudwatch_logs_exports = var.cloudwatch_logs_exports
}


## Load Balancer Configuration
# Create a load balancer 
resource "aws_lb" "sonarqube_loadbalancer" {

  name               = "sonar-alb"
  internal           = true
  load_balancer_type = "application"
  subnets            = ["subnet-01e4577b6b1f4e06d","subnet-0e499c24278b14da1"]
  enable_deletion_protection = false
  #availability_zones = "${var.zones[var.region]}"

  security_groups = ["${aws_security_group.sonarqube_elb_sg.id}"]
}

# Create a Target group
resource "aws_lb_target_group" "sonarqube_targetgroup" {
  name        = "sonar-ecs-targetgroup"
  port        = 9000
  protocol    = "HTTP"
  vpc_id      = "vpc-0853f07c56d69c3fc"
  target_type = "ip"
}

# Create a listener for Application Load Balancer
resource "aws_lb_listener" "sonarqube_listener" {
    load_balancer_arn = aws_lb.sonarqube_loadbalancer.arn
    port     = "9000"
    protocol = "HTTP"

    default_action {
    target_group_arn =  aws_lb_target_group.sonarqube_targetgroup.id
    type             = "forward"
  }
}

### ECS Configuration
# Create ECS cluster 
resource "aws_ecs_cluster" "sonarqube_ecs_cluster" {

  name = "sonar-ecs-cluster"
  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

# Create Task definition for ECS
resource "aws_ecs_task_definition" "sonarqube_web" {

  family                   = "sonarqube-web"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  task_role_arn            = aws_iam_role.sonarqube_ecs.arn
  execution_role_arn       = aws_iam_role.sonarqube_ecs.arn
  

  container_definitions = <<DEFINITION
[
  {
    "essential": true,
    "image": "495637283141.dkr.ecr.ca-central-1.amazonaws.com/sonarqube:latest",
    "name": "sonarqube",
    "portMappings": [
      { 
        "hostPort": 9000,
        "containerPort": 9000,
        "protocol": "tcp"
      }
    ],
    "environment": [ 
      {
        "name": "SONARQUBE_JDBC_USERNAME",
        "value": "sonariets"
      },
      { 
        "name": "SONARQUBE_JDBC_PASSWORD",
        "value": "sonariets"
      },
      {
        "name": "SONARQUBE_JDBC_URL",
        "value": "jdbc:postgresql://${aws_db_instance.sonarqube_db.endpoint}/sonarqubepostgres"
      }
    ],
    "command": [
        "-Dsonar.search.javaAdditionalOpts=-Dnode.store.allow_mmapfs=false"
    ],
    "ulimits": [
    {
    "name": "nofile",
    "softLimit": 65535,
    "hardLimit": 65535
    }
   ],
   "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
            "awslogs-group": "ecs-sonar",
            "awslogs-region": "ca-central-1",
            "awslogs-stream-prefix": "ecs"
          }
    }
  }
]
DEFINITION

}


# Create ECS service
resource "aws_ecs_service" "sonarqube_service" {

  name            = "sonar-ecs-service"
  task_definition = aws_ecs_task_definition.sonarqube_web.arn
  cluster         = aws_ecs_cluster.sonarqube_ecs_cluster.id
  desired_count   = 1
  launch_type     = "FARGATE"

  #iam_role        = aws_iam_role.sonarqube_ecs.arn # required for elb

  network_configuration {
    security_groups = ["${aws_security_group.sonarqube_elb_sg.id}"]
    subnets         = ["subnet-01e4577b6b1f4e06d","subnet-0e499c24278b14da1"]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.sonarqube_targetgroup.arn
    container_name = "sonarqube"
    container_port = "9000"
  }

}


# IAM Configuration
# AmazonEC2ContainerServiceforEC2Role
resource "aws_iam_role" "sonarqube_ecs" {

  name = "sonar-ecs"

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
resource "aws_iam_role_policy_attachment" "sonarqube_ecs_service" {
  policy_arn  = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role        = aws_iam_role.sonarqube_ecs.name
}

resource "aws_iam_role_policy_attachment" "sonarqube_ecs_elb" {
  role        = aws_iam_role.sonarqube_ecs.name
  policy_arn  = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}


resource "aws_iam_role_policy_attachment" "sonarqube_ecs_full" {
  role        = aws_iam_role.sonarqube_ecs.name
  policy_arn  = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}