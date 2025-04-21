#!/bin/bash
# This script downloads a CSV file from Google Sheets, converts it to iCal format, adds timezone data, and uploads it to a server via SSH.

# Set Default Variables
    # Config file
    config_file="config.conf"
    # Timezone configuration
    match='BEGIN:VCALENDAR'
    timezone_file='timezones'
    event_start='DTSTART;VALUE=DATE-TIME:'
    timezone_start='DTSTART;TZID=Australia/Melbourne:'
    event_end='DTEND;VALUE=DATE-TIME:'
    timezone_end='DTEND;TZID=Australia/Melbourne:'

#check if config file exists
if [ ! -f "$config_file" ]; then
    echo "Config file not found. Please create a config.sh file with the required variables."
    exit 1
fi 

# Function to parse the config file
    parse_config() {
    while IFS='=' read -r key value; do
        # Remove leading/trailing whitespaces from key and value
        key=$(echo -n "$key" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        value=$(echo -n "$value" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

        # Check if the line is not a comment or empty
        if [[ -n "$key" && ! "$key" =~ ^# ]]; then
        # Assign the value to a variable with the key name
        declare "$key=$value"
        }
    done < "$1"
    }

# Parse the config file     
parse_config "$config_file"

#Load variables from config file
if [ -f "config" ]; then
    source config.sh
else
    echo "Config file not found. Please create a config.sh file with the required variables."
    exit 1
fi

# Run checks
    # Check if required commands are available
    if ! command -v wget &> /dev/null || ! command -v sed &> /dev/null || ! command -v scp &> /dev/null; then
        echo "Required commands are not available. Please install wget, sed, and scp."
        exit 1
    fi
    # Check if timezone file exists
    if [ ! -f "$timezone_file" ]; then
        echo "Timezone file not found: $timezone_file"
        exit 1
    fi
    # Check if to_ical.py exists
    if [ ! -f "to_ical.py" ]; then
        echo "to_ical.py not found. Please ensure it is in the same directory as this script."
        exit 1
    fi
    # Check if CSV URL is reachable
    if ! wget --spider "$csv_url" 2>&1 | grep -q '200 OK'; then
        echo "CSV URL is not reachable: $csv_url"
        exit 1
    fi

# Download from Google Sheets
printf "\nDownloading CSV.\n"
wget -q --show-progress -O "${unique_filename}.csv" "${csv_url}"
    # Check if CSV file is empty
    if [ ! -s "${unique_filename}.csv" ]; then
        echo "CSV file is empty after download."
        exit 1
    fi
printf "CSV downloaded.\n\n"

# Convert to ICS, uses modified csv-ical (pip install csv-ical)
./to_ical.py "${unique_filename}.csv"
printf "Converted to iCal format.\n"

# Add Timezone Data
sed -i "s%${event_start}%${timezone_start}%g" ${unique_filename}.ics
sed -i "s%${event_end}%${timezone_end}%g" ${unique_filename}.ics
sed -i "/$match/r ${timezone_file}" ${unique_filename}.ics
printf "Timezone data added.\n\n"

# Upload to server via SSH
printf "Uploading to server.\n"
    # Check if SSH connection is possible
    if ! ssh -p "$ssh_port" "$ssh_user@$ssh_host" exit; then
        echo "SSH connection failed. Please check your SSH credentials."
        exit 1
    fi
        # Check if SSH destination is writable
    ssh -p "$ssh_port" "$ssh_user@$ssh_host" "touch ${ssh_destination}" 2>/dev/null
    if [ $? -ne 0 ]; then
        echo "SSH destination is not writable: $ssh_destination"
        exit 1
    fi
scp -P $ssh_port "${unique_filename}.ics" "${ssh_user}@${ssh_host}:${ssh_destination}"
printf "Upload complete.\n\n"
printf "https://zapbear.com/wp-content/${unique_filename}.ics\n\n"

# Cleanup
rm "${unique_filename}.csv"
rm "${unique_filename}.ics"