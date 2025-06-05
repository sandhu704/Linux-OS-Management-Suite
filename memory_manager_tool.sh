#!/bin/bash
#
# memory_manager_tool.sh
# A script to monitor and manage memory usage.
#
# Usage:
#   ./memory_manager_tool.sh
#       Display current memory usage (total, used, free).
#
#   ./memory_manager_tool.sh -p <MB>
#       List processes consuming more than <MB> of memory.
#
#   ./memory_manager_tool.sh -c
#       Clear cache and buffers to free up memory.
#
#   ./memory_manager_tool.sh -l <MB>
#       Alert if available memory is below <MB> megabytes.

print_usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -p <MB>        List processes using more than <MB> MB of memory"
    echo "  -c             Clear cache and buffers (requires root privileges)"
    echo "  -l <MB>        Alert if available memory is below <MB> MB"
    echo "  -h             Display this help message"
}

# If no arguments: show memory usage
if [[ $# -eq 0 ]]; then
    echo "Current memory usage (in MB):"
    free -m
    exit 0
fi

while getopts ":p:cl:h" opt; do
    case $opt in
        p)
            MIN_MB="$OPTARG"
            if ! [[ "$MIN_MB" =~ ^[0-9]+$ ]]; then
                echo "Error: <MB> must be an integer." >&2
                exit 1
            fi
            echo "Processes consuming more than $MIN_MB MB of memory:"
            # ps outputs RSS in KB; convert to MB
            ps aux --sort=-rss | awk -v min="$MIN_MB" 'NR==1 {printf "%s\t%s\t%s\t%s\t%s\n", "PID", "USER", "RSS(MB)", "%MEM", "CMD"; next}
            {
                rss_mb = $6/1024
                if (rss_mb > min) {
                    printf "%s\t%s\t%.2f\t%s%%\t%s\n", $2, $1, rss_mb, $4, $11
                }
            }'
            ;;
        c)
            if [[ $EUID -ne 0 ]]; then
                echo "Error: Clearing cache requires root privileges." >&2
                exit 1
            fi
            echo "Clearing cache and buffers..."
            sync
            echo 3 > /proc/sys/vm/drop_caches
            echo "Caches cleared."
            ;;
        l)
            ALERT_MB="$OPTARG"
            if ! [[ "$ALERT_MB" =~ ^[0-9]+$ ]]; then
                echo "Error: <MB> must be an integer." >&2
                exit 1
            fi
            available_kb=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
            available_mb=$(( available_kb / 1024 ))
            echo "Available memory: ${available_mb} MB"
            if (( available_mb < ALERT_MB )); then
                echo "ALERT: Available memory (${available_mb} MB) is below threshold (${ALERT_MB} MB)."
            else
                echo "Available memory (${available_mb} MB) is above threshold."
            fi
            ;;
        h)
            print_usage
            exit 0
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            print_usage
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            print_usage
            exit 1
            ;;
    esac
done
