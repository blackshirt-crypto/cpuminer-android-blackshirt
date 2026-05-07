#!/bin/bash
# cpuminer-android-blackshirt setup script
# Builds cpuminer-blackshirt on Android/Termux
# Optimized for ARM/Android - yespower, sha256d, scrypt
# github.com/blackshirt-crypto/cpuminer-android-blackshirt

set -e

echo "============================================"
echo "  cpuminer-android-blackshirt installer"
echo "  github.com/blackshirt-crypto"
echo "============================================"
echo ""

# Step 1: Update and install dependencies
echo "[1/5] Installing dependencies..."
pkg update -y
pkg install -y git build-essential automake autoconf libcurl libjansson openssl pkg-config libtool

echo ""
echo "[2/5] Cloning cpuminer-blackshirt..."
cd ~
rm -rf cpuminer-blackshirt
git clone https://github.com/blackshirt-crypto/cpuminer-blackshirt.git
cd cpuminer-blackshirt

echo ""
echo "[3/5] Running autogen..."
./autogen.sh

echo ""
echo "[4/5] Configuring for ARM Android..."
./configure CFLAGS="-O3 -march=armv8-a -mfpu=neon" \
            CXXFLAGS="-O3 -march=armv8-a -mfpu=neon" \
            --with-curl \
            --disable-assembly

echo ""
echo "[5/5] Building... (this may take 15-30 minutes)"
make -j$(nproc)

# Check if build was successful
if [ -f "cpuminer" ]; then
    echo ""
    echo "============================================"
    echo "  Build successful!"
    echo "  Binary: ~/cpuminer-blackshirt/cpuminer"
    echo "============================================"
    echo ""
    echo "Example usage:"
    echo ""
    echo "  yespower:"
    echo "  ./cpuminer -a yespower -o stratum+tcp://POOL:PORT -u WALLET -p x"
    echo ""
    echo "  sha256d:"
    echo "  ./cpuminer -a sha256d -o stratum+tcp://POOL:PORT -u WALLET -p x"
    echo ""
    echo "  scrypt:"
    echo "  ./cpuminer -a scrypt -o stratum+tcp://POOL:PORT -u WALLET -p x"
    echo ""
    echo "  yescrypt:"
    echo "  ./cpuminer -a yescrypt -o stratum+tcp://POOL:PORT -u WALLET -p x"
    echo ""
else
    echo ""
    echo "  Build failed. Check errors above."
    echo "  Try: ./configure --disable-assembly"
    exit 1
fi
