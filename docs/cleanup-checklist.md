# 리소스 정리 체크리스트

정리 순서를 지킬 것: 상위 리소스(EC2 등)를 먼저 종료해야 하위 리소스(SG, Subnet, VPC)가 삭제 가능하다.
`terraform destroy` 를 사용하면 아래 항목이 대부분 자동으로 정리되지만, 콘솔에서 직접 만든 리소스가 있다면 수동으로도 확인할 것.

- [x] **EC2 인스턴스**: 상태가 `terminated` 인지 확인 (`stopped` 만으로는 EBS 등 과금이 남을 수 있음)
- [x] **Elastic IP**: 인스턴스에서 분리(disassociate) 후 Release 되었는지 확인 (연결 안 된 EIP는 시간당 과금)
- [x] **EBS Volume**: 인스턴스 종료 후 잔여 볼륨(`available` 상태)이 없는지 확인, 있다면 삭제
- [x] **NAT Gateway**: 생성했다면 삭제 확인 (이 미션에서는 생성하지 않았다면 해당 없음)
- [x] **ELB/ALB**: 생성했다면 삭제 확인 (이 미션에서는 생성하지 않았다면 해당 없음)
- [x] **RDS**: 생성했다면 삭제 확인 (이 미션에서는 생성하지 않았다면 해당 없음)
- [x] **Internet Gateway**: VPC에서 detach 후 삭제 확인
- [x] **Route Table / Subnet**: 삭제 확인 (기본 리소스 제외)
- [x] **Security Group**: 삭제 확인 (기본 SG 제외)
- [x] **VPC**: 삭제 확인
- [x] **키페어**: 실습 완전 종료 시 필요 없다면 콘솔에서 삭제 (선택)
- [x] **Billing Dashboard**: "Bills" 또는 "Cost Explorer" 에서 실행 중인 리소스로 인한 예상 비용이 0에 수렴하는지 확인

## Terraform 기준 정리 명령
```bash
cd terraform
terraform destroy
```
destroy 완료 후 `terraform show` 로 남은 상태가 없는지 재확인.

## 정리 완료 근거
- 정리 완료 일시:
- 확인 방법 (스크린샷/CLI 출력 등):
