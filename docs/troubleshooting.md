# 트러블슈팅 보고서

## 사례 1: 브라우저에서 퍼블릭 IP로 접속이 안 됨 (연결 시간 초과)

- **증상**: `http://<퍼블릭IP>` 접속 시 계속 로딩되다가 timeout. `curl http://<퍼블릭IP>` 도 응답 없음.
- **가설**:
  1. Security Group에서 80번 포트가 열려있지 않을 수 있다.
  2. Route Table에 0.0.0.0/0 → IGW 경로가 없을 수 있다.
  3. Nginx가 인스턴스 내부에서 실행되지 않고 있을 수 있다.
- **검증**:
  - `aws ec2 describe-security-groups` 로 인바운드 규칙에 80/tcp, 0.0.0.0/0 존재 여부 확인
  - `aws ec2 describe-route-tables` 로 Public Subnet 라우트 테이블에 IGW 경로 존재 여부 확인
  - SSH로 인스턴스 접속 후 `sudo systemctl status nginx`, `curl -i http://localhost` 로 로컬 응답 확인
- **조치**: (실제로 확인된 원인을 여기 기재. 예: SG 인바운드 규칙에 80이 누락되어 있었음 → `aws_security_group` 룰 추가/재적용)
- **결과**: 조치 후 `curl -i http://<퍼블릭IP>` 가 200 OK 반환됨을 확인.
- **재발방지**: Terraform으로 SG 규칙을 코드화하여 콘솔에서 수동 변경 시 발생하는 누락을 방지. `terraform plan` 으로 apply 전 항상 diff 확인.

## 사례 2: SSH 접속 시 Permission denied 또는 Connection timed out

- **증상**: `ssh -i key.pem ubuntu@<퍼블릭IP>` 실행 시 응답 없이 멈추거나 `Permission denied (publickey)` 발생.
- **가설**:
  1. Security Group의 22번 포트 소스가 내 IP와 다름 (IP가 변경되었거나 잘못 입력됨).
  2. 키페어 파일 권한이 너무 열려 있어 SSH 클라이언트가 거부함 (0644 등).
  3. 사용자 계정명이 AMI와 맞지 않음 (Ubuntu는 `ubuntu`, Amazon Linux는 `ec2-user`).
- **검증**:
  - `curl ifconfig.me` 로 현재 내 IP를 재확인하고 SG 규칙과 비교
  - `chmod 400 key.pem` 적용 여부 확인
  - AMI 종류에 맞는 기본 사용자명으로 재시도
- **조치**: (실제 원인 기재. 예: 집-카페 이동으로 IP가 바뀌어 SG 소스와 불일치 → `my_ip_cidr` 변수 갱신 후 `terraform apply`)
- **결과**: SSH 접속 성공, `whoami` 로 `ubuntu` 계정 확인.
- **재발방지**: IP가 자주 바뀌는 환경이면 SSH 접속 전 항상 `curl ifconfig.me` 로 확인하는 습관화, 또는 임시로 AWS Systems Manager Session Manager 사용 고려 (SSH 포트 자체를 열지 않는 대안).

---
> 실제 실습 중 겪은 오류로 위 템플릿 내용을 교체할 것. 최소 1건은 필수 제출 항목.
