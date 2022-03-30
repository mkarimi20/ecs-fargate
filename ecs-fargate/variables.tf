# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
variable "name_prefix" {
  description = "A prefix used for naming resources."
  type        = string
}

variable "container_name" {
  description = "Optional name for the container to be used instead of name_prefix. Useful when when constructing an imagedefinitons.json file for continuous deployment using Codepipeline."
  default     = ""
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID."
  type        = string
}

variable "private_subnet_ids" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
}

variable "task_container_image" {
  description = "The image used to start a container."
  type        = string
}

variable "alb_arn" {
  default     = ""
  description = "Arn for the LB for which the service should be attach to."
  type        = string
}

variable "desired_count" {
  description = "The number of instances of the task definitions to place and keep running."
  default     = 1
  type        = number
}

variable "task_container_assign_public_ip" {
  description = "Assigned public IP to the container."
  default     = false
  type        = bool
}

variable "task_container_port" {
  description = "Port that the container exposes."
  type        = number
  default     = 0
}

variable "task_container_port_mappings" {
  description = "List of port objects that the container exposes in addition to the task_container_port."
  type = list(object({
    containerPort = number
    hostPort      = number
    protocol      = string
  }))
  default = []
}

variable "task_container_protocol" {
  description = "Protocol that the container exposes."
  default     = "HTTP"
  type        = string
}

variable "task_definition_cpu" {
  description = "Amount of CPU to reserve for the task."
  default     = 256
  type        = number
}

variable "task_definition_memory" {
  description = "The soft limit (in MiB) of memory to reserve for the container."
  default     = 512
  type        = number
}

variable "task_container_command" {
  description = "The command that is passed to the container."
  default     = []
  type        = list(string)
}

variable "task_container_environment" {
  description = "The environment variables to pass to a container."
  default     = {}
  type        = map(string)
}

variable "health_check" {
  description = "A health block containing health check settings for the target group. Overrides the defaults."
  type        = map(string)
  default     = {}
}

variable "health_check_grace_period_seconds" {
  default     = 300
  description = "Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown, up to 7200. Only valid for services configured to use load balancers."
  type        = number
}

variable "tags" {
  description = "A map of tags (key-value pairs) passed to resources."
  type        = map(string)
  default     = {}
}

variable "deployment_minimum_healthy_percent" {
  default     = 50
  description = "The lower limit of the number of running tasks that must remain running and healthy in a service during a deployment"
  type        = number
}

variable "deployment_maximum_percent" {
  default     = 200
  description = "The upper limit of the number of running tasks that can be running in a service during a deployment"
  type        = number
}
variable "wait_for_steady_state" {
  description = "Wait for the service to reach a steady state (like aws ecs wait services-stable) before continuing."
  type        = bool
  default     = false
}

variable "stop_timeout" {
  description = "Time duration (in seconds) to wait before the container is forcefully killed if it doesn't exit normally on its own. On Fargate the maximum value is 120 seconds."
  default     = 30
}

variable "task_role_permissions_boundary_arn" {
  description = "ARN of the policy that is used to set the permissions boundary for the task (and task execution) role."
  default     = ""
  type        = string
}

variable "protocol_version" {
  description = "The protocol (HTTP) version."
  default     = "HTTP1"
  type        = string
}

variable "efs_volumes" {
  description = "Volumes definitions"
  default     = []
  type = list(object({
    name            = string
    file_system_id  = string
    root_directory  = string
    mount_point     = string
    readOnly        = bool
    access_point_id = string
  }))
}

variable "privileged" {
  description = "When this parameter is true, the container is given elevated privileges on the host container instance"
  default     = false
  type        = bool
}

variable "aws_iam_role_execution_suffix" {
  description = "Name suffix for task execution IAM role"
  type        = string
  default     = "-task-execution-role"
}

variable "aws_iam_role_task_suffix" {
  description = "Name suffix for task IAM role"
  type        = string
  default     = "-task-role"
}

variable "sg_cider_egress" {
  description = "List of cider to be used in egress"
  type        = list(string)
  default     = []
}

variable "enable_execute_command" {
  description = "Enable aws ecs execute_command"
  type        = bool
  default     = false
}

variable "sidecar_containers" {
  description = "List of sidecar containers"
  type        = list(any)
  default     = []
}

variable "mount_points" {
  description = "List of mount points"
  type        = list(any)
  default     = []
}

variable "volumes" {
  description = "List of volume"
  type        = list(any)
  default     = []
}

variable "allowed_cider_ingress" {
  
}

variable "aws_region" {
  
}