#!/bin/bash
# This script downloads a CSV file from Google Sheets, converts it to iCal format, adds timezone data, and uploads it to a server via SSH.

# Set Default Variables
    # Config file
    config_file='config.conf'
    # Calendar name
    calendar_name='Sheets2iCal'
    # Google Sheets
    sheets_id='Google_Sheets_ID'
    csv_url="https://docs.google.com/spreadsheets/d/${sheets_id}/export?format=csv"
    # Timezone configuration
    timezone_events='Australia/Melbourne'
    prepend_calendar_string='BEGIN:VCALENDAR'
    prepend_calendar_string='BEGIN:VCALENDAR'
    append_timezone_string='X-WR-TIMEZONE:'
    timezone_file='timezones'
    event_start='DTSTART;VALUE=DATE-TIME:'
    timezone_start="DTSTART;TZID=${timezone_events}:"
    event_end='DTEND;VALUE=DATE-TIME:'
    timezone_end="DTEND;TZID=${timezone_events}:"
    # SSH configuration
    ssh_port='22'

#check if config file exists
if [ ! -f "$config_file" ]; then
    echo "Config file not found. Please create/specify a config file with the required variables. Default is $config_file."
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
        eval "$key=$value"
        
        fi
    done < "$1"
    }

# Parse the config file     
parse_config "$config_file"

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
sed -i "/$prepend_calendar_string/r ${timezone_file}" ${unique_filename}.ics
sed -i "/$append_timezone_string/a X-WR-CALNAME\:${calendar_name}" ${unique_filename}.ics
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
# Set output URL
output_url="https://zapbear.com/wp-content/${unique_filename}.ics"
# Print output URL as a clickable link
printf "\e]8;;${output_url}\e\\${output_url}\e]8;;\e\n\n"

# Cleanup
rm "${unique_filename}.csv"
rm "${unique_filename}.ics"
