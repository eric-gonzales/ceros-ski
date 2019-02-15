# Identity and Access Management (IAM) roles, instance profiles, and policies

# Begin ECS Instance Profile - ensures that EC2 instances can communicate with ECS, pull images from ECR, and create/push logs
resource "aws_iam_role" "ecs_instance_role" {
  name               = "${module.label_ceros_evaluation.id}-ecs-instance-role"
  path               = "/"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_instance_policy.json}"
}

data "aws_iam_policy_document" "ecs_instance_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_attachment" {
  role       = "${aws_iam_role.ecs_instance_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs-instance-profile" {
  name = "${module.label_ceros_evaluation.id}-ecs-instance-profile"
  path = "/"
  role = "${aws_iam_role.ecs_instance_role.id}"

  provisioner "local-exec" {
    command = "sleep 60"
  }
}

# Begin ECS Service Role - used for calls that the ECS service scheduler makes to EC2 and ELB
resource "aws_iam_role" "ecs_service_role" {
  name               = "${module.label_ceros_evaluation.id}-ecs-service-role"
  path               = "/"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_service_policy.json}"
}

resource "aws_iam_role_policy_attachment" "ecs_service_role_attachment" {
  role       = "${aws_iam_role.ecs_service_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

data "aws_iam_policy_document" "ecs_service_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}
