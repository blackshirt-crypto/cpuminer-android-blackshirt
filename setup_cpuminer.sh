#!/data/data/com.termux/files/usr/bin/bash

#########################################
# cpuminer-android-blackshirt Setup
# ARM/Android optimized CPU miner
# Algorithms: yespower, sha256d, scrypt
# github.com/blackshirt-crypto
#########################################

echo "========================================="
echo "  cpuminer-android-blackshirt Setup"
echo "  ARM Optimized CPU Mining"
echo "========================================="
echo ""

# Step 1: Update Termux
echo "[1/5] Updating Termux packages..."
yes | pkg update && pkg upgrade -y

# Step 2: Install dependencies
echo ""
echo "[2/5] Installing dependencies..."
yes | pkg install git clang build-essential automake autoconf libcurl libjansson openssl pkg-config libtool make gmp -y

# Step 3: Clone cpuminer-blackshirt
echo ""
echo "[3/5] Cloning cpuminer-blackshirt..."
cd ~
if [ -d "cpuminer-blackshirt" ]; then
    echo "Removing old cpuminer-blackshirt directory..."
    rm -rf cpuminer-blackshirt
fi

git clone https://github.com/blackshirt-crypto/cpuminer-blackshirt.git
cd cpuminer-blackshirt

# Step 4: Build
echo ""
echo "[4/5] Building cpuminer-blackshirt for ARM..."
echo "This may take 15-30 minutes, please be patient..."
echo ""

./autogen.sh
./configure CFLAGS="-O2 -march=armv8-a+crypto+sha2+aes -flax-vector-conversions" \
            --with-curl
make

# Check if build was successful
if [ -f "cpuminer" ]; then
    echo ""
    echo "✓ Build successful!"
else
    echo ""
    echo "✗ Build failed. Check errors above."
    echo "You may need to try a different miner for your device."
    exit 1
fi

# Step 5: Interactive configuration
echo ""
echo "[5/5] Configuring mining parameters..."
echo ""
echo "========================================="
echo "  Algorithm Configuration"
echo "========================================="
echo ""
echo "Supported algorithms:"
echo "  • yespower    - Small CPU coins, best for ARM (recommended)"
echo "  • yespower-r16 - yespower r16 variant"
echo "  • yescrypt    - Yescrypt coins"
echo "  • yescryptr16 - Yescrypt r16 variant"
echo "  • sha256d     - Small SHA-256d coins"
echo "  • scrypt      - Small scrypt coins (not LTC/DOGE)"
echo ""
echo "Run ./cpuminer --help to see full algorithm list"
echo ""
read -p "Enter algorithm to mine: " ALGO

echo ""
echo "========================================="
echo "  Primary Pool Configuration"
echo "========================================="
echo ""
echo "Enter primary pool address"
echo "Format: pool-address.com:port"
echo "Example: pool.yespowersugar.com:3333"
echo ""
read -p "Primary pool address: " PRIMARY_POOL_INPUT
PRIMARY_POOL="stratum+tcp://$PRIMARY_POOL_INPUT"

echo ""
echo "========================================="
echo "  Backup Pool Configuration (Optional)"
echo "========================================="
echo ""
read -p "Do you want to add a backup/secondary pool? (y/n): " ADD_BACKUP

if [[ "$ADD_BACKUP" =~ ^[Yy]$ ]]; then
    echo ""
    echo "Enter backup pool address"
    echo "Format: pool-address.com:port"
    echo ""
    read -p "Backup pool address: " BACKUP_POOL_INPUT
    BACKUP_POOL="stratum+tcp://$BACKUP_POOL_INPUT"
    HAS_BACKUP=true
    echo ""
    echo "✓ Backup pool configured: $BACKUP_POOL_INPUT"
else
    HAS_BACKUP=false
    BACKUP_POOL="None"
    echo ""
    echo "✓ No backup pool - using primary only"
fi

echo ""
echo "========================================="
echo "  Wallet Configuration"
echo "========================================="
echo ""
echo "Enter your wallet address for this coin"
echo ""
read -p "Wallet address: " WALLET_ADDRESS

echo ""
echo "========================================="
echo "  Worker Configuration"
echo "========================================="
echo ""
echo "Worker name helps identify this device"
echo "Examples: phone-1, pixel-6, miner-01"
echo ""
read -p "Worker name: " WORKER_NAME

echo ""
echo "========================================="
echo "  Password Configuration"
echo "========================================="
echo ""
echo "Most pools use 'x' as password"
echo ""
read -p "Pool password (default: x): " POOL_PASSWORD
POOL_PASSWORD=${POOL_PASSWORD:-x}

echo ""
echo "========================================="
echo "  Thread Configuration"
echo "========================================="
echo ""
echo "More threads = higher hashrate but more heat"
echo ""
echo "Recommended by device type:"
echo "  Budget phones  (4-6 cores): 2-4 threads"
echo "  Mid-range      (6-8 cores): 4-6 threads"
echo "  Flagship       (8+ cores):  6-8 threads"
echo ""
read -p "Number of threads (default: 4): " THREADS
THREADS=${THREADS:-4}

# Create start.sh
echo ""
echo "Creating mining scripts..."

cat > start.sh << EOF
#!/data/data/com.termux/files/usr/bin/bash
cd ~/cpuminer-blackshirt

echo "========================================="
echo "  Starting cpuminer-blackshirt"
echo "========================================="
echo ""
echo "Algorithm: $ALGO"
echo "Pool: $PRIMARY_POOL_INPUT"
echo "Worker: $WORKER_NAME"
echo "Threads: $THREADS"
echo ""
echo "Press Ctrl+C to stop mining"
echo ""

./cpuminer -a $ALGO -o $PRIMARY_POOL -u $WALLET_ADDRESS.$WORKER_NAME -p $POOL_PASSWORD -t $THREADS
EOF

chmod +x start.sh

# Create backup pool script if configured
if [ "$HAS_BACKUP" = true ]; then
    cat > start-backup.sh << EOF
#!/data/data/com.termux/files/usr/bin/bash
cd ~/cpuminer-blackshirt

echo "========================================="
echo "  Starting cpuminer-blackshirt (BACKUP)"
echo "========================================="
echo ""
echo "Algorithm: $ALGO"
echo "Pool: $BACKUP_POOL_INPUT"
echo "Worker: $WORKER_NAME"
echo "Threads: $THREADS"
echo ""
echo "Press Ctrl+C to stop mining"
echo ""

./cpuminer -a $ALGO -o $BACKUP_POOL -u $WALLET_ADDRESS.$WORKER_NAME -p $POOL_PASSWORD -t $THREADS
EOF

    chmod +x start-backup.sh
fi

# Create reconfigure script
cat > reconfigure.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash

echo "========================================="
echo "  cpuminer-blackshirt Reconfiguration"
echo "========================================="
echo ""
echo "Update mining settings without rebuilding"
echo ""

cd ~/cpuminer-blackshirt

# Load current config if exists
if [ -f "mining-config.txt" ]; then
    echo "Current configuration found. Loading..."
    source mining-config.txt
    echo ""
    echo "Current settings:"
    echo "  Algorithm: $ALGO"
    echo "  Primary Pool: $PRIMARY_POOL"
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
        echo "  yespower, yespower-r16, yescrypt, yescryptr16, sha256d, scrypt"
        echo ""
        read -p "Enter new algorithm: " NEW_ALGO
        ALGO=$NEW_ALGO
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
        read -p "Enter new wallet address: " NEW_WALLET
        WALLET_ADDRESS=$NEW_WALLET
        read -p "Enter new worker name: " NEW_WORKER
        WORKER_NAME=$NEW_WORKER
        ;;
    5)
        echo ""
        read -p "Enter new thread count: " NEW_THREADS
        THREADS=$NEW_THREADS
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

# Full reconfiguration
if [ "$CHANGE_ALL" = true ]; then
    echo ""
    echo "========================================="
    echo "  Full Reconfiguration"
    echo "========================================="
    echo ""
    echo "Supported algorithms:"
    echo "  yespower, yespower-r16, yescrypt, yescryptr16, sha256d, scrypt"
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
    read -p "Threads (default: 4): " THREADS
    THREADS=${THREADS:-4}
fi

PRIMARY_POOL_DISPLAY=${PRIMARY_POOL#stratum+tcp://}
BACKUP_POOL_DISPLAY=${BACKUP_POOL#stratum+tcp://}

# Recreate start.sh
cat > start.sh << INNEREOF
#!/data/data/com.termux/files/usr/bin/bash
cd ~/cpuminer-blackshirt

echo "========================================="
echo "  Starting cpuminer-blackshirt"
echo "========================================="
echo ""
echo "Algorithm: $ALGO"
echo "Pool: $PRIMARY_POOL_DISPLAY"
echo "Worker: $WORKER_NAME"
echo "Threads: $THREADS"
echo ""
echo "Press Ctrl+C to stop mining"
echo ""

./cpuminer -a $ALGO -o $PRIMARY_POOL -u $WALLET_ADDRESS.$WORKER_NAME -p $POOL_PASSWORD -t $THREADS
INNEREOF

chmod +x start.sh

if [ "$HAS_BACKUP" = true ]; then
    cat > start-backup.sh << INNEREOF
#!/data/data/com.termux/files/usr/bin/bash
cd ~/cpuminer-blackshirt

echo "========================================="
echo "  Starting cpuminer-blackshirt (BACKUP)"
echo "========================================="
echo ""
echo "Algorithm: $ALGO"
echo "Pool: $BACKUP_POOL_DISPLAY"
echo "Worker: $WORKER_NAME"
echo "Threads: $THREADS"
echo ""
echo "Press Ctrl+C to stop mining"
echo ""

./cpuminer -a $ALGO -o $BACKUP_POOL -u $WALLET_ADDRESS.$WORKER_NAME -p $POOL_PASSWORD -t $THREADS
INNEREOF
    chmod +x start-backup.sh
fi

# Save configuration
cat > mining-config.txt << INNEREOF
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
echo "  Primary Pool: $PRIMARY_POOL_DISPLAY"
if [ "$HAS_BACKUP" = true ]; then
    echo "  Backup Pool: $BACKUP_POOL_DISPLAY"
fi
echo "  Wallet: $WALLET_ADDRESS"
echo "  Worker: $WORKER_NAME"
echo "  Threads: $THREADS"
echo ""
echo "Start mining:"
echo "  ./start.sh"
echo ""
EOF

chmod +x reconfigure.sh

# Save initial configuration
cat > mining-config.txt << EOF
# cpuminer-blackshirt configuration
# Created: $(date)
ALGO="$ALGO"
PRIMARY_POOL="$PRIMARY_POOL"
BACKUP_POOL="$BACKUP_POOL"
WALLET_ADDRESS="$WALLET_ADDRESS"
WORKER_NAME="$WORKER_NAME"
POOL_PASSWORD="$POOL_PASSWORD"
THREADS="$THREADS"
HAS_BACKUP=$HAS_BACKUP
EOF

# Final success message
PRIMARY_POOL_DISPLAY=${PRIMARY_POOL#stratum+tcp://}
BACKUP_POOL_DISPLAY=${BACKUP_POOL#stratum+tcp://}

echo ""
echo "========================================="
echo "  ✓ cpuminer-blackshirt Setup Complete!"
echo "========================================="
echo ""
echo "Your configuration:"
echo "  Algorithm: $ALGO"
echo "  Primary Pool: $PRIMARY_POOL_DISPLAY"
if [ "$HAS_BACKUP" = true ]; then
    echo "  Backup Pool: $BACKUP_POOL_DISPLAY"
fi
echo "  Wallet: $WALLET_ADDRESS"
echo "  Worker: $WORKER_NAME"
echo "  Password: $POOL_PASSWORD"
echo "  Threads: $THREADS"
echo ""
echo "========================================="
echo "  Quick Start Commands"
echo "========================================="
echo ""
echo "Start mining NOW:"
echo "  cd ~/cpuminer-blackshirt && ./start.sh"
echo ""
if [ "$HAS_BACKUP" = true ]; then
    echo "Start with backup pool:"
    echo "  cd ~/cpuminer-blackshirt && ./start-backup.sh"
    echo ""
fi
echo "Change configuration:"
echo "  cd ~/cpuminer-blackshirt && ./reconfigure.sh"
echo ""
echo "List supported algorithms:"
echo "  cd ~/cpuminer-blackshirt && ./cpuminer --help"
echo ""
echo "========================================="
echo "  Ready to mine!"
echo "========================================="
echo ""
echo "  cd ~/cpuminer-blackshirt && ./start.sh"
echo ""
