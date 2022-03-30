
module "fargate" {
    source = "./ecs-fargate"

    name_prefix               = "nginx"
    vpc_id                    = "vpc-0be078435ce78daaa"
    private_subnet_ids        = ["subnet-045f952fcbb6431d4", "subnet-02e4ef8a264ee23c9"]
    task_container_image      = "nginx:latest"
    task_container_port       = "80"
    allowed_cider_ingress     = ["0.0.0.0/0"]
    aws_region                = "us-west-1"
    task_container_assign_public_ip = "true"
}