variable "app_image" {
  description = "Docker image to run in the ECS cluster"
  default     = "495637283141.dkr.ecr.ca-central-1.amazonaws.com/nexus:latest"
}
variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "4096"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "12288"
}