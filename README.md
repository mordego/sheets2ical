# sheets2ical
This script downloads a CSV file from Google Sheets, converts it to iCal format, adds timezone data, and can also upload it to a server via SSH.

## Installation
Check and set variables in ortho_calendar_publish.sh  
  
Check timezone file has the zones you need. Templates can be found here: https://www.tzurl.org/  


Set your own ssh keys in ~/.ssh/config
```bash
Host [hostname]
    User [username]
    IdentityFile [key_location]
```

Needs CSV/iCal Converter Python Script
    https://github.com/albertyw/csv-ical
```bash
pip install csv-ical
```

## Usage
```bash
./ortho_calendar_publish.sh
```
