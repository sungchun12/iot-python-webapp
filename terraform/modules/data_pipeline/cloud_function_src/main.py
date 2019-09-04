#!/usr/bin/env python

"""Demonstrates how to connect to Cloud Bigtable and run some basic operations.
Prerequisites:
- Create a Cloud Bigtable cluster.
  https://cloud.google.com/bigtable/docs/creating-cluster
- Set your Google Application Default Credentials.
  https://developers.google.com/identity/protocols/application-default-credentials
"""

import argparse
import base64
import os
import datetime
from ast import literal_eval

from google.cloud import bigtable
from google.cloud.bigtable import column_family
from google.cloud.bigtable import row_filters


def handler(event, context):
    """Entry point function that orchestrates the data pipeline from start to finish.
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
        self.project_id = os.environ["GCLOUD_PROJECT_NAME"]
        self.instance_id = os.environ["BIGTABLE_CLUSTER"]
        self.table_id = os.environ["TABLE_NAME"]
        self.row_filter = row_filters.CellsColumnLimitFilter(
            (int(os.environ["ROW_FILTER"]))
        )
        self.client = bigtable.Client(project=self.project_id, admin=True)
        self.instance = self.client.instance(self.instance_id)
        self.device_data = literal_eval(device_data[1:-1])

    def generate_records(self):
        """Main interface to input records into bigtable"""
        table, column_family_id = self.create_table()
        row_key, column = self.write_rows(table, column_family_id)
        self.get_with_filter(table, row_key, column_family_id, column)

    def create_table(self):
        print("Creating the {} table.".format(self.table_id))
        table = self.instance.table(self.table_id)

        print("Creating column family cf1 with Max Version GC rule...")
        # Create a column family with GC policy : most recent N versions
        max_versions_rule = column_family.MaxVersionsGCRule(self.row_filter)
        column_family_id = "device-family"
        column_families = {column_family_id: max_versions_rule}
        if not table.exists():
            table.create(column_families=column_families)
        else:
            print("Table {} already exists.".format(self.table_id))
        return table, column_family_id

    def write_rows(self, table, column_family_id):
        print("Writing a row of device data to the table.")
        rows = []
        column = "device-temp".encode()
        row_key = "device#{}#{}".format(
            self.device_data["device"], self.device_data["timestamp"]
        ).encode()
        row = table.row(row_key)
        # convert to string as bigtable can't accept float types
        # https://streamsets.com/documentation/datacollector/latest/help/datacollector/UserGuide/Destinations/Bigtable.html
        value = str(self.device_data["temperature"])
        row.set_cell(
            column_family_id, column, value, timestamp=datetime.datetime.utcnow()
        )
        rows.append(row)
        table.mutate_rows(rows)
        return row_key, column

    def get_with_filter(self, table, row_key, column_family_id, column):
        print("Getting a single row of device data by row key.")
        key = row_key

        row = table.read_row(key, self.row_filter)
        cell = row.cells[column_family_id][column][0]
        print(cell.value.decode("utf-8"))
