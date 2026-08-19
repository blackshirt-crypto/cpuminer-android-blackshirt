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
2. Ask you for: algorithm, pool, wallet, worker name, password, threads
3. Save your config as `~/cpuminer-blackshirt/start-{algo}.sh`
4. Start mining with a clean colored display

**To mine again after setup:**
```bash
~/cpuminer-blackshirt/start-civiclight.sh
```

**To change settings:**
```bash
~/cpuminer-blackshirt/reconfigure.sh
```

## 🔧 Alternative — Build from Source (Native Compile)

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

CivicNet uses the **civiclight** algorithm: SHA256d → SHA256 → yespower(N=2048, r=8) → XOR → SHA256. CPU-only, ARM-friendly, hardware accelerated with NEON + AES + SHA256.

```bash
~/cpuminer-blackshirt/start-civiclight.sh
# or manually:
~/cpuminer-blackshirt/cpuminer-blackshirt -a civiclight -o stratum+tcp://POOL:PORT -u WALLET -p c=CIVIC -t 6
```

## 📈 civiclight ARM64 Hashrates (observed)

| Device | SoC | Threads | Hashrate |
|--------|-----|---------|----------|
| HMD Vibe 21 | Snapdragon (big.LITTLE) | 6 | ~850 H/s |
| TCL 50 XE | Snapdragon 665 | 8 | ~586 H/s |

> On big.LITTLE SoCs, more threads can lower hashrate. Test 4, 6, and 8 to find your peak.

## 🔑 YIIMP Pool Password Options

Most pools accept `-p x` but YIIMP-based pools support extended options in the password field:

| Password | Effect |
|----------|--------|
| `x` | Standard default |
| `c=CIVIC` | Required for civiclight on NitroPool/YIIMP |
| `c=CIVIC,m=solo` | Solo mining mode on YIIMP |
| `c=CIVIC,ID=MyWorker` | Custom worker name on YIIMP |
| `c=CIVIC,m=solo,ID=XE-1` | Solo mode + custom worker name |

> MiningCore pools (like Blackshirt Pool) use `-p x` and worker name is appended to your wallet address: `-u WALLET.WorkerName`

## ⛏️ Pool Examples

```bash
# Blackshirt Pool (MiningCore, solo)
~/cpuminer-blackshirt/cpuminer-blackshirt -a civiclight -o stratum+tcp://blkshirtpool.com:4353 -u YOUR_CIVIC_ADDRESS.WorkerName -p x -t 6

# NitroPool (YIIMP, proportional)
~/cpuminer-blackshirt/cpuminer-blackshirt -a civiclight -o stratum+tcp://us.nitropool.net:3032 -u YOUR_CIVIC_ADDRESS -p c=CIVIC -t 6

# NitroPool (YIIMP, solo mode)
~/cpuminer-blackshirt/cpuminer-blackshirt -a civiclight -o stratum+tcp://us.nitropool.net:3032 -u YOUR_CIVIC_ADDRESS -p c=CIVIC,m=solo,ID=MyPhone -t 6
```

## 📊 Recommended Thread Settings

| Device Type | Cores | Recommended Threads |
|-------------|-------|-------------------|
| Budget phones | 4-6 cores | 2-4 threads |
| Mid-range phones | 6-8 cores | 4-6 threads |
| Flagship phones | 8+ cores | 6-8 threads |

Test different values — on big.LITTLE chips, fewer threads often wins.

## 🔄 Reconfigure Settings

```bash
~/cpuminer-blackshirt/reconfigure.sh
```

Shows your current config and lets you update pool, wallet, worker, password, or threads.

## ⚠️ Important Notes

### Battery & Heat
- Keep your phone plugged in while mining
- Monitor temperature — stop if overheating
- Remove phone case for better cooling

### Performance Tips
- civiclight and yespower are designed to favor ARM architectures
- Hardware NEON, AES, and SHA256 extensions are active on ARM64
- Test thread counts — the sweet spot varies by phone model

## 🛠️ Keep Mining After Closing Termux

```bash
termux-wake-lock
~/cpuminer-blackshirt/start-civiclight.sh
```

## 🔄 Updating

```bash
curl -L -o setup-cpuminer-blackshirt.sh https://github.com/blackshirt-crypto/cpuminer-android-blackshirt/releases/download/v26.2/setup-cpuminer-blackshirt.sh
chmod +x setup-cpuminer-blackshirt.sh
./setup-cpuminer-blackshirt.sh
```

## 🛠️ Troubleshooting

**Binary won't run:**
- Run `chmod +x ~/cpuminer-blackshirt/cpuminer-blackshirt`
- Confirm ARM64: `uname -m` should show `aarch64`

**Build fails in Termux:**
- Run `pkg update && pkg upgrade` first
- Export TMPDIR: `export TMPDIR=/data/data/com.termux/files/usr/tmp`

**Low hashrate / throttling:**
- Reduce thread count — thermal throttling kills performance
- On big.LITTLE phones try fewer threads

**Miner won't connect:**
- Verify pool address format: `stratum+tcp://HOST:PORT`
- For NitroPool/YIIMP civiclight use `-p c=CIVIC` not `-p x`
- For MiningCore pools use `-p x`

**Not showing on YIIMP pool dashboard:**
- Make sure password is correct for that pool (see YIIMP Password Options above)
- Allow 3-5 minutes after first share for stats to appear

**Unknown algo error:**
- Enter algorithm TYPE not coin ticker: `civiclight` not `CIVIC`, `yescryptr16` not `FNNC`

## 🆘 Resources

- **Source code:** https://github.com/blackshirt-crypto/cpuminer-android-blackshirt
- **Linux version:** https://github.com/blackshirt-crypto/cpuminer-linux-blackshirt
- **Blackshirt Pool:** https://blkshirtpool.com
- **Cell Hasher:** https://cellhasher.com/ — Mobile mining community and Discord
- **Mining Pool Stats:** https://miningpoolstats.stream — Find pools for your coin

## 🤝 Credits & Attribution

- **cpuminer-blackshirt** — ARM/Android optimized fork by [blackshirt-crypto](https://github.com/blackshirt-crypto)
- **cpuminer-opt v26.2** — Original optimized miner by [JayDDee](https://github.com/JayDDee/cpuminer-opt)
- **cpuminer-multi** — Original multi-algo base by [tpruvot](https://github.com/tpruvot/cpuminer-multi)
- **yescrypt/yespower** — Memory-hard KDF by Alexander Peslyak (Solar Designer)
- **civiclight algorithm** — CivicNet / CivicLight developer: [github.com/CivicLight/CivicNet](https://github.com/CivicLight/CivicNet)
- **civic_yespower reference** — nof8 @ [NitroPool](https://nitropool.net) — the namespaced yespower implementation that made civiclight share validation work

All upstream code is open source under GPL-2.0.

## ⚖️ Disclaimer

Mining cryptocurrency consumes significant power and generates heat. Use at your own risk. Monitor device temperature and battery health.

## 📝 License

GPL-2.0 — see [COPYING](COPYING) for full license details.

---
*Built for spec miners. Get in early, mine lean.*
