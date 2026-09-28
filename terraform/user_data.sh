#!/bin/bash
# EC2 최초 부팅 시 1회 실행되는 초기화 스크립트 (Ubuntu 기준)
set -euxo pipefail

# 패키지 목록 갱신 및 nginx 설치
apt-get update -y
apt-get install -y nginx

# 기본 접속 확인용 페이지 (요구사항 A: 브라우저 접속 시 정상 표시)
cat <<'EOF' > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head><title>Cloud Mission</title></head>
<body>
  <h1>Hello from EC2</h1>
  <p>Nginx is running inside a Public Subnet.</p>
</body>
</html>
EOF

# 헬스체크 엔드포인트 (요구사항 B: GET /health -> 200 OK)
mkdir -p /var/www/html
cat <<'EOF' > /var/www/html/health
OK
EOF

# nginx가 /health 요청 시 text/plain 로 OK만 내려주도록 설정
cat <<'EOF' > /etc/nginx/sites-available/default
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    root /var/www/html;
    index index.html;

    location /health {
        default_type text/plain;
        return 200 "OK";
    }

    location / {
        try_files $uri $uri/ =404;
    }
}
EOF

systemctl enable nginx
systemctl restart nginx
