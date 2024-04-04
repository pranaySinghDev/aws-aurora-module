locals {
  extract_resource_name = lower("${var.common_name_prefix}-${var.environment}")
}


resource "aws_db_subnet_group" "db-subnet-group" {
  name       = "${local.extract_resource_name}-db-subnet-group"
  subnet_ids = [var.subnet-db-a-id, var.subnet-db-b-id]

  tags = merge(
    {
      "Name" = format("%s", "${local.extract_resource_name}-db-subnet-group")
    },
    {
      environment = var.environment
    },
    var.tags,
  )
}

resource "random_password" "password_postgres" {
  length  = 16
  special = false
}
resource "aws_db_parameter_group" "rds_parameter_group" {
  name   = "rds-parameter-group"
  family = "postgres16"  # For example, "mysql5.7" for MySQL 5.7, "postgres13" for PostgreSQL 13, etc.
  description = "Custom parameter group for RDS"

  parameter {
    name  = "rds.force_ssl"
    value = "0"
    apply_method = "immediate"  # Can be "immediate" or "pending-reboot"
  }

  # Include any tags here
  tags = {
    Name = "rds-parameter-group"
  }
}


resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier      = "${local.extract_resource_name}-cluster"
  engine                  = "aurora-postgresql"
  engine_version          = "12.9" # or any other compatible version
  availability_zones      = ["us-east-1a", "us-east-1b", "us-east-1c"]
  database_name           = "postgres"
  master_username         = "postgres"
  master_password         = random_password.password_postgres.result
  backup_retention_period = 7
  preferred_backup_window = "20:00-21:00"
  preferred_maintenance_window = "Sat:23:00-Sun:03:00"
  vpc_security_group_ids  = [var.db-sg-id, aws_security_group.rds_ec2.id, aws_security_group.rds_ec2_worker_node.id]
  db_subnet_group_name    = aws_db_subnet_group.db-subnet-group.name
  storage_encrypted       = true
  deletion_protection     = true
  skip_final_snapshot     = var.environment == "prod" || var.environment == "production" ? false : true
  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]

  tags = merge(
    {
      "Name" = format("%s", "${local.extract_resource_name}-cluster")
    },
    {
      environment = var.environment
    },
    var.tags,
  )
}

resource "aws_rds_cluster_instance" "aurora_instance" {
  count                  = 1 # Adjust the count if you need more instances
  identifier             = "${local.extract_resource_name}-instance-${count.index}"
  cluster_identifier     = aws_rds_cluster.aurora_cluster.id
  instance_class         = "db.r5.large" # Adjust the instance class as needed
  engine                 = aws_rds_cluster.aurora_cluster.engine
  engine_version         = aws_rds_cluster.aurora_cluster.engine_version
  publicly_accessible    = false
  performance_insights_enabled = true
  monitoring_interval    = var.environment == "prod" || var.environment == "production" ? 60 : 0

  tags = merge(
    {
      "Name" = format("%s", "${local.extract_resource_name}-instance-${count.index}")
    },
    {
      environment = var.environment
    },
    var.tags,
  )
}

resource "aws_security_group" "ec2_rds" {
  name   = "ec2-rds"
  vpc_id = var.vpc_id

  tags = {
    Name = "ec2-rds"
  }
}

resource "aws_security_group" "rds_ec2" {
  name   = "rds-ec2"
  vpc_id = var.vpc_id

  tags = {
    Name = "rds-ec2"
  }
}

resource "aws_security_group" "rds_ec2_worker_node" {
  name   = "rds-ec2"
  vpc_id = var.vpc_id

  tags = {
    Name = "rds-ec2"
  }
}

resource "aws_security_group_rule" "ec2_to_rds" {
  type              = "egress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  security_group_id = aws_security_group.ec2_rds.id
  source_security_group_id = aws_security_group.rds_ec2.id
}

resource "aws_security_group_rule" "rds_to_ec2" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds_ec2.id
  source_security_group_id = aws_security_group.ec2_rds.id
}

resource "aws_security_group_rule" "rds_to_ec2_worker_node" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds_ec2_worker_node.id
  source_security_group_id = var.worker_node_sg
}



