# Linux-OS-Management-Suite

A suite of Linux shell scripts for system administration tasks, including process management, CPU and memory monitoring, file system analysis, and network traffic tracking. Each script is designed to be simple to run and extend, providing a set of common utilities for administrators and power users.

---

## Table of Contents

- [Features](#features)  
- [Installation](#installation)  
- [Usage](#usage)  
  - [1. Process Manager Tool](#1-process-manager-tool)  
  - [2. CPU Manager Tool](#2-cpu-manager-tool)  
  - [3. Memory Manager Tool](#3-memory-manager-tool)  
  - [4. File System Monitor Tool](#4-file-system-monitor-tool)  
  - [5. Network Monitor Tool](#5-network-monitor-tool)  
- [Dependencies](#dependencies)  
- [Tips & Notes](#tips--notes)  
- [License](#license)  

---

## Features

- **Process Manager Tool**: List, filter, kill, and monitor processes; schedule periodic snapshots.  
- **CPU Manager Tool**: Display current CPU usage, log CPU metrics over time, set CPU affinity, and trigger alerts.  
- **Memory Manager Tool**: Show total/used/free memory, list heavy-memory processes, clear cache/buffers, and alert on low memory.  
- **File System Monitor Tool**: Display disk usage, find largest files, list recently modified files, and delete oversized files.  
- **Network Monitor Tool**: Display active network interfaces, show bandwidth usage, alert on specific IP connections, and log network traffic.

---

## Installation

1. **Clone or download** this repository:
   ```bash
   git clone https://github.com/sandhu704/Linux-OS-Management-Suite.git
   cd Linux-OS-Management-Suite
   ```

2. **Make each script executable**:
   ```bash
   chmod +x process_manager_tool.sh             cpu_manager_tool.sh             memory_manager_tool.sh             file_system_monitor_tool.sh             network_monitor_tool.sh
   ```

3. (Optional) Verify dependencies are installed (see the Dependencies section).

---

## Usage

Each script can be run directly from its filename, followed by the options described. Use `sudo` if root privileges are required.

### 1. Process Manager Tool

```bash
./process_manager_tool.sh [options]
```

Examples:
- List all processes:
  ```bash
  ./process_manager_tool.sh
  ```
- Kill a process:
  ```bash
  ./process_manager_tool.sh -k 1234
  ```
- Filter by user:
  ```bash
  ./process_manager_tool.sh -u alice
  ```
- Show top CPU/memory processes:
  ```bash
  ./process_manager_tool.sh -t
  ```
- Schedule periodic snapshots:
  ```bash
  ./process_manager_tool.sh -s /var/log/process_snapshots.log
  ```

---

### 2. CPU Manager Tool

```bash
./cpu_manager_tool.sh [options]
```

Examples:
- Display current CPU usage:
  ```bash
  ./cpu_manager_tool.sh
  ```
- Log CPU usage at intervals:
  ```bash
  ./cpu_manager_tool.sh -l 10 6 cpu_log.txt
  ```
- Set CPU affinity:
  ```bash
  sudo ./cpu_manager_tool.sh -a 2345 0,2
  ```
- Alert on high CPU usage:
  ```bash
  ./cpu_manager_tool.sh -c 75
  ```

---

### 3. Memory Manager Tool

```bash
./memory_manager_tool.sh [options]
```

Examples:
- Show memory usage:
  ```bash
  ./memory_manager_tool.sh
  ```
- Show processes using > 200MB:
  ```bash
  ./memory_manager_tool.sh -p 200
  ```
- Clear cache:
  ```bash
  sudo ./memory_manager_tool.sh -c
  ```
- Alert if available memory < 500MB:
  ```bash
  ./memory_manager_tool.sh -l 500
  ```

---

### 4. File System Monitor Tool

```bash
./file_system_monitor_tool.sh [options]
```

Examples:
- Show disk usage:
  ```bash
  ./file_system_monitor_tool.sh
  ```
- Largest files:
  ```bash
  ./file_system_monitor_tool.sh -d /var/log
  ```
- Modified files (24h):
  ```bash
  ./file_system_monitor_tool.sh -m /home/alice
  ```
- Delete files > 100MB:
  ```bash
  ./file_system_monitor_tool.sh -c 100 /tmp
  ```

---

### 5. Network Monitor Tool

```bash
./network_monitor_tool.sh [options]
```

Examples:
- Show interfaces:
  ```bash
  ./network_monitor_tool.sh
  ```
- Bandwidth snapshot (requires `ifstat`):
  ```bash
  ./network_monitor_tool.sh -b
  ```
- Watch IP for connection:
  ```bash
  ./network_monitor_tool.sh -w 192.168.1.100
  ```
- Log network traffic:
  ```bash
  ./network_monitor_tool.sh -l 30 net_log.txt
  ```

---

## Dependencies

- Core utilities: `ps`, `awk`, `top`, `free`, `df`, `find`, `du`, `ss`, `ip`, `kill`, `date`
- Optional:
  - `taskset` (from `util-linux`)
  - `ifstat` (install via: `sudo apt install ifstat` or `sudo yum install ifstat`)

---

## Tips & Notes

- Use `sudo` when required.
- Press `Ctrl+C` to stop scheduled loops.
- Fix permission errors:
  ```bash
  chmod +x <script_name>.sh
  ```

---

## License

This project is released under the MIT License. See the LICENSE file for details.
