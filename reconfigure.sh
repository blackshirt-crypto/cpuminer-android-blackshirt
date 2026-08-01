#!/data/data/com.termux/files/usr/bin/bash

echo "========================================="
echo "  cpuminer-blackshirt Reconfiguration"
echo "========================================="
echo ""
echo "Update mining settings without rebuilding"
echo ""

cd ~

# Load current config
if [ -f "mining-config.txt" ]; then
    echo "Current configuration found. Loading..."
    source mining-config.txt
    echo ""
    echo "Current settings:"
    echo "  Algorithm: $ALGO"
    echo "  Primary Pool: ${PRIMARY_POOL#stratum+tcp://}"
    echo "  Wallet: $WALLET_ADDRESS"
    echo "  Worker: $WORKER_NAME"
    echo "  Threads: $THREADS"
    echo ""
fi

read -p "Press Enter to continue with reconfiguration..."
echo ""

echo "What would you like to change?"
echo ""
echo "1) Everything (full reconfiguration)"
echo "2) Algorithm only"
echo "3) Pools only"
echo "4) Wallet/Worker only"
echo "5) Threads only"
echo ""
read -p "Enter choice (1-5): " RECONFIG_CHOICE

case $RECONFIG_CHOICE in
    1)
        CHANGE_ALL=true
        ;;
    2)
        echo ""
        echo "Supported algorithms:"
        echo "  yespower, yespower-r16, yescrypt, yescryptr16"
        echo "  sha256d, scrypt, whirlpool"
        echo ""
        read -p "Enter new algorithm: " ALGO
        ;;
    3)
        echo ""
        read -p "Enter new primary pool (address:port): " NEW_PRIMARY
        PRIMARY_POOL="stratum+tcp://$NEW_PRIMARY"
        read -p "Update backup pool? (y/n): " UPDATE_BACKUP
        if [[ "$UPDATE_BACKUP" =~ ^[Yy]$ ]]; then
            read -p "Enter new backup pool (address:port): " NEW_BACKUP
            BACKUP_POOL="stratum+tcp://$NEW_BACKUP"
            HAS_BACKUP=true
        fi
        ;;
    4)
        echo ""
        read -p "Enter new wallet address: " WALLET_ADDRESS
        read -p "Enter new worker name: " WORKER_NAME
        ;;
    5)
        echo ""
        echo "  Budget phones  (4-6 cores): 2-4 threads"
        echo "  Mid-range      (6-8 cores): 4-6 threads"
        echo "  Flagship       (8+ cores):  6-8 threads"
        echo ""
        read -p "Enter new thread count: " THREADS
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

if [ "$CHANGE_ALL" = true ]; then
    echo ""
    echo "========================================="
    echo "  Full Reconfiguration"
    echo "========================================="
    echo ""
    echo "Supported algorithms:"
    echo "  yespower, yespower-r16, yescrypt, yescryptr16"
    echo "  sha256d, scrypt, whirlpool"
    echo ""
    read -p "Algorithm: " ALGO
    echo ""
    read -p "Primary pool (address:port): " PRIMARY_INPUT
    PRIMARY_POOL="stratum+tcp://$PRIMARY_INPUT"
    echo ""
    read -p "Add backup pool? (y/n): " ADD_BACKUP
    if [[ "$ADD_BACKUP" =~ ^[Yy]$ ]]; then
        read -p "Backup pool (address:port): " BACKUP_INPUT
        BACKUP_POOL="stratum+tcp://$BACKUP_INPUT"
        HAS_BACKUP=true
    else
        HAS_BACKUP=false
        BACKUP_POOL="None"
    fi
    echo ""
    read -p "Wallet address: " WALLET_ADDRESS
    echo ""
    read -p "Worker name: " WORKER_NAME
    echo ""
    read -p "Pool password (default: x): " POOL_PASSWORD
    POOL_PASSWORD=${POOL_PASSWORD:-x}
    echo ""
    echo "  Budget phones  (4-6 cores): 2-4 threads"
    echo "  Mid-range      (6-8 cores): 4-6 threads"
    echo "  Flagship       (8+ cores):  6-8 threads"
    echo ""
    read -p "Threads (default: 4): " THREADS
    THREADS=${THREADS:-4}
fi

PRIMARY_DISPLAY=${PRIMARY_POOL#stratum+tcp://}
BACKUP_DISPLAY=${BACKUP_POOL#stratum+tcp://}

# Recreate start.sh
cat > ~/start.sh << INNEREOF
#!/data/data/com.termux/files/usr/bin/bash

echo "========================================="
echo "  Starting cpuminer-blackshirt"
echo "========================================="
echo ""
echo "Algorithm: $ALGO"
echo "Pool: $PRIMARY_DISPLAY"
echo "Worker: $WORKER_NAME"
echo "Threads: $THREADS"
echo ""
echo "Press Ctrl+C to stop mining"
echo ""

~/cpuminer-blackshirt -a $ALGO -o $PRIMARY_POOL -u $WALLET_ADDRESS.$WORKER_NAME -p $POOL_PASSWORD -t $THREADS
INNEREOF

chmod +x ~/start.sh

if [ "$HAS_BACKUP" = true ]; then
    cat > ~/start-backup.sh << INNEREOF
#!/data/data/com.termux/files/usr/bin/bash

echo "========================================="
echo "  Starting cpuminer-blackshirt (BACKUP)"
echo "========================================="
echo ""
echo "Algorithm: $ALGO"
echo "Pool: $BACKUP_DISPLAY"
echo "Worker: $WORKER_NAME"
echo "Threads: $THREADS"
echo ""
echo "Press Ctrl+C to stop mining"
echo ""

~/cpuminer-blackshirt -a $ALGO -o $BACKUP_POOL -u $WALLET_ADDRESS.$WORKER_NAME -p $POOL_PASSWORD -t $THREADS
INNEREOF
    chmod +x ~/start-backup.sh
fi

# Save config
cat > ~/mining-config.txt << INNEREOF
# cpuminer-blackshirt configuration
# Last updated: $(date)
ALGO="$ALGO"
PRIMARY_POOL="$PRIMARY_POOL"
BACKUP_POOL="$BACKUP_POOL"
WALLET_ADDRESS="$WALLET_ADDRESS"
WORKER_NAME="$WORKER_NAME"
POOL_PASSWORD="$POOL_PASSWORD"
THREADS="$THREADS"
HAS_BACKUP=$HAS_BACKUP
INNEREOF

echo ""
echo "========================================="
echo "  ✓ Reconfiguration Complete!"
echo "========================================="
echo ""
echo "New configuration:"
echo "  Algorithm: $ALGO"
echo "  Primary Pool: $PRIMARY_DISPLAY"
if [ "$HAS_BACKUP" = true ]; then
    echo "  Backup Pool: $BACKUP_DISPLAY"
fi
echo "  Wallet: $WALLET_ADDRESS"
echo "  Worker: $WORKER_NAME"
echo "  Threads: $THREADS"
echo ""
echo "Start mining:"
echo "  ~/start.sh"
echo ""
