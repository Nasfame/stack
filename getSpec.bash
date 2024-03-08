#!/bin/bash

# RAM
echo "RAM:"
free -h | awk '/^Mem:/{print "Total:", $2, "Used:", $3}'

# CPU
echo "CPU:"
echo "Number of CPU cores:" $(nproc)
echo "CPU model:" $(grep "model name" /proc/cpuinfo | uniq | awk -F: '{print $2}')

# Disk
echo "Disk:"
df -h --total | grep "total" | awk '{print "Total:", $2, "Used:", $3}'

# GPU
echo "GPU:"
if command -v nvidia-smi &> /dev/null; then
    nvidia-smi --query-gpu=name --format=csv,noheader
else
    echo "No GPU detected."
fi
