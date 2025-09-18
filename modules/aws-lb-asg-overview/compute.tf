# Criação do Template para as EC2
resource "aws_launch_template" "app_lt" {
    name_prefix = "${var.project_name}-app-lt"
    description = "Launch Template"
    
    ## Imagem da EC2, definido pelo variables
    image_id    = var.ec2_ami_id
    ## Tipo de Instacia, definido pelo variables
    instance_type = var.ec2_instance_type
    ## Nome da Chave, definido por var
    key_name      = var.key_pair_name

    ## IAM com SSM habilitado
    iam_instance_profile {
        name = aws_iam_instance_profile.ec2_instance_profile.name
    }

    user_data = base64encode(templatefile("${path.module}/user-data.sh", {
      CLONE_DIR = "/opt/aws-web-infra-monitoring0"
      REPO_URL  = "https://github.com/Nertonm/aws-web-infra-monitoring"
    }))

    ## Associação de Interfaces de Rede da EC2
    network_interfaces {
      ### Por padrão é falso mas se alguem quiser que seja verdadeiro
      associate_public_ip_address = var.ec2_associate_public_ip_address
      ### Security Group das EC2
      security_groups = [aws_security_group.ec2_sg.id]
    }

    tag_specifications {
        resource_type = "instance"
        tags = var.custom_tags
    }
    
    tag_specifications {
        resource_type = "volume"
        tags = var.custom_tags
    }

}

# Criação do Auto Scalling Group
resource "aws_autoscaling_group" "main_asg" {
  name_prefix = "${var.project_name}-app-asg"

  # Variaveis são defininidas por var
  desired_capacity = var.ec2_asg_desired_capacity
  max_size         = var.ec2_asg_max_size
  min_size         = var.ec2_asg_min_size

  # Private Subnets for ASG
  vpc_zone_identifier = aws_subnet.private_subnets[*].id
    
  # Target Group for ASG
  target_group_arns = [aws_alb_target_group.main.arn]

  health_check_type = "EC2"
  health_check_grace_period = var.asg_health_check_grace_period

  # Utiliza o launch_template criado anteriormente
  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances"
  ]
}

# Configuração pra scalling up
resource "aws_autoscaling_policy" "scale_up_step_policy" {
  name = "${var.project_name}-scale-up-policy"
  autoscaling_group_name = aws_autoscaling_group.main_asg.name
  policy_type = "StepScaling"
  adjustment_type = "ChangeInCapacity" 


  step_adjustment {
    scaling_adjustment = 1
    metric_interval_lower_bound = 0
  }
}

# Configuração pra scalling down
resource "aws_autoscaling_policy" "scale_down_step_policy" {
  name = "${var.project_name}-scale-down-policy"
  autoscaling_group_name = aws_autoscaling_group.main_asg.name
  policy_type = "StepScaling"
  adjustment_type = "ChangeInCapacity" 

  step_adjustment {
    scaling_adjustment = -1
    metric_interval_upper_bound = 0
  }
}

# Configuração CloudWatch Alarm para monitorar CPU High Usage
resource "aws_cloudwatch_metric_alarm" "high_cpu_alarm" {
  alarm_name = "${var.project_name}-high-cpu-utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = var.cloudwatch_evaluation_periods
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = var.cloudwatch_period
  statistic = "Average"
  threshold = var.cloudwatch_threshold 
  alarm_description = "Este alarme dispara se a utilização média da CPU exceder os limites predefinidos."

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.main_asg.name
  }

  alarm_actions = [aws_autoscaling_policy.scale_up_step_policy.arn]
}

# Configuração CloudWatch Alarm para monitorar CPU 
resource "aws_cloudwatch_metric_alarm" "low_cpu_alarm" {
  alarm_name = "${var.project_name}-low-cpu-utilization"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods = var.cloudwatch_evaluation_periods
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = var.cloudwatch_period
  statistic = "Average"
  threshold = var.cloudwatch_low_threshold 
  alarm_description = "Este alarme dispara se a utilização média da CPU ficar abaixo dos limites predefinidos."

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.main_asg.name
  }

  alarm_actions = [aws_autoscaling_policy.scale_down_step_policy.arn]
}