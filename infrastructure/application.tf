# This file contains necessary infrastructure to set up an ECS cluster utilizing EC2 instances

resource "aws_ecs_cluster" "application" {
  name = "${module.label_ceros_evaluation.id}"
}

resource "aws_ecs_service" "ecs_service" {
  name            = "${module.label_ceros_evaluation.id}-service"
  iam_role        = "${aws_iam_role.ecs_service_role.name}"
  cluster         = "${aws_ecs_cluster.application.id}"
  task_definition = "${aws_ecs_task_definition.main_task.family}:${max("${aws_ecs_task_definition.main_task.revision}", "${data.aws_ecs_task_definition.main_task.revision}")}"
  desired_count   = 3 # desired number of containers

  # Our load balancer only has one target group, so we will use the first
  load_balancer {
    target_group_arn = "${module.alb.target_group_arns[0]}"
    container_port   = "${var.container_port}"
    container_name   = "${module.label_ceros_evaluation.id}"
  }

  depends_on = ["module.alb"]
}

data "aws_ecs_task_definition" "main_task" {
  task_definition = "${aws_ecs_task_definition.main_task.family}"
  depends_on      = ["aws_ecs_task_definition.main_task"]
}

resource "aws_ecs_task_definition" "main_task" {
  family                = "${module.label_ceros_evaluation.id}"
  container_definitions = "${module.container_definition.json}"
}

module "container_definition" {
  source = "git::https://github.com/cloudposse/terraform-aws-ecs-container-definition.git?ref=master"

  # we use the latest version of the container image by default
  container_image = "638635720737.dkr.ecr.${var.region}.amazonaws.com/${module.label_ceros_evaluation.id}:latest"
  container_name  = "${module.label_ceros_evaluation.id}"

  # decided to keep logging local to the container in json format
  # in the future we can ship to fluentd, splunk, etc. https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_LogConfiguration.html
  log_driver = "json-file"

  log_options = {}

  port_mappings = [
    {
      containerPort = "${var.container_port}"
      protocol      = "tcp"
    },
  ]

  command = ["npm", "start"]
}

resource "aws_ecr_repository" "main" {
  name = "${module.label_ceros_evaluation.id}"
}

data "aws_ami" "latest_ecs_optimized" {
  most_recent = true
  owners      = ["591542846629"]

  //Amazon Linux 2018.03 (ECS Optimized)
  filter {
    name   = "name"
    values = ["amzn-ami-2018.03.*-amazon-ecs-optimized"]
  }
}

resource "aws_launch_configuration" "ecs_service" {
  name_prefix          = "${module.label_ceros_evaluation.id}"
  image_id             = "${data.aws_ami.latest_ecs_optimized.image_id}"
  instance_type        = "t2.micro"
  iam_instance_profile = "${aws_iam_instance_profile.ecs-instance-profile.id}"
  security_groups      = ["${module.security_group_lb_to_instance.this_security_group_id}"]

  root_block_device {
    volume_type           = "standard"
    volume_size           = 100
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }

  associate_public_ip_address = "false"
  key_name                    = "ceros-ski-keypair"

  # Register the cluster name with ecs-agent which will in turn coordinate with the ECS Cluster
  user_data = <<EOF
  #!/bin/bash
  echo ECS_CLUSTER=${aws_ecs_cluster.application.name} >> /etc/ecs/ecs.config
  EOF
}

resource "aws_autoscaling_group" "ecs_service" {
  name                 = "${module.label_ceros_evaluation.id}-asg"
  max_size             = "3"
  min_size             = "2"
  desired_capacity     = "2" # desired number of instances, ensure that its within the boundaries of min/max above
  vpc_zone_identifier  = ["${data.aws_subnet_ids.default.ids}"]
  launch_configuration = "${aws_launch_configuration.ecs_service.name}"
  health_check_type    = "ELB"

  tag {
    key                 = "Name"
    value               = "${module.label_ceros_evaluation.id}"
    propagate_at_launch = true
  }
}

module "alb" {
  source             = "terraform-aws-modules/alb/aws"
  load_balancer_name = "${module.label_ceros_evaluation.id}-alb"

  vpc_id = "${aws_vpc.default.id}"

  security_groups = [
    "${module.security_group_web_traffic.this_security_group_id}",
    "${module.security_group_lb_to_instance.this_security_group_id}",
  ]

  log_bucket_name     = "${module.s3_bucket_access_logs.bucket_id}"
  log_location_prefix = "${module.label_ceros_evaluation.id}"
  subnets             = ["${data.aws_subnet_ids.default.ids}"]

  # todo add https listeners
  # degenerate implmentation of load balancer listeners - http listeners only for now
  http_tcp_listeners = "${list(map("port", "80", "protocol", "HTTP"))}"

  http_tcp_listeners_count = "1"
  target_groups            = "${list(map("name", "${module.label_ceros_evaluation.id}-tg", "backend_protocol", "HTTP", "backend_port", "80"))}"
  target_groups_count      = "1"
}
