
variable "key_pair_name" {}
variable "admin_ip" {}

module "aws-lb-asg-overview" {
  # 
  source         = "../../modules/aws-lb-asg-overview"
  key_pair_name  = var.key_pair_name
  environment    = "learning"

  admin_ip       = var.admin_ip
  ec2_associate_public_ip_address = false
  nat_gateway_count = 1

  ec2_asg_desired_capacity = 1
  ec2_asg_min_size = 1 
  ec2_asg_max_size = 3

  asg_scale_up_target_value = 50.0
  asg_scale_down_target_value = 10.0
}

output "alb_dns_name" {
  description = "DNS public name for the Load Balancer."
  value       = module.aws-lb-asg-overview.alb_dns_name
}


output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group for application servers."
  value       = module.aws-lb-asg-overview.autoscaling_group_name
}


output "launch_template_id" {
  description = "ID of the Launch Template used by the Auto Scaling Group."
  value       = module.aws-lb-asg-overview.launch_template_id
}


output "security_group_id" {
  description = "ID of the Security Group associated with the EC2 instances."
  value       = module.aws-lb-asg-overview.security_group_id
}


output "vpc_id" {
  description = "ID of the VPC where the resources are deployed."
  value       = module.aws-lb-asg-overview.vpc_id
}


