# 트러블슈팅 보고서

## 사례 1: terraform apply 중 VPC 생성이 UnauthorizedOperation으로 실패
```bash
Error: creating EC2 VPC: modifying EnableDnsHostnames: waiting for completion: operation error EC2: DescribeVpcAttribute, https response error StatusCode: 403, ...
```

- **증상**: `terraform apply` 시 `aws_vpc.main` 생성 도중 403 에러로 중단됨.
  `not authorized to perform: ec2:DescribeVpcAttribute`
- **가설**:
  1. IAM 사용자의 정책에 해당 액션이 빠져 있다.
  2. 리전이나 리소스 범위 제한 때문에 막혔다.
  3. 자격 증명이 다른 사용자(루트 등)로 잡혀 있다.
- **검증**:
  - 에러 메시지의 User ARN이 `user/cloud-mission-user`임을 확인 → 가설 3 배제
  - 에러 문구가 "no identity-based policy allows"이므로 명시적 거부가 아닌 정책 누락 → 가설 1 유력
  - 정책 JSON을 확인하니 `ec2:Describe*`가 없고 일부 Describe만 나열되어 있었음 (가설 1 확정)
- **조치**: 정책에 `ec2:Describe*`(읽기 전용)를 추가하고 저장한 뒤 `terraform apply` 재실행.
  실패 시 생성된 VPC는 tainted 상태로 기록되어 재생성됨.
- **결과**: 7개 리소스가 정상 생성됨. (apply 성공 후 이 문장을 확인해 유지)
- **재발방지**: Terraform은 리소스 생성 후 상태 확인용으로 Describe 계열을 자주 호출하므로,
  읽기 전용 Describe*는 허용하고 생성/삭제 액션만 명시적으로 제한하는 방식으로 정책을 설계한다.

## 사례 2: Security Group 생성 실패 (InvalidParameterValue)
```bash
Error: creating Security Group (cloud-mission-web-sg): operation error EC2: CreateSecurityGroup, https response error StatusCode: 400, RequestID:~, api error InvalidParameterValue: Value (HTTP 전체 허용, SSH는 내 IP만 허용 (최소권한)) for parameter GroupDescription is invalid. Character sets beyond ASCII are not supported.
```

- **증상**: apply 중 VPC/서브넷/IGW는 생성됐지만 aws_security_group.web에서 400 에러.
  `Character sets beyond ASCII are not supported`
- **가설**:
  1. 보안 그룹 description에 허용되지 않는 문자가 있다.
  2. 이름(name)이나 태그에 문제가 있다.
  3. VPC ID가 잘못 전달됐다.
- **검증**: 에러 메시지의 `GroupDescription` 값에 한글이 포함되어 있음을 확인.
  name과 tags는 영문이라 가설 2 배제. 이미 VPC가 만들어졌으므로 가설 3 배제.
- **조치**: description을 영문으로 변경 후 apply 재실행.
  이미 성공한 5개 리소스는 유지되고 나머지 2개만 생성됨(Terraform state 덕분).
- **결과**: (성공 후 실제 결과 기재)
- **재발방지**: AWS API로 전달되는 값(description, name, tag)은 ASCII로 작성.
  한글은 코드 주석에만 사용. 적용 전 `terraform plan`에서 문자열 값을 확인.