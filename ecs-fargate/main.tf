# ------------------------------------------------------------------------------
# AWS
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# IAM - Task execution role, needed to pull ECR images etc.
# ------------------------------------------------------------------------------
resource "aws_iam_role" "execution" {
  name                 = "${var.name_prefix}${var.aws_iam_role_execution_suffix}"
  assume_role_policy   = data.aws_iam_policy_document.task_assume.json
  permissions_boundary = var.task_role_permissions_boundary_arn
}

# ------------------------------------------------------------------------------
# IAM - Task role, basic. Users of the module will append policies to this role
# when they use the module. S3, Dynamo permissions etc etc.
# ------------------------------------------------------------------------------
resource "aws_iam_role" "task" {
  name                 = "${var.name_prefix}${var.aws_iam_role_task_suffix}"
  assume_role_policy   = data.aws_iam_policy_document.task_assume.json
  permissions_boundary = var.task_role_permissions_boundary_arn
}

# ------------------------------------------------------------------------------
# ECS cluster
# ------------------------------------------------------------------------------
resource "aws_ecs_cluster" "main" {
  name = var.name_prefix
}
# ------------------------------------------------------------------------------
# ECS Task/Service
# ------------------------------------------------------------------------------
locals {
  task_container_port_mappings = var.task_container_port == 0 ? var.task_container_port_mappings : concat(var.task_container_port_mappings, [{ containerPort = var.task_container_port, hostPort = var.task_container_port, protocol = "tcp" }])
  task_container_environment   = [for k, v in var.task_container_environment : { name = k, value = v }]
  task_container_mount_points  = concat([for v in var.efs_volumes : { containerPath = v.mount_point, readOnly = v.readOnly, sourceVolume = v.name }], var.mount_points)


  container_definition = merge({
    "name"         = var.container_name != "" ? var.container_name : var.name_prefix
    "image"        = var.task_container_image,
    "essential"    = true
    "portMappings" = local.task_container_port_mappings
    "stopTimeout"  = var.stop_timeout
    "command"      = var.task_container_command
    "environment"  = local.task_container_environment
    "MountPoints"  = local.task_container_mount_points
    "privileged" : var.privileged
  }, 
  )
}

resource "aws_ecs_task_definition" "task" {
  family                   = var.name_prefix
  execution_role_arn       = aws_iam_role.execution.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_definition_cpu
  memory                   = var.task_definition_memory
  task_role_arn            = aws_iam_role.task.arn
  dynamic "volume" {
    for_each = var.efs_volumes
    content {
      name = volume.value["name"]
      efs_volume_configuration {
        file_system_id     = volume.value["file_system_id"]
        root_directory     = volume.value["root_directory"]
        transit_encryption = "ENABLED"
        authorization_config {
          access_point_id = volume.value["access_point_id"]
          iam             = "ENABLED"
        }
      }
    }
  }
  dynamic "volume" {
    for_each = var.volumes
    content {
      name = volume.value["name"]
    }
  }
  container_definitions = jsonencode(concat([local.container_definition], var.sidecar_containers))
}

resource "aws_ecs_service" "service" {
  
  name                               = var.name_prefix
  cluster                            = aws_ecs_cluster.main.id
  task_definition                    = aws_ecs_task_definition.task.arn
  desired_count                      = var.desired_count
  launch_type                        = "FARGATE"
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.deployment_maximum_percent
  health_check_grace_period_seconds  = aws_alb.task_lb.id == "" ? null : var.health_check_grace_period_seconds
  wait_for_steady_state              = var.wait_for_steady_state
  enable_execute_command             = var.enable_execute_command
  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = concat([aws_security_group.ecs_service.id])
    assign_public_ip = var.task_container_assign_public_ip
  }

  dynamic "load_balancer" {
    for_each = aws_alb.task_lb.id == "" ? [] : [1]
    content {
      container_name   = var.container_name != "" ? var.container_name : var.name_prefix
      container_port   = var.task_container_port
      target_group_arn = aws_alb_target_group.task.arn
    }
  }
}
