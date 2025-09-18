variable "aws_region" {
  type = string
  default = "us-east-1"
  description = "AWS region to deploy resources"
}

variable "project_name" {
  type  = string
  default   = "aws-lb-asg-overview"
  description = "Project name for tagging resources" 
}

variable "vpc_name" {
  type  = string
  description = "Name of VPC"
  default = "main"
}

variable "nat_gateway_count" {
    description = "Number of NAT Gateways to create (one per public subnet), for testing use 1"
    type        = number
    default     = 1
    validation {
        condition     = var.nat_gateway_count <= length(var.az)
        error_message = "NAT Gateway count cannot exceed the number of availability zones"
    }
}

variable "az" {
  type  = list(string)
  default  = ["us-east-1a", "us-east-1b"]
  description = "Availability zones"
}

variable "vpc_cidr" {
  type    = string
  default   = "10.0.0.0/16"
  description = "VPC CIDR"
}

variable "private_subnets_cidr" {
  type   = list(string)
  default = ["10.0.128.0/20", "10.0.144.0/20"]
  description = "Private subnets CIDR"
}

variable "public_subnets_cidr" {
  type  = list(string)
  default  = ["10.0.0.0/20", "10.0.16.0/20"]
  description = "Public subnets CIDR"
}

variable "admin_ip" {
  description = "Admin ip address to allow SSH access."
  type   = string
}

variable "environment" {
  description = "Deployment environment"
  type  = string
}

variable "custom_tags" {
  description = "Mapa de tags personalizadas para aplicar aos recursos."
  type        = map(string)
  default = {
    Name       = "" 
    CostCenter = ""
    Project    = ""
  }
}

variable "ec2_instance_type" {
  description = "EC2 instance type for application servers."
  type   = string
  default   = "t2.micro" 
}

variable "ec2_ami_id" {
  description = "AMI ID for the EC2 instances"
  type   = string
  default = "ami-00ca32bbc84273381"  # Amazon Linux
}

variable "key_pair_name" {
  description = "Key pair name for SSH access to EC2 instances."
  type = string
  default = "teste2"
}

variable "ec2_associate_public_ip_address" {
  description = "If true, associates a public IP address with the EC2 instances."
  type = bool
  default = false
}

variable "alb_timeout" {
    description = "Timeout for the ALB health check."
    type  = number
    default  = 5
}

variable "alb_interval" {
    description = "Interval between ALB health checks."
    type = number
    default  = 30
}

variable "alb_healthy_threshold" {
    description = "NNumber of successful attempts required to consider an instance healthy."
    type = number
    default = 3
}

variable "alb_unhealthy_threshold" {
    description = "NNumber of failed attempts required to consider an instance unhealthy."
    type = number
    default = 2
}

variable "ec2_asg_desired_capacity" {
  description = "Desired capacity of the Auto Scaling Group."
  type = number
  default = 1
}

variable "ec2_asg_min_size" {
  description = "Minimum size of the Auto Scaling Group."
  type = number
  default = 1
}

variable "ec2_asg_max_size" {
  description = "Maximum size of the Auto Scaling Group."
  type = number
  default = 4
}

variable "asg_scale_up_target_value" {
  description = "Target CPU value for scaling up the ASG."
  type = number
  default = 50.0
}

variable "asg_scale_down_target_value" {
  description = "Target CPU value for scaling down the ASG."
  type = number
  default = 30.0
}

variable "asg_health_check_grace_period" {
  description = "Health check grace period for the ASG."
  type = number
  default = 300  
}

variable "alb_path" {
  description = "Path for the ALB health check."
  type = string
  default = "/"
}

variable "alb_port" {
  description = "Port for the ALB."
  type = number
  default = 80
}

variable "alb_protocol" {
  description = "Protocol for the ALB."
  type = string
  default = "HTTP"
}

variable "alb_matcher" {
  description = "Matcher for the ALB health check."
  type = string
  default = "200-399"
}

variable "cloudwatch_evaluation_periods" {
  description = "Number of periods over which data is compared to the specified threshold."
  type = number
  default = 2
}

variable "cloudwatch_period" {
  description = "The period, in seconds, over which the specified statistic is applied."
  type = number
  default = 30
}

variable "cloudwatch_threshold" {
  description = "The value against which the specified statistic is compared."
  type = number
  default = 50
}

variable "scale_up_cooldown" {
  description = "Cooldown period after a scale-up activity."
  type = number
  default = 300
}

variable "scale_down_cooldown" {
  description = "Cooldown period after a scale-down activity."
  type = number
  default = 300
}

variable "cloudwatch_low_threshold" {
  description = "The value against which the specified statistic is compared for scaling down."
  type = number
  default = 30
}