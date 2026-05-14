# 요구사항 수행 내역서

### [0] 실습 환경 세팅
```
// 가상머신 생성
orb create ubuntu:22.04 codyssey-server-b1-1

// 생성된 가상머신 접속
orb -m codyssey-server-b1-1

// 버전 확인
orb -m codyssey-server-b1-1
cat /etc/os-release

// 패키지 목록 업데이트 및 설치
sudo apt update
sudo apt install openssh-server -y
sudo apt install nano -y
sudo apt install ufw -y
```

<br>
<br>

### [1] 기본 보안 및 네트워크 설정
[1-1] SSH 설정
```
// 설정 파일 열기
sudo nano /etc/ssh/sshd_config

// 포트 번호 변경(편집기)
Port 20022

// 최고 관리자 로그인 차단(편집기)
PermitRootLogin no

// SSH 재시작
sudo systemctl restart ssh
```
![1.ssh_config](screenshots/1.ssh_config.png)

<br>

[1-2] 방화벽 설정(UFW)
```
//포트 허용 규칙 추가
sudo ufw allow 20022/tcp
sudo ufw allow 15034/tcp

// 방화벽 활성화
sudo ufw enable

// 방화벽 설정 상세 확인
sudo ufw status verbose
```
![2.ufw_status](screenshots/2.ufw_status.png)

<br>
<br>

### [2] 계정/그룹/권한 체계
[1-1] SSH 설정