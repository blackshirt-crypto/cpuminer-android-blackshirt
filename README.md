# cpuminer-android-blackshirt

ARM64 CPU miner for Android/Termux — optimized for **civiclight**, yespower, yescrypt, sha256d, scrypt, and whirlpool. Built for spec mining small coins before difficulty rises.

## 📱 Requirements

- Android device (ARM64/ARMv8 architecture)
- Termux app installed (F-Droid or GitHub — do NOT use Play Store version)
- Stable internet connection
- At least 2GB free storage space
- At least 2GB RAM recommended

## ⚡ Quick Start — One Command Setup (Recommended)

Open Termux and run:

```bash
curl -L -o setup-cpuminer-blackshirt.sh https://github.com/blackshirt-crypto/cpuminer-android-blackshirt/releases/download/v26.2/setup-cpuminer-blackshirt.sh
chmod +x setup-cpuminer-blackshirt.sh
./setup-cpuminer-blackshirt.sh
```

The setup script will:
1. Download the pre-built ARM64 binary into `~/cpuminer-blackshirt/`
2. Ask you for: algorithm, pool, backup pool (optional), wallet, worker name, password, threads
3. Save your config as `~/cpuminer-blackshirt/start-{algo}.sh`
4. Start mining immediately with a clean colored display

**To mine again after setup:**
```bash
~/cpuminer-blackshirt/start-civiclight.sh
```

**To change settings:**
```bash
~/cpuminer-blackshirt/reconfigure.sh
```

## 🔧 Alternative — Download Binary Only

If you just want the raw binary:

```bash
curl -L -o ~/cpuminer-blackshirt https://github.com/blackshirt-crypto/cpuminer-android-blackshirt/releases/download/v26.2/cpuminer-arm64-v26.2
chmod +x ~/cpuminer-blackshirt
~/cpuminer-blackshirt -a civiclight --benchmark -t 6
```

## 🔧 Alternative — Build from Source (Native Compile)

For a device-optimized native build directly on your phone:

```bash
curl -L -o setup_cpuminer.sh https://raw.githubusercontent.com/blackshirt-crypto/cpuminer-android-blackshirt/master/setup_cpuminer.sh
chmod +x setup_cpuminer.sh
./setup_cpuminer.sh
```

## 🎯 Supported Algorithms

Enter the TYPE — not the coin ticker (e.g. type `civiclight` not `CIVIC`):

| Algorithm | Coin | ARM Performance |
|-----------|------|----------------|
| `civiclight` | **CivicNet (CIVIC)** | ✅ Excellent |
| `yespower` | Small yespower coins | ✅ Excellent |
| `yespowerr16` | Yenten (YTN) | ✅ Excellent |
| `yespower-b2b` | blake2b yespower variants | ✅ Excellent |
| `yescrypt` | various yescrypt coins | ✅ Good |
| `yescryptr8` | yescrypt r8 variants | ✅ Good |
| `yescryptr16` | Fennec (FNNC) | ✅ Good |
| `yescryptr32` | yescrypt r32 variants | ✅ Good |
| `sha256d` | Small SHA-256d coins | ✅ Good |
| `scrypt` | Small scrypt coins* | ✅ Good |
| `whirlpool` | CapStash (CAP) | ✅ Good |

> *Scrypt for Litecoin/Dogecoin is ASIC dominated. Focus on smaller coins.

## 🪙 CivicNet (CIVIC) — Featured

CivicNet uses the **civiclight** algorithm: `SHA256d → SHA256 → yespower(N=2048, r=8) → XOR → SHA256`. CPU-only, ARM-friendly, NEON + AES + SHA256 hardware accelerated.

```bash
~/cpuminer-blackshirt/start-civiclight.sh
# or manually:
~/cpuminer-blackshirt/cpuminer-blackshirt -a civiclight -o stratum+tcp://POOL:PORT -u WALLET -p x -t 6
```

## 📈 civiclight ARM64 Hashrates (observed)

Measured on mid-range ARM64 (Snapdragon-class, big.LITTLE):

| Threads | Hashrate | Notes |
|---------|----------|-------|
| 2 | ~505 H/s | efficiency cores only |
| 4 | ~700 H/s | |
| 6 | ~850 H/s | **sweet spot** |
| 8 | ~715 H/s | efficiency-core contention drops output |

> On big.LITTLE SoCs, more threads can mean *lower* hashrate. Test 4, 6, and 8 to find your device's peak.

## ⛏️ Usage Examples

```bash
# civiclight (CivicNet/CIVIC)
~/cpuminer-blackshirt/cpuminer-blackshirt -a civiclight -o stratum+tcp://POOL:PORT -u WALLET -p x -t 6

# yespower
~/cpuminer-blackshirt/cpuminer-blackshirt -a yespower -o stratum+tcp://POOL:PORT -u WALLET -p x -t 6

# yescryptr16 (Fennec/FNNC)
~/cpuminer-blackshirt/cpuminer-blackshirt -a yescryptr16 -o stratum+tcp://POOL:PORT -u WALLET -p x -t 6

# sha256d
~/cpuminer-blackshirt/cpuminer-blackshirt -a sha256d -o stratum+tcp://POOL:PORT -u WALLET -p x -t 4

# whirlpool (CapStash)
~/cpuminer-blackshirt/cpuminer-blackshirt -a whirlpool -o stratum+tcp://POOL:PORT -u WALLET -p x -t 4
```

## 🔥 Benchmark

```bash
~/cpuminer-blackshirt/cpuminer-blackshirt -a civiclight --benchmark -t 6
```

## 📊 Recommended Thread Settings

| Device Type | Cores | Recommended Threads |
|-------------|-------|-------------------|
| Budget phones | 4-6 cores | 2-4 threads |
| Mid-range phones | 6-8 cores | 4-6 threads |
| Flagship phones | 8+ cores | 6-8 threads |

For civiclight on big.LITTLE phones, **6 threads** is typically the sweet spot.

## ⚠️ Important Notes

### Battery & Heat
- Mining is CPU-intensive — keep your phone plugged in
- Monitor device temperature — stop if it gets too hot
- Remove phone case for better cooling if needed

### Performance Tips
- Close other apps while mining
- civiclight and yespower are designed to favor ARM architectures
- Hardware NEON, AES, and SHA256 extensions are active on ARM64

## 🛠️ Keep Mining After Closing Termux

```bash
termux-wake-lock
~/cpuminer-blackshirt/start-civiclight.sh
# To stop: Ctrl+C then termux-wake-unlock
```

## 🔄 Updating

```bash
curl -L -o setup-cpuminer-blackshirt.sh https://github.com/blackshirt-crypto/cpuminer-android-blackshirt/releases/download/v26.2/setup-cpuminer-blackshirt.sh
chmod +x setup-cpuminer-blackshirt.sh
./setup-cpuminer-blackshirt.sh
```

## 🛠️ Troubleshooting

**Binary won't run:**
- Make sure you ran `chmod +x ~/cpuminer-blackshirt/cpuminer-blackshirt`
- Confirm you're on ARM64: `uname -m` should show `aarch64`
- Try building from source with `setup_cpuminer.sh`

**Build fails in Termux:**
- Run `pkg update && pkg upgrade` first
- Ensure 2GB+ free storage
- Export TMPDIR: `export TMPDIR=/data/data/com.termux/files/usr/tmp`

**Low hashrate / throttling:**
- Reduce thread count — thermal throttling hurts performance
- On big.LITTLE phones try 6 threads instead of 8
- Check device temperature

**Miner won't connect:**
- Verify pool address and port format: `stratum+tcp://HOST:PORT`
- Check wallet address format for your coin
- CivicNet: use legacy `C...` address on MiningCore pools; bech32 `civc1...` works on YIIMP pools

**Unknown algo error:**
- Enter the algorithm TYPE not the coin ticker
- Example: `civiclight` not `CIVIC`, `yescryptr16` not `FNNC`

## 🆘 Resources

- **Source code:** https://github.com/blackshirt-crypto/cpuminer-android-blackshirt
- **Linux version:** https://github.com/blackshirt-crypto/cpuminer-linux-blackshirt
- **Blackshirt Pool:** https://blkshirtpool.com
- **Cell Hasher:** https://cellhasher.com/ — Mobile mining community and Discord
- **Mining Pool Stats:** https://miningpoolstats.stream — Find pools for your coin

## 🤝 Credits & Attribution

- **cpuminer-blackshirt** — ARM/Android optimized fork by [blackshirt-crypto](https://github.com/blackshirt-crypto)
- **cpuminer-opt v26.1** — Original optimized miner by [JayDDee](https://github.com/JayDDee/cpuminer-opt)
- **cpuminer-multi** — Original multi-algo base by [tpruvot](https://github.com/tpruvot/cpuminer-multi)
- **yescrypt/yespower** — Memory-hard KDF by Alexander Peslyak (Solar Designer)
- **civiclight algorithm** — CivicNet / CivicLight developer: [github.com/CivicLight/CivicNet](https://github.com/CivicLight/CivicNet)
- **civic_yespower reference** — nof8 @ [NitroPool](https://nitropool.net) — the namespaced yespower implementation that made civiclight share validation work

All upstream code is open source under GPL-2.0.

## ⚖️ Disclaimer

Mining cryptocurrency consumes significant power and generates heat. Use at your own risk. Monitor your device temperature and battery health. Mining profitability varies based on hardware, electricity costs, and market conditions.

## 📝 License

GPL-2.0 — see [COPYING](COPYING) for full license details.

---
*Built for spec miners. Get in early, mine lean.*
