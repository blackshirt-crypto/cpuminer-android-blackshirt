#!/bin/bash
# cpuminer-blackshirt reconfigure script
# Lists saved start scripts and lets user update any setting
# Blackshirt Crypto — blkshirtpool.com

echo ""
echo "  cpuminer-blackshirt — Reconfigure"
echo "  ==================================="
echo ""

SAVED=(~/cpuminer-blackshirt/start-*.sh)

if [ ${#SAVED[@]} -eq 0 ] || [ ! -f "${SAVED[0]}" ]; then
    echo "No saved mining configs found."
    echo "Run ~/start.sh to create one."
    echo ""
    exit 0
fi

echo "Saved mining configs:"
echo ""
i=1
for f in "${SAVED[@]}"; do
    ALGO=$(basename "$f" .sh | sed 's/start-//')
    POOL=$(grep '\-o ' "$f" | grep -oE 'stratum[^ ]+' | head -1)
    THREADS=$(grep '\-t ' "$f" | grep -oE '\-t [0-9]+' | grep -oE '[0-9]+')
    echo "  $i) start-${ALGO}.sh  |  pool: $POOL  |  threads: $THREADS"
    i=$((i+1))
done

echo ""
echo "  $i) Create a new config (run start.sh)"
echo "  0) Exit"
echo ""
read -p "Choose a config to edit (0-$((i))): " CHOICE

if [ "$CHOICE" = "0" ]; then
    echo "Exiting."
    exit 0
fi

if [ "$CHOICE" = "$i" ]; then
    exec ~/cpuminer-blackshirt/setup-cpuminer-blackshirt.sh
fi

if ! [[ "$CHOICE" =~ ^[0-9]+$ ]] || [ "$CHOICE" -lt 1 ] || [ "$CHOICE" -gt $((i-1)) ]; then
    echo "Invalid choice."
    exit 1
fi

SELECTED="${SAVED[$((CHOICE-1))]}"
ALGO=$(basename "$SELECTED" .sh | sed 's/start-//')

echo ""
echo "Editing: $SELECTED"
echo ""
echo "What would you like to change?"
echo "  1) Pool address"
echo "  2) Wallet address"
echo "  3) Worker name"
echo "  4) Password"
echo "  5) Threads"
echo "  6) Recreate entire config (re-run setup for this algo)"
echo "  0) Cancel"
echo ""
read -p "Choice: " WHAT

case $WHAT in
    1)
        read -p "New pool address: " NEW
        sed -i "s|-o [^ ]*|-o $NEW|" "$SELECTED"
        echo "Pool updated."
        ;;
    2)
        read -p "New wallet address: " NEW
        WORKER=$(grep '\-u ' "$SELECTED" | grep -oE '\.[a-zA-Z0-9_-]+' | head -1)
        sed -i "s|-u [^ ]*|-u ${NEW}${WORKER}|" "$SELECTED"
        echo "Wallet updated."
        ;;
    3)
        read -p "New worker name (leave blank to remove): " NEW
        WALLET=$(grep '\-u ' "$SELECTED" | grep -oE '\-u [^ ]+' | sed 's/-u //' | cut -d'.' -f1)
        if [ -n "$NEW" ]; then
            sed -i "s|-u [^ ]*|-u ${WALLET}.${NEW}|" "$SELECTED"
        else
            sed -i "s|-u [^ ]*|-u ${WALLET}|" "$SELECTED"
        fi
        echo "Worker updated."
        ;;
    4)
        read -p "New password: " NEW
        sed -i "s|-p [^ ]*|-p $NEW|" "$SELECTED"
        echo "Password updated."
        ;;
    5)
        MAX_THREADS=$(nproc)
        echo "Your device has $MAX_THREADS CPU cores available."
        while true; do
            read -p "New thread count (1-$MAX_THREADS): " NEW
            if [[ "$NEW" =~ ^[0-9]+$ ]] && [ "$NEW" -ge 1 ] && [ "$NEW" -le "$MAX_THREADS" ]; then
                break
            fi
            echo "Please enter a number between 1 and $MAX_THREADS."
        done
        sed -i "s|-t [0-9]*|-t $NEW|" "$SELECTED"
        echo "Threads updated."
        ;;
    6)
        rm "$SELECTED"
        exec ~/cpuminer-blackshirt/setup-cpuminer-blackshirt.sh
        ;;
    0)
        echo "Cancelled."
        exit 0
        ;;
    *)
        echo "Invalid choice."
        exit 1
        ;;
esac

echo ""
echo "Config saved. Run $SELECTED to start mining."
echo ""
