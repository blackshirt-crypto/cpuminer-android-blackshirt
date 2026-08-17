#!/data/data/com.termux/files/usr/bin/bash

#########################################
# cpuminer-android-blackshirt Setup
# ARM64 optimized CPU miner
# Algorithms: civiclight, yespower family, yescrypt family, sha256d, scrypt, whirlpool
# github.com/blackshirt-crypto
#########################################

echo "========================================="
echo "  cpuminer-android-blackshirt Setup"
echo "  ARM64 Optimized CPU Mining"
echo "========================================="
echo ""

# Step 1: Update Termux
echo "[1/5] Updating Termux packages..."
yes | pkg update && pkg upgrade -y

# Step 2: Install dependencies
echo ""
echo "[2/5] Installing dependencies..."
yes | pkg install git clang build-essential automake autoconf libcurl libjansson openssl pkg-config libtool make libgmp -y

# Step 3: Clone source
echo ""
echo "[3/5] Cloning cpuminer-android-blackshirt..."
cd ~
if [ -d "cpuminer-android-blackshirt" ]; then
    echo "Removing old build directory..."
    rm -rf cpuminer-android-blackshirt
fi

git clone https://github.com/blackshirt-crypto/cpuminer-android-blackshirt.git cpuminer-android-blackshirt
cd cpuminer-android-blackshirt

# Step 4: Build
echo ""
echo "[4/5] Building for ARM64..."
echo "This may take 15-30 minutes, please be patient..."
echo ""

./autogen.sh
./configure CFLAGS="-O3 -march=armv8-a+crypto+sha2+aes -flax-vector-conversions" --with-curl
make -j$(nproc)

# Check if build was successful
if [ -f "cpuminer" ]; then
    cp cpuminer ~/cpuminer-blackshirt
    chmod +x ~/cpuminer-blackshirt
    echo ""
    echo "✓ Build successful!"
else
    echo ""
    echo "✗ Build failed. Trying pre-built binary..."
    curl -L -o ~/cpuminer-blackshirt https://github.com/blackshirt-crypto/cpuminer-android-blackshirt/releases/download/v26.1/cpuminer-arm64
    chmod +x ~/cpuminer-blackshirt
    if ~/cpuminer-blackshirt --version > /dev/null 2>&1; then
        echo "✓ Pre-built binary installed successfully!"
    else
        echo "✗ Installation failed. Check errors above."
        exit 1
    fi
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
echo "  civiclight   - CivicNet (CIVIC), CPU-only, best for ARM (recommended)"
echo "  yespower     - Small CPU coins, great for ARM"
echo "  yespowerr16  - Yenten (YTN) and r16 variants"
echo "  yescrypt     - Yescrypt coins"
echo "  yescryptr16  - Fennec (FNNC)"
echo "  sha256d      - Small SHA-256d coins"
echo "  scrypt       - Small scrypt coins (not LTC/DOGE)"
echo "  whirlpool    - CapStash (CAP), spec mining"
echo ""
read -p "Enter algorithm to mine: " ALGO

echo ""
echo "========================================="
echo "  Primary Pool Configuration"
echo "========================================="
echo ""
echo "Format: pool-address.com:port"
echo ""
read -p "Primary pool address: " PRIMARY_POOL_INPUT
PRIMARY_POOL="stratum+tcp://$PRIMARY_POOL_INPUT"

echo ""
read -p "Add backup pool? (y/n): " ADD_BACKUP
if [[ "$ADD_BACKUP" =~ ^[Yy]$ ]]; then
    read -p "Backup pool address: " BACKUP_POOL_INPUT
    BACKUP_POOL="stratum+tcp://$BACKUP_POOL_INPUT"
    HAS_BACKUP=true
    echo "✓ Backup pool configured"
else
    HAS_BACKUP=false
    BACKUP_POOL="None"
    echo "✓ No backup pool"
fi

echo ""
echo "========================================="
echo "  Wallet Configuration"
echo "========================================="
echo ""
read -p "Wallet address: " WALLET_ADDRESS

echo ""
echo "========================================="
echo "  Worker Configuration"
echo "========================================="
echo ""
echo "Examples: phone-1, pixel-6, miner-01"
read -p "Worker name: " WORKER_NAME

echo ""
read -p "Pool password (default: x): " POOL_PASSWORD
POOL_PASSWORD=${POOL_PASSWORD:-x}

echo ""
echo "========================================="
echo "  Thread Configuration"
echo "========================================="
echo ""
echo "  Budget phones  (4-6 cores): 2-4 threads"
echo "  Mid-range      (6-8 cores): 4-6 threads"
echo "  Flagship       (8+ cores):  6-8 threads"
echo ""
MAX_THREADS=$(nproc)
echo "Your device has $MAX_THREADS CPU cores available."
echo ""
while true; do
    read -p "Number of threads to use (1-$MAX_THREADS): " THREADS
    if [[ "$THREADS" =~ ^[0-9]+$ ]] && [ "$THREADS" -ge 1 ] && [ "$THREADS" -le "$MAX_THREADS" ]; then
        break
    fi
    echo "Please enter a number between 1 and $MAX_THREADS."
done

# Create start.sh
echo ""
echo "Creating mining scripts..."

cat > ~/start.sh << EOF
#!/data/data/com.termux/files/usr/bin/bash

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

~/cpuminer-blackshirt -a $ALGO -o $PRIMARY_POOL -u $WALLET_ADDRESS.$WORKER_NAME -p $POOL_PASSWORD -t $THREADS
EOF

chmod +x ~/start.sh

if [ "$HAS_BACKUP" = true ]; then
    cat > ~/start-backup.sh << EOF
#!/data/data/com.termux/files/usr/bin/bash

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

~/cpuminer-blackshirt -a $ALGO -o $BACKUP_POOL -u $WALLET_ADDRESS.$WORKER_NAME -p $POOL_PASSWORD -t $THREADS
EOF
    chmod +x ~/start-backup.sh
fi

# Save config
cat > ~/mining-config.txt << EOF
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

# Final message
PRIMARY_DISPLAY=${PRIMARY_POOL#stratum+tcp://}
BACKUP_DISPLAY=${BACKUP_POOL#stratum+tcp://}

echo ""
echo "========================================="
echo "  ✓ Setup Complete!"
echo "========================================="
echo ""
echo "Configuration:"
echo "  Algorithm: $ALGO"
echo "  Primary Pool: $PRIMARY_DISPLAY"
if [ "$HAS_BACKUP" = true ]; then
    echo "  Backup Pool: $BACKUP_DISPLAY"
fi
echo "  Wallet: $WALLET_ADDRESS"
echo "  Worker: $WORKER_NAME"
echo "  Threads: $THREADS"
echo ""
echo "========================================="
echo "  Quick Start Commands"
echo "========================================="
echo ""
echo "Start mining:"
echo "  ~/start.sh"
echo ""
if [ "$HAS_BACKUP" = true ]; then
    echo "Start with backup pool:"
    echo "  ~/start-backup.sh"
    echo ""
fi
echo "Change configuration:"
echo "  ~/reconfigure.sh"
echo ""
echo "Benchmark:"
echo "  ~/cpuminer-blackshirt -a $ALGO --benchmark -t $THREADS"
echo ""
echo "========================================="
echo "  Ready to mine!"
echo "========================================="
