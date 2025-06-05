#!/bin/bash
#
# cpu_manager_tool.sh
# A script to monitor and analyze CPU usage.
#
# Usage:
#   ./cpu_manager_tool.sh                
#       Display current CPU usage percentage.
#
#   ./cpu_manager_tool.sh -l <INTERVAL> <COUNT> <LOGFILE>
#       Track CPU usage every INTERVAL seconds, COUNT times, logging to LOGFILE.
#
#   ./cpu_manager_tool.sh -a <PID> <CPU_LIST>
#       Set CPU affinity for a specific process (PID) to the CPUs in CPU_LIST (e.g., "0,2").
#
#   ./cpu_manager_tool.sh -c <THRESHOLD>
#       Generate an alert if current CPU usage exceeds THRESHOLD (percentage).

print_usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -l <INTERVAL> <COUNT> <LOGFILE>  Track CPU usage every INTERVAL seconds, COUNT times, logging to LOGFILE"
    echo "  -a <PID> <CPU_LIST>             Set CPU affinity for process PID to CPUs in CPU_LIST"
    echo "  -c <THRESHOLD>                  Alert if current CPU usage exceeds THRESHOLD (%)"
    echo "  -h                              Display this help message"
}

# Function: get current CPU usage %
get_cpu_usage() {
    # Using top in batch mode to fetch CPU usage
    local usage
    usage=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')
    printf "%.2f\n" "$usage"
}

# If no arguments: show current CPU usage
if [[ $# -eq 0 ]]; then
    current=$(get_cpu_usage)
    echo "Current CPU usage: $current%"
    exit 0
fi

# Parse options
while getopts ":l:a:c:h" opt; do
    case $opt in
        l)
            INTERVAL="$OPTARG"
            shift $((OPTIND-1))
            COUNT="$1"
            LOGFILE="$2"
            if [[ -z "$INTERVAL" || -z "$COUNT" || -z "$LOGFILE" ]]; then
                echo "Error: -l requires three arguments." >&2
                print_usage
                exit 1
            fi
            echo "Logging CPU usage every $INTERVAL seconds, $COUNT times, to '$LOGFILE'."
            for ((i=1; i<=COUNT; i++)); do
                ts=$(date '+%Y-%m-%d %H:%M:%S')
                usage=$(get_cpu_usage)
                echo "$ts CPU Usage: $usage%" >> "$LOGFILE"
                sleep "$INTERVAL"
            done
            ;;
        a)
            PID="$OPTARG"
            shift $((OPTIND-1))
            CPU_LIST="$1"
            if [[ -z "$PID" || -z "$CPU_LIST" ]]; then
                echo "Error: -a requires PID and CPU_LIST." >&2
                print_usage
                exit 1
            fi
            echo "Setting CPU affinity of PID $PID to CPUs $CPU_LIST..."
            taskset -cp "$CPU_LIST" "$PID"
            ;;
        c)
            THRESHOLD="$OPTARG"
            if ! [[ "$THRESHOLD" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
                echo "Error: Threshold must be a number." >&2
                exit 1
            fi
            current=$(get_cpu_usage)
            comp=$(awk -v c="$current" -v t="$THRESHOLD" 'BEGIN{print (c>t)?1:0}')
            if [[ $comp -eq 1 ]]; then
                echo "ALERT: CPU usage $current% exceeded threshold $THRESHOLD%."
            else
                echo "CPU usage $current% is below threshold $THRESHOLD%."
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
