cat > /tmp/README.md << 'EOF'
# cpuminer-android-blackshirt

Automated setup script for CPU mining on Android devices using cpuminer-blackshirt in Termux. Optimized for ARM/Android with yespower, sha256d, and scrypt algorithms — built for spec mining small coins before difficulty rises.

## 📱 Requirements

- Android device (ARM64/ARMv8 architecture)
- Termux app installed (F-Droid or GitHub — do NOT use Play Store version)
- Stable internet connection
- At least 2GB free storage space
- At least 2GB RAM recommended
- Mining pool and wallet address for your target coin

## ⚡ Quick Start

### 1. Install Termux

Download and install Termux from [F-Droid](https://f-droid.org/packages/com.termux/) (recommended) or [GitHub releases](https://github.com/termux/termux-app/releases). Do not use the Play Store version as it is outdated.

### 2. Download and Run Setup Script

Open Termux and run:

```bash
curl -O https://raw.githubusercontent.com/blackshirt-crypto/cpuminer-android-blackshirt/main/setup_cpuminer.sh
chmod +x setup_cpuminer.sh
./setup_cpuminer.sh
```

### 3. Start Mining

After setup completes:

```bash
cd ~/cpuminer-blackshirt
./cpuminer -a yespower -o stratum+tcp://POOL:PORT -u WALLET -p x
```

## 🔧 What the Script Does

- Updates Termux packages
- Installs required dependencies (git, build tools, curl, openssl, jansson)
- Clones cpuminer-blackshirt — ARM/Android optimized fork
- Configures build with ARM NEON SIMD flags for maximum hashrate
- Compiles the miner (takes 15-30 minutes depending on device)

## 🎯 Supported Algorithms

| Algorithm | Target Coins | ARM Performance |
|-----------|-------------|----------------|
| `yespower` | Cryply, CPUpower, various small coins | ✅ Excellent |
| `yespower-r16` | Yenten (YTN), yespower r16 variants | ✅ Excellent |
| `yescrypt` | Yescrypt coins | ✅ Good |
| `yescryptr16` | Yescrypt r16 variants | ✅ Good |
| `sha256d` | Small SHA-256d coins | ✅ Good |
| `scrypt` | Small scrypt coins (not LTC/DOGE) | ✅ Good |

> **Note:** Scrypt for Litecoin and Dogecoin is completely dominated by ASIC hardware. Focus on smaller coins where CPU mining is still competitive.

## ⛏️ Usage Examples

```bash
cd ~/cpuminer-blackshirt

# yespower (recommended for ARM)
./cpuminer -a yespower -o stratum+tcp://POOL:PORT -u WALLET -p x -t 4

# yespower-r16
./cpuminer -a yespower-r16 -o stratum+tcp://POOL:PORT -u WALLET -p x -t 4

# sha256d
./cpuminer -a sha256d -o stratum+tcp://POOL:PORT -u WALLET -p x -t 4

# scrypt
./cpuminer -a scrypt -o stratum+tcp://POOL:PORT -u WALLET -p x -t 4

# yescrypt
./cpuminer -a yescrypt -o stratum+tcp://POOL:PORT -u WALLET -p x -t 4
```

## 📊 Recommended Thread Settings

| Device Type | Cores | Recommended Threads |
|-------------|-------|-------------------|
| Budget phones | 4-6 cores | 2-4 threads |
| Mid-range phones | 6-8 cores | 4-6 threads |
| Flagship phones | 8+ cores | 6-8 threads |

Start with fewer threads and increase gradually while monitoring temperature.

## 🔥 Benchmark

Test your hashrate before connecting to a pool:

```bash
cd ~/cpuminer-blackshirt
./cpuminer -a yespower --benchmark -t 4
```

## ⚠️ Important Notes

### Battery & Heat
- Mining is CPU-intensive and will drain battery quickly
- Keep your phone plugged in while mining
- Monitor device temperature — stop if it gets too hot
- Consider removing phone case for better cooling
- Avoid mining on devices with poor cooling

### Performance Tips
- Close other apps while mining
- Enable Performance mode in phone settings if available
- yespower is specifically designed to favor ARM architectures
- cpuminer-blackshirt includes ARM NEON SIMD optimizations for improved hashrate

## 🛠️ Keep Mining After Closing Termux

```bash
# Acquire wakelock to keep Termux running in background
termux-wake-lock

# Start mining
cd ~/cpuminer-blackshirt
./cpuminer -a yespower -o stratum+tcp://POOL:PORT -u WALLET -p x

# To stop
# Press Ctrl+C then run:
termux-wake-unlock
```

## 🔄 Updating

```bash
cd ~/cpuminer-blackshirt
git pull
make
```

## 🛠️ Troubleshooting

**Build fails:**
- Ensure 2GB+ free storage
- Run `pkg update && pkg upgrade` first
- Try: `./configure --disable-assembly CFLAGS="-O2 -march=armv8-a" && make`

**Low hashrate:**
- Reduce thread count — thermal throttling hurts performance
- Check if phone is overheating
- Try yespower-r16 instead of yespower

**Miner won't connect:**
- Verify pool address and port
- Check wallet address format for your coin
- Try a different pool

## 📁 File Structure

~/cpuminer-blackshirt/
├── cpuminer          # Main miner binary
├── algo/             # Algorithm implementations
└── yescrypt/         # yescrypt/yespower core with ARM NEON optimizations

## 🆘 Resources

- **cpuminer-blackshirt repo:** https://github.com/blackshirt-crypto/cpuminer-blackshirt
- **Cell Hasher:** https://cellhasher.com/ — Mobile mining community and Discord
- **Mining Pool Stats:** https://miningpoolstats.stream — Find pools for your target coin

## 🤝 Credits & Attribution

- **cpuminer-blackshirt** — ARM/Android optimized fork by [blackshirt-crypto](https://github.com/blackshirt-crypto)
- **cpuminer-multi** — Original multi-algorithm miner by [tpruvot](https://github.com/tpruvot/cpuminer-multi)
- **yescrypt/yespower** — Memory-hard KDF by Alexander Peslyak (Solar Designer)

All upstream code is open source under GPL-2.0. See the [original cpuminer-multi repository](https://github.com/tpruvot/cpuminer-multi) for full license details.

## ⚖️ Disclaimer

Mining cryptocurrency consumes significant power and generates heat. Use at your own risk. Monitor your device temperature and battery health. Mining profitability varies based on hardware, electricity costs, and market conditions. This project is provided for educational and experimental purposes.
EOF
echo "Written ok"
wc -l /tmp/README.md
