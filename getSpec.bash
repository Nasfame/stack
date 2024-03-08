#!/bin/bash

# RAM
echo -n "RAM:"
free -h | awk '/^Mem:/{print "Total:", $2, "Used:", $3}'

# CPU
echo -n  "CPU:"
echo "Number of CPU cores:" $(nproc)
echo "CPU model:" $(grep "model name" /proc/cpuinfo | uniq | awk -F: '{print $2}')

# Disk
echo -n "Disk: Total: "
df -h | awk '/^\/dev/{total+=$2; used+=$3} END {printf "%s Used: %s\n", total, used}'

# GPU
echo -n "GPU:"
if command -v nvidia-smi &> /dev/null; then
    nvidia-smi --query-gpu=name --format=csv,noheader
else
    echo "No GPU detected."
fi
