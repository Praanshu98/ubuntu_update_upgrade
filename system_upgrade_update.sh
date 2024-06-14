#!/bin/bash

# Define text styles
TEXT_RESET='\e[0m'
TEXT_YELLOW='\e[0;33m'
TEXT_RED_B='\e[1;31m'

# Log file
LOG_FILE="/var/log/apt_update.log"

# Function to run a command, print a message in yellow, and log output
run_and_echo() {
    local command=$1
    local message=$2

    # Run command and capture output
    if output=$($command 2>&1); then
        echo -e $TEXT_YELLOW
        echo $message
        echo -e $TEXT_RESET
        echo "$(date): $message" >> $LOG_FILE
        echo "$output" >> $LOG_FILE
    else
        echo -e $TEXT_RED_B
        echo "Error running command: $command"
        echo "$output"
        echo -e $TEXT_RESET
        echo "$(date): Error running command: $command" >> $LOG_FILE
        echo "$output" >> $LOG_FILE
        exit 1
    fi
}

# Notify function (optional)
notify() {
    local message=$1
    if command -v notify-send &> /dev/null; then
        notify-send "APT Update Script" "$message"
    fi
}

# Update and upgrade the system
run_and_echo "sudo apt-get update" "APT update finished..."
notify "APT update finished..."
run_and_echo "sudo apt-get dist-upgrade -y" "APT distributive upgrade finished..."
notify "APT distributive upgrade finished..."
run_and_echo "sudo apt-get upgrade -y" "APT upgrade finished..."
notify "APT upgrade finished..."
run_and_echo "sudo apt-get autoremove -y" "APT auto remove finished..."
notify "APT auto remove finished..."

# Print the current date
echo $(date)

# Check if reboot is required and notify
if [ -f /var/run/reboot-required ]; then
    echo -e $TEXT_RED_B
    echo 'Reboot required!'
    echo -e $TEXT_RESET
    echo "$(date): Reboot required!" >> $LOG_FILE
    notify "Reboot required!"
    /sbin/shutdown -r now
fi
