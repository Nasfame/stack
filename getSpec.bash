#!/bin/bash

# Function to get RAM information
get_ram_info() {
    echo -n "RAM: "
    if [[ $(uname) == "Linux" ]]; then
        free -h | awk '/^Mem:/{print "Total:", $2, "Used:", $3}'
    elif [[ $(uname) == "Darwin" ]]; then
        total=$(vm_stat | awk '/Pages free/ {free=$3} /Pages active/ {active=$3} /Pages inactive/ {inactive=$3} /Pages speculative/ {speculative=$3} /Pages wired down/ {wired=$3} END {total=(free+active+inactive+speculative+wired)*4096/1024^3; print total}')
        used=$(vm_stat | awk '/Pages active/ {active=$3} /Pages inactive/ {inactive=$3} /Pages speculative/ {speculative=$3} /Pages wired down/ {wired=$3} END {used=((active+speculative+wired)*4096)/1024^3; print used}')
        echo "Total: ${total}G Used: ${used}G"
    fi
}

# Function to get CPU information
get_cpu_info() {
    echo -n "CPU: $(uname -m) "
    echo
    echo "Number of CPU cores:" $(nproc --all)
    echo "Number of Available CPU cores:" $(nproc)
    if [[ $(uname) == "Linux" ]]; then
        echo "CPU model:" $(grep "model name" /proc/cpuinfo | uniq | awk -F: '{print $2}')
    elif [[ $(uname) == "Darwin" ]]; then
        echo "CPU model:" $(sysctl -n machdep.cpu.brand_string)
    fi
}

# Function to get Disk information
get_disk_info() {
    echo -n "Disk: Total: "
    df -h | awk '/^\/dev/{total+=$2; used+=$3} END {printf "%s Used: %s\n", total, used}'
}

# Function to get GPU information
get_gpu_info() {
    echo -n "GPU: "
    if command -v nvidia-smi &> /dev/null; then
        nvidia-smi --query-gpu=name --format=csv,noheader
        echo "NVIDIA GPUs: $(get_nvidia_gpu_count)"
    fi

    if command -v lspci &> /dev/null; then
        amd_gpus=$(lspci | grep -i vga | grep -i amd | cut -d '"' -f 2)
        if [[ -n $amd_gpus ]]; then
            echo "$amd_gpus"
            echo "AMD GPUs: $(get_amd_gpu_count)"
        fi
    fi

    if [[ $(uname) == "Darwin" ]]; then
        echo "Apple GPUs: $(echo `get_macos_gpu_count`)"
    fi

    if command -v lspci &> /dev/null && [[ -z $(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null) && -z $(lspci | grep -i vga | grep -i amd | cut -d '"' -f 2) && $(uname) != "Darwin" ]]; then
        echo "No GPU detected."
    fi
}

# Function to get the number of NVIDIA GPUs
get_nvidia_gpu_count() {
    nvidia-smi --list-gpus | wc -l
}

# Function to get the number of AMD GPUs
get_amd_gpu_count() {
    lspci | grep -i vga | grep -i amd | wc -l
}

# Function to get the number of GPUs on macOS (supports both AMD and NVIDIA)
get_macos_gpu_count() {
    system_profiler SPDisplaysDataType | grep Chipset | wc -l
}

# Main function to display system information
main() {
    get_ram_info
    echo
    get_cpu_info
    echo
    get_disk_info
    echo
    get_gpu_info
}

# Execute main function
main
