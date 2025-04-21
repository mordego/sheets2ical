#!/usr/bin/python3

"""
Example for converting a CSV file into an iCal file
"""


from datetime import datetime

from csv_ical import Config, Convert

import sys

convert = Convert()
csv_file_location = sys.argv[1]
ical_file_location = csv_file_location[:-3] + 'ics'
csv_configs: Config = {
    'HEADER_ROWS_TO_SKIP': 1,
    'CSV_NAME': 0,
    'CSV_START_DATE': 1,
    'CSV_END_DATE': 2,
    'CSV_DESCRIPTION': 3,
    'CSV_LOCATION': 4,
    'CSV_DELIMITER': ',',
}

convert.read_csv(csv_file_location, csv_configs)
for row in convert.csv_data:
    start_date = row[csv_configs['CSV_START_DATE']]
    row[csv_configs['CSV_START_DATE']] = datetime.strptime(
        start_date, '%Y-%m-%d %H:%M:%S',
    )
    end_date = row[csv_configs['CSV_END_DATE']]
    row[csv_configs['CSV_END_DATE']] = datetime.strptime(
        end_date, '%Y-%m-%d %H:%M:%S',
    )

convert.make_ical(csv_configs)
convert.save_ical(ical_file_location)
