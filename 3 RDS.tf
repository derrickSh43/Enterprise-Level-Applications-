resource "aws_rds_cluster" "blog-backend" {
  cluster_identifier      = "aurora-cluster-demo"
  engine                  = "aurora-mysql"
  engine_version          = "5.7.mysql_aurora.2.03.2"
  availability_zones      = ["us-east-1a", "us-east-1b", "us-east-1c"]
  database_name           = "blogdb"
  master_username         = "foo"
  master_password         = "foobarhoe"
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
}

resource "aws_db_parameter_group" "education" {
  name   = "education"
  family = "postgres14"

  parameter {
    name  = "log_connections"
    value = "1"
  }
}
