#!/bin/bash

# RAM
echo -n "RAM: "
if [[ $(uname) == "Linux" ]]; then
    free -h | awk '/^Mem:/{print "Total:", $2, "Used:", $3}'
elif [[ $(uname) == "Darwin" ]]; then
    total=$(vm_stat | awk '/Pages free/ {free=$3} /Pages active/ {active=$3} /Pages inactive/ {inactive=$3} /Pages speculative/ {speculative=$3} /Pages wired down/ {wired=$3} END {total=(free+active+inactive+speculative+wired)*4096/1024^3; print total}')
    used=$(vm_stat | awk '/Pages active/ {active=$3} /Pages inactive/ {inactive=$3} /Pages speculative/ {speculative=$3} /Pages wired down/ {wired=$3} END {used=((active+speculative+wired)*4096)/1024^3; print used}')
    echo "Total: ${total}G Used: ${used}G"
fi
echo 
# CPU
echo -n  "CPU: $(uname -m) "
echo
echo "Number of CPU cores:" $(nproc --all)
echo "Number of Available CPU cores:" $(nproc)
if [[ $(uname) == "Linux" ]]; then
    echo "CPU model:" $(grep "model name" /proc/cpuinfo | uniq | awk -F: '{print $2}')
elif [[ $(uname) == "Darwin" ]]; then
    echo "CPU model:" $(sysctl -n machdep.cpu.brand_string)
fi
echo 
# Disk
echo -n "Disk: Total: "
df -h | awk '/^\/dev/{total+=$2; used+=$3} END {printf "%s Used: %s\n", total, used}'

echo 
# GPU
echo -n "GPU: "
if command -v nvidia-smi &> /dev/null; then
    nvidia-smi --query-gpu=name --format=csv,noheader
else
    echo "No GPU detected."
fi
