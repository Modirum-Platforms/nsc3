#!/usr/bin/env bash

if [ -z "$1" ]; then
    echo "Usage: ./diagnose.sh <target-domain>"
    exit 1
fi

TARGET_DOMAIN="$1"
TARGET_IP=$(dig +short $TARGET_DOMAIN | tail -n1)
PORTS=(443 25204 25205 25206)

mkdir -p logs
LOGFILE="./logs/diagnostic-$(date +%Y%m%d-%H%M%S).log"

echo "=== SaaS NETWORK DIAGNOSTICS (Linux) ===" | tee -a $LOGFILE
echo "Target domain: $TARGET_DOMAIN" | tee -a $LOGFILE
echo "" | tee -a $LOGFILE

echo "1) DNS CHECK" | tee -a $LOGFILE
if [ -z "$TARGET_IP" ]; then
    echo "FAIL: DNS lookup failed" | tee -a $LOGFILE
else
    echo "OK: DNS returned $TARGET_IP" | tee -a $LOGFILE
fi
echo "" | tee -a $LOGFILE

echo "2) HTTPS CHECK (443)" | tee -a $LOGFILE
curl -I --max-time 5 https://$TARGET_DOMAIN 2>&1 | tee -a $LOGFILE
if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo "FAIL: HTTPS unreachable" | tee -a $LOGFILE
else
    echo "OK: HTTPS reachable" | tee -a $LOGFILE
fi
echo "" | tee -a $LOGFILE

echo "3) RAW TCP PORT CHECKS" | tee -a $LOGFILE
for p in "${PORTS[@]}"; do
    echo -n "Testing port $p ... " | tee -a $LOGFILE
    nc -z -v -w3 $TARGET_DOMAIN $p 2>&1 | grep -E "succeeded|open" >/dev/null
    if [ $? -eq 0 ]; then
        echo "OPEN" | tee -a $LOGFILE
    else
        echo "BLOCKED" | tee -a $LOGFILE
    fi
done
echo "" | tee -a $LOGFILE

echo "4) TRACEROUTE" | tee -a $LOGFILE
traceroute -n $TARGET_DOMAIN 2>&1 | tee -a $LOGFILE
echo "" | tee -a $LOGFILE

echo "=== DONE ===" | tee -a $LOGFILE
