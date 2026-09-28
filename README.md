# Secure by Design: Your First VPC-Based Web Service on AWS
> VPC · Subnet · Internet Gateway · Security Group · IAM Least Privilege

## 1. 아키텍처
`docs/architecture.png` 참고. VPC → Public Subnet → IGW → Route Table → EC2(Nginx) 흐름.


## 2. 실행 방법
```bash
cd C:\Users\user\Building-a-Secure-Web-Service-on-AWS\terraform

# 내 공인 IP 확인
(Invoke-RestMethod https://checkip.amazonaws.com).Trim()

# 예시 파일 복사
Copy-Item terraform.tfvars.example terraform.tfvars
notepad terraform.tfvars
```

```bash
terraform init        # 필요한 AWS 플러그인 다운로드 (처음 1회)
terraform validate    # 코드 문법 검사
terraform plan        # 무엇을 만들지 미리보기 (아직 아무것도 안 만들어짐)
terraform apply       # 실제 생성. 확인 질문에 yes 입력
```
apply 완료 후 출력되는 `instance_public_ip` 를 아래 접속 검증에 사용.

## 3. 외부 접속 검증 (택 1)
- [ ] 방식 A: 브라우저로 `http://<여기에 실제 퍼블릭 IP 기재>/health` 접속 → 정상 페이지 표시
- [x] 방식 B: `curl -i http://<여기에 실제 퍼블릭 IP 기재>/health` → `200 OK`, 응답 본문 `OK`

선택한 방식: **B**
접속 정보: `curl -i http://13.209.84.146/health`

스크린샷: `docs/screenshots/access-proof.png`

## 4. 네트워크 요약
| 구성요소 | 값 |
|---|---|
| VPC CIDR | 10.0.0.0/16 |
| Public Subnet CIDR | 10.0.1.0/24 |
| 리전 | ap-northeast-2 (서울) |
| 인스턴스 타입 | t3.micro |

## 5. 보안 그룹 규칙
| 방향 | 포트 | 소스/목적지 | 사유 |
|---|---|---|---|
| Inbound | 80 | 0.0.0.0/0 | 웹 서비스는 누구나 접근 |
| Inbound | 22 | 내 IP/32 | 관리자만 SSH 접근 |
| Outbound | all | 0.0.0.0/0 | 패키지 설치 등 아웃바운드 통신 |

## 6. 리소스 정리
`docs/cleanup-checklist.md` 참고. 실습 종료 후 `terraform destroy` 실행.
