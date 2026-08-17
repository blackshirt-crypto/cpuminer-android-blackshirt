#!/usr/bin/env python3
# filter.py — cpuminer-blackshirt output filter
# Reformats raw cpuminer-opt output into clean colored event lines
# Blackshirt Crypto — blkshirtpool.com

import sys
import re
import time
from datetime import datetime

# ANSI colors
GREEN  = '\033[92m'
RED    = '\033[91m'
YELLOW = '\033[93m'
CYAN   = '\033[96m'
WHITE  = '\033[97m'
DIM    = '\033[2m'
RESET  = '\033[0m'

def ts():
    return datetime.now().strftime('%H:%M:%S')

def out(color, msg):
    print(f"{DIM}[{ts()}]{RESET} {color}{msg}{RESET}", flush=True)

# Args
algo    = sys.argv[1] if len(sys.argv) > 1 else 'unknown'
pool    = sys.argv[2] if len(sys.argv) > 2 else ''
threads = sys.argv[3] if len(sys.argv) > 3 else '--'

# Pool display name
try:
    pool_name = pool.split('//')[1].split(':')[0]
except:
    pool_name = pool

# State
hashrate = None
temp     = '--'
block    = '--'
netdiff  = '--'
accepted = 0
rejected = 0
last_hr  = 0
HR_INTERVAL = 5  # seconds

# Header
print(f"{CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{RESET}", flush=True)
print(f"{CYAN}  cpuminer-blackshirt | {algo} | {pool_name}{RESET}", flush=True)
print(f"{CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{RESET}", flush=True)
out(WHITE, f"Starting miner | threads: {threads} | algo: {algo}")

try:
    for raw in sys.stdin:
        line = raw.strip()
        now  = time.time()

        # Connecting
        if 'Stratum connect stratum' in line:
            m = re.search(r'stratum\S+', line)
            if m:
                out(CYAN, f"Connecting to {m.group()}")

        # Connected
        elif 'Stratum connection established' in line:
            out(CYAN, f"Connected | block {block} | netdiff {netdiff}")

        # Connection lost
        elif 'connection failed' in line or 'Stratum connection reset' in line:
            out(RED, "Connection lost | reconnecting...")

        # New block
        elif 'New Block' in line or 'New Stratum Diff' in line or 'New Work' in line:
            b = re.search(r'Block (\d+)', line)
            d = re.search(r'Netdiff ([0-9.]+)', line)
            if b: block = b.group(1)
            if d: netdiff = d.group(1)

        # Hashrate from periodic report
        elif re.search(r'\([0-9]+\.[0-9]+h/s\)', line):
            m = re.search(r'\(([0-9.]+)h/s\)', line)
            if m:
                hashrate = m.group(1)

        # CPU temp
        elif 'CPU temp' in line:
            m = re.search(r'curr (\d+) C', line)
            if m: temp = m.group(1)

        # Accepted share — cpuminer prints "N Accepted N S0 R0"
        elif re.search(r'^\d+ Accepted \d+', line):
            accepted += 1
            d = re.search(r'Submitted Diff ([0-9.e+-]+)', line)
            diff_str = d.group(1) if d else '--'
            total = accepted + rejected
            ratio = f"{100*accepted/total:.1f}%" if total > 0 else "100.0%"
            out(GREEN, f"✓ ACCEPTED  #{accepted} | {ratio} | {rejected} rejected | diff {diff_str}")

        # Rejected share
        elif re.search(r'^\d+ A\d+ S\d+ Rejected', line):
            rejected += 1
            r = re.search(r'Reject reason: (.+)', line)
            reason = r.group(1).strip() if r else 'unknown'
            total = accepted + rejected
            ratio = f"{100*accepted/total:.1f}%" if total > 0 else "0.0%"
            out(RED, f"✗ REJECTED  #{accepted} | {ratio} | {rejected} rejected | {reason}")

        # Block solved
        elif 'BLOCK SOLVED' in line or ('Solved' in line and 'block' in line.lower()):
            out(YELLOW, f"★ BLOCK FOUND  block {block} | submitting...")

        # Hashrate heartbeat every 5 seconds
        if hashrate and (now - last_hr >= HR_INTERVAL):
            out(WHITE, f"Hashrate {hashrate} H/s | temp {temp}C | block {block}")
            last_hr = now

except KeyboardInterrupt:
    print(f"\n{CYAN}Miner stopped.{RESET}", flush=True)
    sys.exit(0)
