terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Random ID for unique naming
resource "random_id" "id" {
  byte_length = 4
}

# The Guardrail
resource "aws_budgets_budget" "tlab_budget" {  
  name              = "TLAB-Strict-Budget"  
  budget_type       = "COST"  
  limit_amount      = "10"  
  limit_unit        = "USD"  
  time_unit         = "MONTHLY"  

  notification {    
    comparison_operator        = "GREATER_THAN"    
    notification_type          = "ACTUAL"    
    threshold                  = 80    
    threshold_type             = "PERCENTAGE"    
    subscriber_email_addresses = ["gjlfa2005@gmail.com"]  
  }
}

resource "aws_s3_bucket" "vault" {
  bucket = "titan-fintech-vault-gjl-${random_id.id.hex}"
  acl = "private"
   
  tags = {
    Name        = "Titan Fintech Vault"
    Environment = "TLAB5"
  }
}

# The Target Identity
resource "aws_iam_user" "tlab_user" {  
  name = "tlab-service-account"
}

# Trust policy allowing EC2 to assume the role
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "titan_ec2_vault_role" {
  name               = "Titan-EC2-Vault-Role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = {
    Name        = "Titan EC2 Vault Role"
    Environment = "TLAB5"
  }
}

# Policy: only PutObject into the specific vault bucket
data "aws_iam_policy_document" "vault_put_only" {
  statement {
    effect = "Allow"

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.vault.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "vault_put_policy" {
  name   = "Titan-EC2-Vault-PutOnly"
  policy = data.aws_iam_policy_document.vault_put_only.json
}

resource "aws_iam_role_policy_attachment" "vault_put_attach" {
  role       = aws_iam_role.titan_ec2_vault_role.name
  policy_arn = aws_iam_policy.vault_put_policy.arn
}

# Instance profile to attach the role to EC2
resource "aws_iam_instance_profile" "titan_ec2_vault_profile" {
  name = "Titan-EC2-Vault-InstanceProfile"
  role = aws_iam_role.titan_ec2_vault_role.name
}

# Ubuntu AMI lookup (Canonical, latest Ubuntu 20.04 LTS)
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "titan_vault_ec2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  iam_instance_profile = aws_iam_instance_profile.titan_ec2_vault_profile.name

  tags = {
    Name        = "Titan Vault EC2"
    Environment = "TLAB5"
  }
}
