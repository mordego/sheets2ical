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
- Make a google sheet with event details. Template available at https://docs.google.com/spreadsheets/d/1DBvqr58Xx9Sss5kiTsqD5VDs0aPGBK7mJ2fDbp4Yvlw
    - Publish sheet as CSV so that the script can access it via URL. (File > Share > Publish to Web)

- Make config file and set variables in 'config.conf', see 'config.example.conf' for template.
  
- Change/add timezones to 'timezones' file as required. Templates can be found here: https://www.tzurl.org  

- Install CSV/iCal Converter Python Script
    https://github.com/albertyw/csv-ical
```bash
pip install csv-ical
```

Set your own ssh keys in ~/.ssh/config
```bash
Host [hostname]
    User [username]
    IdentityFile [key_location]
```

## Usage
```bash
./sheets2ical.sh
```

## Options

1. **Calendar ID**: Specifies the calendar to be synced with the Google Sheets document. 
2. **Start Date (15D Reminder)**: Sets the start date for the range of events to be fetched from the Google Calendar. 
3. **End Date (15D + Final D)**: Sets the end date for the range of events to be fetched from the Google Calendar. 
4. **Description**: Sets the details of the events on Google Calendar.
5. **Location**: Sets the location for the events.
6. **Guests**: Sets the mail to connecting users with mailing about the events.

## Limitations

- This script is designed for use with Google Sheets and Google Calendar. It may not work with other spreadsheet or calendar applications.
- The script only supports the synchronization between a single calendar and a single sheet.
- The script may not work as expected if there are too many events or if the calendar has a large number of recurring events.
- The script does not support automated mailing to event attendees or reminders.

## Contributing

Contributions to this project are welcome! If you have improvements, bug fixes, or new features you'd like to see added, please submit a Pull Request.
