#!/bin/bash

# 1. 환경 설정
LOG_DIR="/var/log/agent-app"
LOG_FILE="$LOG_DIR/monitor.log"

echo "====== SYSTEM MONITOR RESULT ======"
echo ""

# 2. Health Check(실패 시 종료)
echo "[HEALTH CHECK]"
PID=$(pgrep -f "agent-app" | head -n 1)

if [ -z "$PID" ]; then
    echo "Checking process 'agent-app'... [FAIL]"
    exit 1
else
    echo "Checking process 'agent-app'... [OK] (PID: $PID)"
fi

PORT_CHECK=$(ss -tln | grep ":15034")
if [ -z "$PORT_CHECK" ]; then
    echo "Checking port 15034... [FAIL]"
    exit 1
else
    echo "Checking port 15034... [OK]"
fi
echo ""

# 3. Status Check (방화벽)
UFW_STATUS=$(sudo ufw status | grep "Status: active")
if [ -z "$UFW_STATUS" ]; then
    echo "[WARNING] Firewall (UFW) is inactive!"
fi

# 4. Resource Collection (앱 CPU, 메모리, 디스크 사용률)
CPU_USAGE=$(ps -p $PID -o %cpu= | awk '{print $1}')
MEM_USAGE=$(ps -p $PID -o %mem= | awk '{print $1}')
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')

echo "[RESOURCE MONITORING]"
echo "CPU Usage : ${CPU_USAGE}%"
echo "MEM Usage : ${MEM_USAGE}%"
echo "DISK Used : ${DISK_USAGE}%"
echo ""

# 5. 임계값 경고 (경고만 출력, 스크립트 종료 x)
if $(awk "BEGIN {exit !($CPU_USAGE > 20)}"); then
    echo "[WARNING] CPU threshold exceeded (${CPU_USAGE}% > 20%)"
fi
if $(awk "BEGIN {exit !($MEM_USAGE > 10)}"); then
    echo "[WARNING] MEM threshold exceeded (${MEM_USAGE}% > 10%)"
fi
if [ "$DISK_USAGE" -gt 80 ]; then
    echo "[WARNING] DISK threshold exceeded (${DISK_USAGE}% > 80%)"
fi
echo ""

# 6. 로그 기록
NOW=$(date +"%Y-%m-%d %H:%M:%S")
LOG_ENTRY="[$NOW] PID:$PID CPU:${CPU_USAGE}% MEM:${MEM_USAGE}% DISK_USED:${DISK_USAGE}%"
echo "$LOG_ENTRY" >> $LOG_FILE