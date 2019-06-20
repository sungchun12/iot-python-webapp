#!/usr/bin/env python

"""Demonstrates how to connect to Cloud Bigtable and run some basic operations.
Prerequisites:
- Create a Cloud Bigtable cluster.
  https://cloud.google.com/bigtable/docs/creating-cluster
- Set your Google Application Default Credentials.
  https://developers.google.com/identity/protocols/application-default-credentials
"""

import argparse

# [START bigtable_imports]
import datetime

from google.cloud import bigtable
from google.cloud.bigtable import column_family
from google.cloud.bigtable import row_filters

# [END bigtable_imports]


def main(project_id, instance_id, table_id):
    # [START bigtable_connect]
    # The client must be created with admin=True because it will create a
    # table.

    client = bigtable.Client(project=project_id, admin=True)
    instance = client.instance(instance_id)

    # [END bigtable_connect]

    # [START bigtable_create_table]
    print("Creating the {} table.".format(table_id))
    table = instance.table(table_id)

    print("Creating column family cf1 with Max Version GC rule...")
    # Create a column family with GC policy : most recent N versions
    # Define the GC policy to retain only the most recent 2 versions
    max_versions_rule = column_family.MaxVersionsGCRule(2)
    column_family_id = "device-family"
    column_families = {column_family_id: max_versions_rule}
    if not table.exists():
        table.create(column_families=column_families)
    else:
        print("Table {} already exists.".format(table_id))
    # [END bigtable_create_table]

    # [START bigtable_write_rows]
    print("Writing a row of device data to the table.")
    device_data_ex = {
        "device": "temp-sensor-14152",
        "timestamp": 1561047487,
        "temperature": 25.875,
    }
    rows = []
    column = "device-temp".encode()
    row_key = (
        f"device#{device_data_ex['device']}#{device_data_ex['timestamp']}".encode()
    )
    row = table.row(row_key)
    # convert to string as bigtable can't accept float types
    # https://streamsets.com/documentation/datacollector/latest/help/datacollector/UserGuide/Destinations/Bigtable.html
    value = str(device_data_ex["temperature"])
    row.set_cell(column_family_id, column, value, timestamp=datetime.datetime.utcnow())
    rows.append(row)
    table.mutate_rows(rows)
    # [END bigtable_write_rows]

    # [START bigtable_create_filter]
    # Create a filter to only retrieve the most recent version of the cell
    # for each column accross entire row.
    row_filter = row_filters.CellsColumnLimitFilter(2)
    # [END bigtable_create_filter]

    # [START bigtable_get_with_filter]
    print("Getting a single row of device data by row key.")
    key = row_key

    row = table.read_row(key, row_filter)
    cell = row.cells[column_family_id][column][0]
    print(cell.value.decode("utf-8"))
    # [END bigtable_get_with_filter]

    # [START bigtable_scan_with_filter]
    print("Scanning for all device data:")
    partial_rows = table.read_rows(filter_=row_filter)

    for row in partial_rows:
        cell = row.cells[column_family_id][column][0]
        print(cell.value.decode("utf-8"))
    # [END bigtable_scan_with_filter]


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    parser.add_argument("project_id", help="Your Cloud Platform project ID.")
    parser.add_argument(
        "instance_id", help="ID of the Cloud Bigtable instance to connect to."
    )
    parser.add_argument(
        "--table", help="Table to create and destroy.", default="raw-device-data"
    )

    args = parser.parse_args()
    main(args.project_id, args.instance_id, args.table)
