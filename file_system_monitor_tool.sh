#!/bin/bash
#
# file_system_monitor_tool.sh
# A script to monitor disk usage and manage files.
#
# Usage:
#   ./file_system_monitor_tool.sh
#       Display disk usage for each mounted filesystem.
#
#   ./file_system_monitor_tool.sh -d <DIRECTORY>
#       List the top 15 largest files in <DIRECTORY>.
#
#   ./file_system_monitor_tool.sh -m <DIRECTORY>
#       Show files in <DIRECTORY> modified within the last 24 hours.
#
#   ./file_system_monitor_tool.sh -c <SIZE_IN_MB> <DIRECTORY>
#       Clean (delete) temp files in <DIRECTORY> exceeding <SIZE_IN_MB> MB.

print_usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -d <DIRECTORY>             List top 15 largest files in DIRECTORY"
    echo "  -m <DIRECTORY>             Show files in DIRECTORY modified within last 24 hours"
    echo "  -c <SIZE_IN_MB> <DIR>      Delete files in DIR exceeding SIZE_IN_MB (temp cleanup)"
    echo "  -h                         Display this help message"
}

# If no arguments: show disk usage
if [[ $# -eq 0 ]]; then
    echo "Disk usage for each mounted filesystem:"
    df -h
    exit 0
fi

while getopts ":d:m:c:h" opt; do
    case $opt in
        d)
            TARGET_DIR="$OPTARG"
            if [[ ! -d "$TARGET_DIR" ]]; then
                echo "Error: '$TARGET_DIR' is not a valid directory." >&2
                exit 1
            fi
            echo "Top 15 largest files in '$TARGET_DIR':"
            find "$TARGET_DIR" -type f -exec du -h {} + 2>/dev/null | sort -hr | head -n 15
            ;;
        m)
            TARGET_DIR="$OPTARG"
            if [[ ! -d "$TARGET_DIR" ]]; then
                echo "Error: '$TARGET_DIR' is not a valid directory." >&2
                exit 1
            fi
            echo "Files modified in the last 24 hours in '$TARGET_DIR':"
            find "$TARGET_DIR" -type f -mtime -1
            ;;
        c)
            SIZE_MB="$OPTARG"
            shift $((OPTIND-1))
            TARGET_DIR="$1"
            if [[ -z "$SIZE_MB" || -z "$TARGET_DIR" ]]; then
                echo "Error: -c requires SIZE_IN_MB and DIRECTORY." >&2
                print_usage
                exit 1
            fi
            if [[ ! "$SIZE_MB" =~ ^[0-9]+$ ]]; then
                echo "Error: SIZE_IN_MB must be an integer." >&2
                exit 1
            fi
            if [[ ! -d "$TARGET_DIR" ]]; then
                echo "Error: '$TARGET_DIR' is not a valid directory." >&2
                exit 1
            fi
            echo "Deleting files in '$TARGET_DIR' larger than ${SIZE_MB}MB..."
            find "$TARGET_DIR" -type f -size +"${SIZE_MB}"M -exec rm -f {} \;
            echo "Cleanup complete."
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
