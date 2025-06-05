#!/bin/bash
#
# network_monitor_tool.sh
# A script to manage and monitor network activity.
#
# Usage:
#   ./network_monitor_tool.sh
#       Display IP addresses and status of active network interfaces.
#
#   ./network_monitor_tool.sh -b
#       Show current bandwidth usage for each interface (one snapshot).
#
#   ./network_monitor_tool.sh -w <IP_ADDRESS>
#       Monitor network connections; alert if <IP_ADDRESS> connects.
#
#   ./network_monitor_tool.sh -l <INTERVAL> <LOGFILE>
#       Track network traffic every INTERVAL seconds, logging to LOGFILE.

print_usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -b                       Show current bandwidth usage (snapshot using ifstat)"
    echo "  -w <IP_ADDRESS>          Alert if <IP_ADDRESS> establishes a connection"
    echo "  -l <INTERVAL> <LOGFILE>  Log network traffic every INTERVAL seconds to LOGFILE"
    echo "  -h                       Display this help message"
}

# If no arguments: show active interfaces with IPs
if [[ $# -eq 0 ]]; then
    echo "Active network interfaces and their IP addresses:"
    ip -br addr show up | awk '{print $1 "\t" $3}'
    exit 0
fi

while getopts ":b w:l:h" opt; do
    case $opt in
        b)
            # Requires ifstat installed
            echo "Bandwidth usage (values in KB/s):"
            if command -v ifstat &>/dev/null; then
                # Single snapshot: interval=1, count=1
                ifstat -t 1 1
            else
                echo "Error: 'ifstat' is not installed." >&2
                exit 1
            fi
            ;;
        w)
            WATCH_IP="$OPTARG"
            echo "Monitoring active connections; alerting if IP $WATCH_IP connects."
            while true; do
                if ss -nt | awk '{print $5}' | grep -q "$WATCH_IP"; then
                    ts=$(date '+%Y-%m-%d %H:%M:%S')
                    echo "[$ts] ALERT: Connection detected to $WATCH_IP"
                fi
                sleep 5
            done
            ;;
        l)
            INTERVAL="$OPTARG"
            shift $((OPTIND-1))
            LOGFILE="$1"
            if [[ -z "$INTERVAL" || -z "$LOGFILE" ]]; then
                echo "Error: -l requires INTERVAL and LOGFILE." >&2
                print_usage
                exit 1
            fi
            if ! [[ "$INTERVAL" =~ ^[0-9]+$ ]]; then
                echo "Error: INTERVAL must be an integer." >&2
                exit 1
            fi
            echo "Logging network traffic every $INTERVAL seconds to '$LOGFILE'."
            if ! command -v ifstat &>/dev/null; then
                echo "Error: 'ifstat' is not installed." >&2
                exit 1
            fi
            while true; do
                ts=$(date '+%Y-%m-%d %H:%M:%S')
                echo "=== $ts ===" >> "$LOGFILE"
                ifstat -t 1 1 | tail -n +3 >> "$LOGFILE"
                echo "" >> "$LOGFILE"
                sleep "$INTERVAL"
            done
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
