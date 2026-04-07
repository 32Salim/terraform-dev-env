resource "aws_iam_role" "bastion_ec2_role" {
  name = "bastion-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "bastion-ec2-role"
    Environment = "dev"
  }
}

resource "aws_iam_role_policy_attachment" "bastion_cloudwatch_agent" {
  role       = aws_iam_role.bastion_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "bastion_instance_profile" {
  name = "bastion-instance-profile"
  role = aws_iam_role.bastion_ec2_role.name
}

resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Security group for hardened bastion host"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from trusted IP only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "bastion-sg"
    Environment = "dev"
  }
}

resource "aws_security_group" "app_sg" {
  name        = "app-sg"
  description = "Security group for private app instances"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "SSH from bastion only"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "app-sg"
    Environment = "dev"
  }
}


resource "aws_network_acl" "private_nacl" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = [aws_subnet.private_az1.id, aws_subnet.private_az2.id]

  ingress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = var.public_subnet_az1_cidr
    from_port  = 22
    to_port    = 22
  }

  ingress {
    rule_no    = 110
    protocol   = "tcp"
    action     = "allow"
    cidr_block = var.public_subnet_az1_cidr
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = var.public_subnet_az1_cidr
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    rule_no    = 110
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  tags = {
    Name        = "private-nacl"
    Environment = "dev"
  }
}

resource "aws_network_acl" "public_nacl" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = [aws_subnet.public_az1.id, aws_subnet.public_az2.id]

  ingress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = var.my_ip
    from_port  = 22
    to_port    = 22
  }

  ingress {
    rule_no    = 110
    protocol   = "tcp"
    action     = "allow"
    cidr_block = var.my_ip
    from_port  = 1024
    to_port    = 65535
  }

  ingress {
    rule_no    = 120
    protocol   = "tcp"
    action     = "allow"
    cidr_block = var.private_subnet_az1_cidr
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    rule_no    = 110
    protocol   = "tcp"
    action     = "allow"
    cidr_block = aws_subnet.private_az1.cidr_block
    from_port  = 22
    to_port    = 22
  }

  egress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = aws_subnet.private_az2.cidr_block
    from_port  = 22
    to_port    = 22
  }

  egress {
    rule_no    = 120
    protocol   = "tcp"
    action     = "allow"
    cidr_block = var.my_ip
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    rule_no    = 130
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  tags = {
    Name        = "public-nacl"
    Environment = "dev"
  }
}



resource "aws_instance" "bastion" {
  ami                         = data.aws_ssm_parameter.amazon_linux_2_ami.value
  instance_type               = var.bastion_instance_type
  subnet_id                   = aws_subnet.public_az1.id
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.bastion_instance_profile.name
  key_name                    = var.bastion_key_name
  associate_public_ip_address = true

  user_data = <<-EOF
            #!/bin/bash
            set -euxo pipefail

            yum update -y
            amazon-linux-extras install epel -y || true
            yum install -y fail2ban amazon-cloudwatch-agent

            sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
            sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
            sed -i 's/^#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
            sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

            cat > /etc/fail2ban/jail.local <<'EOT'
            [sshd]
            enabled = true
            port = ssh
            logpath = /var/log/secure
            backend = auto
            maxretry = 5
            findtime = 10m
            bantime = 1h
            EOT

            mkdir -p /opt/aws/amazon-cloudwatch-agent/etc

            cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<'EOT'
            ${templatefile("${path.module}/cloudwatch-agent.json.tpl", {})}
            EOT

            systemctl restart sshd
            systemctl enable fail2ban
            systemctl restart fail2ban

            /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
              -a fetch-config \
              -m ec2 \
              -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
              -s

            systemctl enable amazon-cloudwatch-agent
            EOF

  tags = {
    Name        = "bastion-host"
    Environment = "dev"
  }
}

data "aws_ssm_parameter" "amazon_linux_2_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-kernel-default-hvm-x86_64-gp2"
}

resource "aws_cloudwatch_log_group" "bastion_secure_logs" {
  name              = "bastion-secure-logs"
  retention_in_days = 14

  tags = {
    Name        = "bastion-secure-logs"
    Environment = "dev"
  }
}

resource "aws_cloudwatch_log_group" "bastion_system_logs" {
  name              = "bastion-system-logs"
  retention_in_days = 14

  tags = {
    Name        = "bastion-system-logs"
    Environment = "dev"
  }
}

resource "aws_instance" "private_app" {
  ami                         = data.aws_ssm_parameter.amazon_linux_2_ami.value
  instance_type               = var.private_instance_type
  subnet_id                   = aws_subnet.private_az1.id
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  key_name                    = var.private_key_name
  associate_public_ip_address = false

  tags = {
    Name        = "private-app-instance"
    Environment = "dev"
  }
}

