#!/bin/bash

# Script: server-stats.sh
# Purpose: Analyze basic server performance stats

# Check if the script is run as root for failed login stats
if [[ $EUID -ne 0 ]]; then
    echo "Warning: Failed login attempts will not be retrieved unless the script is run as root."
fi

# Function to display total CPU usage
cpu_usage() {
    echo "\n--- CPU Usage ---"
    mpstat | awk '$3 ~ /CPU/ {next} {print "Idle: "$12"%", "Used: "(100-$12)"%"}'
}

# Function to display memory usage
memory_usage() {
    echo "\n--- Memory Usage ---"
    free -h | awk 'NR==2 {printf "Used: %s / Total: %s (%.2f%%)\n", $3, $2, $3*100/$2 }'
}

# Function to display disk usage
disk_usage() {
    echo "\n--- Disk Usage ---"
    df -h --total | awk '$1 ~ /total/ {printf "Used: %s / Total: %s (%.2f%%)\n", $3, $2, $5 }'
}

# Function to display top 5 processes by CPU usage
top_cpu_processes() {
    echo "\n--- Top 5 Processes by CPU Usage ---"
    ps -eo pid,comm,%cpu --sort=-%cpu | head -n 6
}

# Function to display top 5 processes by memory usage
top_memory_processes() {
    echo "\n--- Top 5 Processes by Memory Usage ---"
    ps -eo pid,comm,%mem --sort=-%mem | head -n 6
}

# Function to display additional stats
additional_stats() {
    echo "\n--- Additional Stats ---"
    echo "OS Version: $(lsb_release -d | cut -f2)"
    echo "Uptime: $(uptime -p)"
    echo "Load Average: $(uptime | awk -F 'load average: ' '{print $2}')"
    echo "Logged In Users:"
    who
    if [[ $EUID -eq 0 ]]; then
        echo "\nFailed Login Attempts:"
        awk '/Failed password/ {print $1, $2, $3, $11, $13}' /var/log/auth.log | sort | uniq -c
    fi
}

# Display all stats
cpu_usage
memory_usage
disk_usage
top_cpu_processes
top_memory_processes
additional_stats

# End of script
