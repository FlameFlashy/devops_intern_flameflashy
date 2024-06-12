variable "frontend_image" {
  description = "The Docker image for the front-end container"
  default     = "637423237571.dkr.ecr.eu-central-1.amazonaws.com/flameflashy-intern:fe_devops"
}

variable "app_image" {
  description = "The Docker image for the back-end container"
  default     = "637423237571.dkr.ecr.eu-central-1.amazonaws.com/flameflashy-intern:be_devops"
}

variable "db_user" {
  description = "Database username"
  default     = "intern_user"
}

variable "db_password" {
  description = "Database password"
  default     = "intern_12321fds"
}

variable "db_name" {
  description = "Database name"
  default     = "intern_db"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

