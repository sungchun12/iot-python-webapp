#!/usr/bin/env python

"""Demonstrates how to connect to Cloud Bigtable and run some basic operations.
-Ingests IOT telemetry data and launches within Terraform deployment
"""

import sys
import argparse
import base64
import os
import datetime
from ast import literal_eval

from google.cloud import bigtable
from google.cloud.bigtable import column_family
from google.cloud.bigtable import row_filters

# example data dictionary: {'device': 'temp-sensor-18963', 'timestamp': 1568066927, 'temperature': 28.095405908242377}


def handler(event, context):
    """Entry point function that orchestrates the data movement.
    Triggered from a message on a Cloud Pub/Sub topic.
    Args:
        event (dict): Event payload.
        context (google.cloud.functions.Context): Metadata for the event.
    """
    device_data = base64.b64decode(event["data"]).decode("utf-8")
    print(device_data)
    input_bigtable_records = bigtable_input_generator(device_data)
    input_bigtable_records.generate_records()


class bigtable_input_generator:
    def __init__(self, device_data):
        # pass through environment vars
        self.project_id = os.environ["GCLOUD_PROJECT_NAME"]
        self.instance_id = os.environ["BIGTABLE_CLUSTER"]
        self.table_id = os.environ["TABLE_NAME"]
        self.row_filter_count = int(os.environ["ROW_FILTER"])

        # setup table config
        self.client = bigtable.Client(project=self.project_id, admin=True)
        self.instance = self.client.instance(self.instance_id)
        self.column = "device-temp".encode()
        self.column_family_id = "device-family"
        self.row_filter = row_filters.CellsColumnLimitFilter((self.row_filter_count))

        # setup row value config
        self.device_data = literal_eval(device_data)
        # reverse the timestamp as that is the most common query
        # https://cloud.google.com/bigtable/docs/schema-design-time-series#reverse_timestamps_only_when_necessary
        self.row_key = "device#{}#{}".format(
            self.device_data["device"], (sys.maxsize - (self.device_data["timestamp"]))
        ).encode()
        # convert to string as bigtable can't accept float types
        # https://streamsets.com/documentation/datacollector/latest/help/datacollector/UserGuide/Destinations/Bigtable.html
        self.value = str(self.device_data["temperature"])

    def generate_records(self):
        """Main interface to write records into bigtable"""
        table = self.create_table()
        self.write_rows(table)
        self.get_with_filter(table)

    # TODO: have this overwrite table from terraform if it does not match with cloud function config?
    def create_table(self):
        print("Creating the {} table.".format(self.table_id))
        table = self.instance.table(self.table_id)
        print(
            "Creating column family cf1 with Max Version GC rule: most recent {} versions".format(
                self.row_filter_count
            )
        )
        max_versions_rule = column_family.MaxVersionsGCRule(self.row_filter_count)
        column_families = {self.column_family_id: max_versions_rule}
        if not table.exists():
            table.create(column_families=column_families)
        else:
            print("Table {} already exists.".format(self.table_id))
        return table

    def write_rows(self, table):
        print("Writing a row of device data to the table.")
        rows = []
        row = table.row(self.row_key)
        row.set_cell(
            self.column_family_id,
            self.column,
            self.value,
            timestamp=datetime.datetime.utcnow(),
        )
        rows.append(row)
        table_updated = table.mutate_rows(rows)
        print(table_updated)

    def get_with_filter(self, table):
        print("Getting a single row of device data by row key.")
        key = self.row_key
        row = table.read_row(key, self.row_filter)
        cell = row.cells[self.column_family_id][self.column][0]
        print(cell.value.decode("utf-8"))
        # TODO: test with RowKeyRegexFilter
        # https://stackoverflow.com/questions/48391664/google-bigtable-python-api-rowkey-regex-filter-issues
        row_key_filter = "device#{}#".format(self.device_data["device"])
        regex = ("^" + str(row_key_filter) + "..........$").encode()
        filter = row_filters.RowKeyRegexFilter(regex)
        row_data = table.read_rows(filter_=filter)
        read_rows = [row for row in row_data]
        print(read_rows[0].row_key.decode("utf-8"))
        print(read_rows[1].row_key.decode("utf-8"))
        print(read_rows[2].row_key.decode("utf-8"))
        print(read_rows[-1].row_key.decode("utf-8"))
        row_data = table.read_rows()
        read_rows = [row for row in row_data]
        print(read_rows[0].row_key.decode("utf-8"))
        row_data = table.read_rows(
            start_key=row_key_filter.encode()
        )  # this is the winner
        read_rows = [row for row in row_data]
        print(read_rows[0].row_key.decode("utf-8"))
        print(read_rows[1].row_key.decode("utf-8"))
        print(read_rows[2].row_key.decode("utf-8"))
        print(read_rows[-1].row_key.decode("utf-8"))
        row_data = table.read_rows(start_key=row_key_filter.encode(), limit=1)
        read_rows = [row for row in row_data]
        print(read_rows[0].row_key.decode("utf-8"))
        # print a list of dictionaries
        print("testing starts here")
        row_data = table.read_rows(
            start_key=row_key_filter.encode(), limit=5
        )  # this is the winner
        read_rows = [row for row in row_data]
        # print(row_data.consume_next())
        final_rows_copy = []
        # final_rows_deepcopy = []
        for row in read_rows:
            # grab the most recent cell
            device_row_dict = {}
            row_key = row.row_key.decode("utf-8")
            cell = row.cells[self.column_family_id][self.column][0]
            temp = cell.value.decode("utf-8")
            # extract the temperature timestamp
            temp_timestamp = int(row_key.split("#")[2][::-1])
            device_row_dict[row_key] = {}
            device_row_dict[row_key]["temp"] = temp
            device_row_dict[row_key]["temp_timestamp"] = self.timestamp_converter(
                temp_timestamp
            )
            print(device_row_dict)
            final_rows_copy.append(device_row_dict.copy())
            # final_rows_deepcopy.append(device_row_dict.deepcopy())
        print(final_rows_copy)
        # print(final_rows_deepcopy)
        print("testing ends here")

    @staticmethod
    def timestamp_converter(timestamp):
        """Convert timestamp into more useful format"""
        # if you encounter a "year is out of range" error the timestamp
        # may be in milliseconds, try `ts /= 1000` in that case
        timestamp_converted = datetime.datetime.utcfromtimestamp(timestamp).strftime(
            "%Y-%m-%d %H:%M:%S"
        )
        return timestamp_converted
