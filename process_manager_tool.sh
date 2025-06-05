#!/bin/bash
#
# process_manager_tool.sh
# A script to manage and analyze system processes.
#
# Usage:
#   ./process_manager_tool.sh                # List all processes
#   ./process_manager_tool.sh -k <PID>       # Kill the given process ID
#   ./process_manager_tool.sh -u <USER>      # Display processes by a specific user
#   ./process_manager_tool.sh -t             # Show top 5 CPU- and memory-consuming processes
#   ./process_manager_tool.sh -s <LOGFILE>   # Schedule status checks every minute, logging to LOGFILE

print_usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -k <PID>        Kill the process with PID"
    echo "  -u <USER>       Show processes running by the specified user"
    echo "  -t              Show top 5 processes by CPU and by memory usage"
    echo "  -s <LOGFILE>    Schedule process status checks every minute, appending to LOGFILE"
    echo "  -h              Display this help message"
}

# If no arguments provided, list all running processes:
if [[ $# -eq 0 ]]; then
    echo "Listing all currently running processes (PID, USER, %CPU, %MEM):"
    ps aux --sort=-%cpu | awk 'NR==1 || NR>1 {print $2 "\t" $1 "\t" $3 "%\t" $4 "%\t" $11}'
    exit 0
fi

# Parse options
while getopts ":k:u:ts:h" opt; do
    case $opt in
        k)
            PID="$OPTARG"
            if [[ ! "$PID" =~ ^[0-9]+$ ]]; then
                echo "Error: PID must be a number."
                exit 1
            fi
            echo "Killing process with PID $PID..."
            kill "$PID" 2>/dev/null
            if [[ $? -eq 0 ]]; then
                echo "Process $PID terminated successfully."
            else
                echo "Failed to terminate process $PID. Check if it exists or you have permissions."
            fi
            ;;
        u)
            USER="$OPTARG"
            echo "Processes running by user '$USER':"
            ps -u "$USER" -o pid,user,%cpu,%mem,cmd
            ;;
        t)
            echo "Top 5 processes by CPU usage:"
            ps aux --sort=-%cpu | awk 'NR<=6 { if (NR==1) printf "%s\t%s\t%s\t%s\t%s\n", "PID", "USER", "%CPU", "%MEM", "CMD"; else printf "%s\t%s\t%s%%\t%s%%\t%s\n", $2, $1, $3, $4, $11 }'
            echo
            echo "Top 5 processes by Memory usage:"
            ps aux --sort=-%mem | awk 'NR<=6 { if (NR==1) printf "%s\t%s\t%s\t%s\t%s\n", "PID", "USER", "%CPU", "%MEM", "CMD"; else printf "%s\t%s\t%s%%\t%s%%\t%s\n", $2, $1, $3, $4, $11 }'
            ;;
        s)
            LOGFILE="$OPTARG"
            echo "Scheduling process status checks every minute. Logging to '$LOGFILE'. Press [CTRL+C] to stop."
            while true; do
                echo "=== $(date '+%Y-%m-%d %H:%M:%S') ===" >> "$LOGFILE"
                ps aux --sort=-%cpu | awk 'NR<=6 { if (NR==1) printf "%s\t%s\t%s\t%s\t%s\n", "PID", "USER", "%CPU", "%MEM", "CMD"; else printf "%s\t%s\t%s%%\t%s%%\t%s\n", $2, $1, $3, $4, $11 }' >> "$LOGFILE"
                echo "" >> "$LOGFILE"
                sleep 60
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
