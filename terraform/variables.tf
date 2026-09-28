variable "aws_region" {
  description = "리소스를 생성할 리전 (미션 제약: 서울 리전 고정)"
  type        = string
  default     = "ap-northeast-2"
}

variable "project_name" {
  description = "리소스 이름/태그에 붙일 프로젝트 식별자"
  type        = string
  default     = "cloud-mission"
}

variable "vpc_cidr" {
  description = "VPC 전체 CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Public Subnet CIDR (VPC CIDR의 부분집합이어야 함)"
  type        = string
  default     = "10.0.1.0/24"
}

variable "az" {
  description = "Public Subnet을 배치할 가용영역"
  type        = string
  default     = "ap-northeast-2a"
}

variable "instance_type" {
  description = "프리티어 대상 인스턴스 타입"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "SSH 접속용으로 미리 생성해둔 EC2 키페어 이름 (콘솔에서 먼저 생성 후 입력)"
  type        = string
}

variable "my_ip_cidr" {
  description = "SSH(22) 접속을 허용할 내 IP (CIDR 형식, 예: 1.2.3.4/32). curl ifconfig.me 로 확인 후 /32 붙여서 입력"
  type        = string
}

variable "root_volume_size" {
  description = "EBS 루트 볼륨 크기(GiB), 8~10 권장"
  type        = number
  default     = 8
}
