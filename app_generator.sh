#!/bin/bash

# Ensure our target log directory exists
mkdir -p logs
LOGFILE="logs/app.log"

echo "[INFO] $(date '+%Y-%m-%d %H:%M:%S') - Starting Enterprise App Service..." >> "$LOGFILE"

# Infinite loop to simulate aggressive background transaction logging
while true
do
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Bulletproof random simulator using standard seconds ($SECONDS counts shell uptime!)
    USER_ID=$(( (SECONDS * 7) % 1000 + 1000 ))
    TXN_ID=$(( (SECONDS * 13) % 90000 + 10000 ))
    CENTS=$(( (SECONDS * 3) % 90 + 10 ))
    
    # Write dynamic events to log
    echo "[INFO] $TIMESTAMP - USER_LOGIN - User ID: $USER_ID successfully authenticated." >> "$LOGFILE"
    echo "[SUCCESS] $TIMESTAMP - PAYMENT_API - Transaction ID: TXN$TXN_ID processed successfully. Amount: \$12.$CENTS" >> "$LOGFILE"
    
    # Simulating random error blocks using math cycles
    RAND_CHECK=$(( SECONDS % 5 ))
    if [ $RAND_CHECK -eq 0 ]; then
        echo "[WARNING] $TIMESTAMP - DB_CONNECTION - Latency spikes detected on database cluster master." >> "$LOGFILE"
    fi

    # Rest for a split second to simulate rapid traffic flow
    sleep 0.2
done
