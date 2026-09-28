output "instance_public_ip" {
  description = "외부 접속 검증에 사용할 퍼블릭 IP"
  value       = aws_instance.web.public_ip
}

output "ssh_command" {
  description = "SSH 접속 명령어 예시"
  value       = "ssh -i <your-key>.pem ubuntu@${aws_instance.web.public_ip}"
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet_id" {
  value = aws_subnet.public.id
}
