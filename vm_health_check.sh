#!/bin/bash

# Threshold for "healthy" (percent utilization)
THRESHOLD=60

# Function to get CPU utilization percentage (average over 1 minute)
get_cpu_usage() {
    # Use top to get the idle percentage, then calculate usage
    CPU_IDLE=$(top -bn1 | grep "Cpu(s)" | awk '{print $8}' | cut -d. -f1)
    CPU_USAGE=$((100 - CPU_IDLE))
    echo "$CPU_USAGE"
}

# Function to get memory utilization percentage
get_mem_usage() {
    MEM_TOTAL=$(free -m | awk '/^Mem:/ {print $2}')
    MEM_USED=$(free -m | awk '/^Mem:/ {print $3}')
    MEM_USAGE=$(awk "BEGIN {printf \"%.0f\", ($MEM_USED/$MEM_TOTAL)*100}")
    echo "$MEM_USAGE"
}

# Function to get disk utilization percentage for root (/)
get_disk_usage() {
    DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
    echo "$DISK_USAGE"
}

# Parse argument
EXPLAIN=false
if [[ "$1" == "explain" ]]; then
    EXPLAIN=true
fi

CPU=$(get_cpu_usage)
MEM=$(get_mem_usage)
DISK=$(get_disk_usage)

HEALTHY=true
REASONS=()

if [ "$CPU" -gt "$THRESHOLD" ]; then
    HEALTHY=false
    REASONS+=("CPU utilization is at ${CPU}% (above ${THRESHOLD}%)")
fi

if [ "$MEM" -gt "$THRESHOLD" ]; then
    HEALTHY=false
    REASONS+=("Memory utilization is at ${MEM}% (above ${THRESHOLD}%)")
fi

if [ "$DISK" -gt "$THRESHOLD" ]; then
    HEALTHY=false
    REASONS+=("Disk utilization is at ${DISK}% (above ${THRESHOLD}%)")
fi

if $HEALTHY; then
    STATUS="healthy"
else
    STATUS="not healthy"
fi

echo "VM Health Status: $STATUS"

if $EXPLAIN; then
    if $HEALTHY; then
        echo "All parameters (CPU, Memory, Disk) are under ${THRESHOLD}% utilization."
        echo "CPU: ${CPU}%, Memory: ${MEM}%, Disk: ${DISK}%"
    else
        echo "Reasons:"
        for REASON in "${REASONS[@]}"; do
            echo " - $REASON"
        done
        echo "CPU: ${CPU}%, Memory: ${MEM}%, Disk: ${DISK}%"
    fi
fi

exit 0
