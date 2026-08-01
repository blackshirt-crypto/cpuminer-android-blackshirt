# cpuminer-android-blackshirt

Automated setup and pre-built binary for CPU mining on Android devices using Termux. Optimized for ARM64 with yespower, sha256d, scrypt, and whirlpool algorithms — built for spec mining small coins before difficulty rises.

## 📱 Requirements

- Android device (ARM64/ARMv8 architecture)
- Termux app installed (F-Droid or GitHub — do NOT use Play Store version)
- Stable internet connection
- At least 2GB free storage space
- At least 2GB RAM recommended

## ⚡ Quick Start — Pre-built Binary (Fastest)

Open Termux and run:

```bash
curl -L -o ~/cpuminer-blackshirt https://github.com/blackshirt-crypto/cpuminer-android-blackshirt/releases/download/v26.1/cpuminer-arm64
chmod +x ~/cpuminer-blackshirt
~/cpuminer-blackshirt --version
```

Then start mining:
```bash
~/cpuminer-blackshirt -a yespower -o stratum+tcp://POOL:PORT -u WALLET -p x -t 4
```

## 🔧 Alternative — Build from Source (Native Compile)

For users who want a device-optimized native build:

```bash
curl -O https://raw.githubusercontent.com/blackshirt-crypto/cpuminer-android-blackshirt/master/setup_cpuminer.sh
chmod +x setup_cpuminer.sh
./setup_cpuminer.sh
```

The setup script will install dependencies, clone the source, compile natively on your device, and walk you through configuration interactively.

## 🎯 Supported Algorithms

| Algorithm | Target Coins | ARM Performance |
|-----------|-------------|----------------|
| `yespower` | Cryply, CPUpower, Sugar | ✅ Excellent |
| `yespower-r16` | Yenten (YTN) | ✅ Excellent |
| `yescrypt` | Fennec (FNNC), various | ✅ Good |
| `yescryptr16` | Yescrypt r16 variants | ✅ Good |
| `sha256d` | Small SHA-256d coins | ✅ Good |
| `scrypt` | Small scrypt coins* | ✅ Good |
| `whirlpool` | Capstash, spec mining | ✅ Good |

> *Scrypt for Litecoin/Dogecoin is ASIC dominated. Focus on smaller coins.

## ⛏️ Usage Examples

```bash
# yespower (recommended for ARM)
~/cpuminer-blackshirt -a yespower -o stratum+tcp://POOL:PORT -u WALLET -p x -t 4

# yescrypt (Fennec/FNNC)
~/cpuminer-blackshirt -a yescryptr16 -o stratum+tcp://POOL:PORT -u WALLET -p x -t 4

# sha256d
~/cpuminer-blackshirt -a sha256d -o stratum+tcp://POOL:PORT -u WALLET -p x -t 4

# whirlpool (Capstash)
~/cpuminer-blackshirt -a whirlpool -o stratum+tcp://POOL:PORT -u WALLET -p x -t 4
```

## 🔥 Benchmark

```bash
~/cpuminer-blackshirt -a yespower --benchmark -t 4
```

## 📊 Recommended Thread Settings

| Device Type | Cores | Recommended Threads |
|-------------|-------|-------------------|
| Budget phones | 4-6 cores | 2-4 threads |
| Mid-range phones | 6-8 cores | 4-6 threads |
| Flagship phones | 8+ cores | 6-8 threads |

Start with fewer threads and increase gradually while monitoring temperature.

## 🔄 Reconfigure Mining Settings

After initial setup, change pools, wallet, algo, or threads without rebuilding:

```bash
cd ~ && ./reconfigure.sh
```

## ⚠️ Important Notes

### Battery & Heat
- Mining is CPU-intensive and will drain battery quickly
- Keep your phone plugged in while mining
- Monitor device temperature — stop if it gets too hot
- Consider removing phone case for better cooling

### Performance Tips
- Close other apps while mining
- yespower is specifically designed to favor ARM architectures
- Hardware SHA256, NEON, and AES extensions are active on ARM64

## 🛠️ Keep Mining After Closing Termux

```bash
termux-wake-lock
~/cpuminer-blackshirt -a yespower -o stratum+tcp://POOL:PORT -u WALLET -p x -t 4
# To stop: Ctrl+C then termux-wake-unlock
```

## 🔄 Updating Binary

```bash
curl -L -o ~/cpuminer-blackshirt https://github.com/blackshirt-crypto/cpuminer-android-blackshirt/releases/download/v26.1/cpuminer-arm64
chmod +x ~/cpuminer-blackshirt
```

## 🛠️ Troubleshooting

**Binary won't run:**
- Make sure you ran `chmod +x ~/cpuminer-blackshirt`
- Try building from source instead using the setup script

**Build fails:**
- Run `pkg update && pkg upgrade` first
- Ensure 2GB+ free storage

**Low hashrate:**
- Reduce thread count — thermal throttling hurts performance
- Check if phone is overheating
- Try yespower-r16 instead of yespower

**Miner won't connect:**
- Verify pool address and port
- Check wallet address format for your coin

## 🆘 Resources

- **Source code:** https://github.com/blackshirt-crypto/cpuminer-android-blackshirt
- **Linux version:** https://github.com/blackshirt-crypto/cpuminer-linux-blackshirt
- **Cell Hasher:** https://cellhasher.com/ — Mobile mining community and Discord
- **Mining Pool Stats:** https://miningpoolstats.stream — Find pools for your coin

## 🤝 Credits & Attribution

- **cpuminer-blackshirt** — ARM/Android optimized fork by [blackshirt-crypto](https://github.com/blackshirt-crypto)
- **cpuminer-opt v26.1** — Original optimized miner by [JayDDee](https://github.com/JayDDee/cpuminer-opt)
- **cpuminer-multi** — Original multi-algo base by [tpruvot](https://github.com/tpruvot/cpuminer-multi)
- **yescrypt/yespower** — Memory-hard KDF by Alexander Peslyak (Solar Designer)

All upstream code is open source under GPL-2.0.

## ⚖️ Disclaimer

Mining cryptocurrency consumes significant power and generates heat. Use at your own risk. Monitor your device temperature and battery health. Mining profitability varies based on hardware, electricity costs, and market conditions.

## 📝 License

GPL-2.0 — see [COPYING](COPYING) for full license details.

---
*Built for spec miners. Get in early, mine lean.*
