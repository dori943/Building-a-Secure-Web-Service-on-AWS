resource "aws_security_group" "web" {
  name        = "${var.project_name}-web-sg"
  description = "Allow HTTP from anywhere, SSH from my IP only"
  vpc_id      = aws_vpc.main.id

  # HTTP: 누구나 접근 가능해야 하는 웹 서비스이므로 0.0.0.0/0 허용
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH: 반드시 내 IP 대역으로만 제한 (0.0.0.0/0 금지)
  ingress {
    description = "SSH from my IP only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  # 아웃바운드는 전체 허용 (패키지 설치, curl 테스트 등을 위해 필요)
  egress {
    description = "allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-web-sg"
  }
}
