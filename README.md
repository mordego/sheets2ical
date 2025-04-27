# sheets2ical
This bash script downloads a CSV file from Google Sheets, converts it to iCal format, adds timezone data, and can also upload it to a server via SSH.

## Table of Contents

<!-- [Features](#features) -->
- [Setup](#setup)
- [Usage](#usage)
- [Options](#options)
- [Limitations](#limitations)
- [Contributing](#contributing)
<!-- [License](#license) -->

## Setup
1. Make a google sheet with event details. Template available at https://docs.google.com/spreadsheets/d/1DBvqr58Xx9Sss5kiTsqD5VDs0aPGBK7mJ2fDbp4Yvlw
    - Publish sheet as CSV so that the script can access it via URL.   
    `(File > Share > Publish to Web)`

1. Make config file and set variables in `config.conf`, see `config.example.conf` for template.
  
1. Change/add timezones to `timezones` file as required. Templates can be found here: https://www.tzurl.org  

1. Install CSV/iCal Converter Python Script
    https://github.com/albertyw/csv-ical

    ```bash
    pip install csv-ical
    ```

1. (Optional) Set your own ssh keys in ~/.ssh/config
    ```bash
    Host [hostname]
        User [username]
        IdentityFile [key_location]
    ```

## Usage
1. Run scipt
    ```bash
    ./sheets2ical.sh
    ```
2. Set cronjob to run script at regular intervals  
    - Open crontab
    ```
    crontab -e
    ```
    - Add the following line and save the file   
    (this one will run every 30 mins, note Google calendar by default will only update URL imported calendars every 8-12h)
    ```
    */30 * * * * /path/to/the/script
    ```
## Options

### General
- **config_file**: Name of config file (assumes same directory)  
- **calendar_name**: Sets name of calendar (Default: `Sheets2iCal`)
- **unique_filename**: Sets filename of generated/uploaded `.ics` file
- **sheets_id**: Google sheets ID
- **timezone_file**: Name of the timezone file (Default: `timezones`)
- **timezone_events**: Set the timezone of your events (Default: `Australia/Melbourne`)

### SSH details
- **ssh_user**: SSH username
- **ssh_host**: SSH hostname  
- **ssh_port**: SSH port (Default: `22`)  
- **ssh_destination**: Remote directory to save `.ics` file once done.
    ```
    ssh_destination="REMOTE_DIRECTORY/${unique_filename}.ics"
    ```

### Timezone Injection Search Strings
- **prepend_calendar_string**: Search string denoting start of `.ics` calendar after which timezone definitions will be (Default: `'BEGIN:VCALENDAR'`)
- **append_timezone_string**: Search string denoting location to insert `X-WR-CALNAME:${calendar_name}` (Default: `'X-WR-TIMEZONE:'`)
- **event_start**: Search string denoting event start (Default: `'DTSTART;VALUE=DATE-TIME:'`)
- **timezone_start**: Timezone specifying version of start string (Default: `'DTSTART;TZID=${timezone_events}:'`)
- **event_end**: Search string denoting event end (Default: `'DTEND;VALUE=DATE-TIME:'`)
- **timezone_end**: Timezone specifying version of end string (Default: `'DTEND;TZID=${timezone_events}:'`)

## Limitations

- OS needs to be able to run a bash script and ideally automate its execution at regular intervals.
- This script is designed for use with Google Sheets and Google Calendar. It may not work with other spreadsheet or calendar applications.

## Contributing

Contributions to this project are welcome! If you have improvements, bug fixes, or new features you'd like to see added, please submit a Pull Request.
