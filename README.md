# Ubuntu Package Auto-Update Script

This script automates the process of updating, upgrading, and cleaning up packages on an Ubuntu system. It also handles reboots if necessary. The script is designed to be run as a cron job to ensure your system stays up-to-date without manual intervention.

## Features

-   Updates package lists (`apt-get update`)
-   Performs a distributive upgrade (`apt-get dist-upgrade -y`)
-   Upgrades installed packages (`apt-get upgrade -y`)
-   Removes unnecessary packages (`apt-get autoremove -y`)
-   Logs all operations to `/var/log/apt_update.log`
-   Notifies the user if a reboot is required
-   Optionally sends desktop notifications if `notify-send` is available

## Usage

1. **Save the Script**: Save the script to a file, for example, `update_packages.sh`.

2. **Make the Script Executable**: Run the following command to make the script executable:

    ```sh
    chmod +x update_packages.sh
    ```

3. **Set Up Cron Job**: To run the script at a desired time, add a cron job. For example, to run the script daily at 2 AM:

    ```sh
    crontab -e
    ```

    Add the following line to the crontab file:

    ```sh
    0 2 * * * /path/to/update_packages.sh
    ```

    Replace `/path/to/update_packages.sh` with the actual path to the script.

## Script Details

```bash
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
```
