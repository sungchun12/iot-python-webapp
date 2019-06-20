#!/usr/bin/env python

"""Demonstrates how to connect to Cloud Bigtable and run some basic operations.
Prerequisites:
- Create a Cloud Bigtable cluster.
  https://cloud.google.com/bigtable/docs/creating-cluster
- Set your Google Application Default Credentials.
  https://developers.google.com/identity/protocols/application-default-credentials
"""
#%%
import argparse

# [START bigtable_hw_imports]
import datetime

from google.cloud import bigtable
from google.cloud.bigtable import column_family
from google.cloud.bigtable import row_filters

# [END bigtable_hw_imports]

#%%
# expected dictionary of values to pass through pub sub

device_data_ex1 = {
    "device": "temp-sensor-14152",
    "timestamp": 1561047482,
    "temperature": 25.871327565065535,
}

device_data_ex2 = {
    "device": "temp-sensor-14152",
    "timestamp": 1561047476,
    "temperature": 25.901292631539086,
}

device_data_ex3 = {
    "device": "temp-sensor-14152",
    "timestamp": 1561047496,
    "temperature": 25.754188518132445,
}

test_data = [device_data_ex1, device_data_ex2, device_data_ex3]
print(test_data[0]["device"])
print(device_data_ex1["timestamp"])

#%%
# start the code
# [START bigtable_hw_connect]
# The client must be created with admin=True because it will create a
# table.
import os

os.environ[
    "GOOGLE_APPLICATION_CREDENTIALS"
] = "C:/Users/sungwon.chung/Desktop/repos/serverless_dash_repo/serverless_dash/terraform/service_account.json"
project_id = "iconic-range-220603"
instance_id = "iot-stream-database"
table_id = "raw-device-data"
client = bigtable.Client(project=project_id, admin=True)
instance = client.instance(instance_id)
# [END bigtable_hw_connect]

# [START bigtable_hw_create_table]
print("Creating the {} table.".format(table_id))
table = instance.table(table_id)

print("Creating column family cf1 with Max Version GC rule...")
# Create a column family with GC policy : most recent N versions
# Define the GC policy to retain only the most recent 2 versions
max_versions_rule = column_family.MaxVersionsGCRule(2)
column_family_id = "cf1"
column_families = {column_family_id: max_versions_rule}
if not table.exists():
    table.create(column_families=column_families)
else:
    print("Table {} already exists.".format(table_id))
# [END bigtable_hw_create_table]
#%%
# [START bigtable_hw_write_rows]
print("Writing some dummy device data to the table.")
greetings = ["Hello World!", "Hello Cloud Bigtable!", "Hello Python!"]
rows = []
column = "greeting".encode()
for i, value in enumerate(greetings):
    # Note: This example uses sequential numeric IDs for simplicity,
    # but this can result in poor performance in a production
    # application.  Since rows are stored in sorted order by key,
    # sequential keys can result in poor distribution of operations
    # across nodes.
    #
    # For more information about how to design a Bigtable schema for
    # the best performance, see the documentation:
    #
    #     https://cloud.google.com/bigtable/docs/schema-design
    row_key = "greeting{}".format(i).encode()
    row = table.row(row_key)
    row.set_cell(column_family_id, column, value, timestamp=datetime.datetime.utcnow())
    rows.append(row)
table.mutate_rows(rows)
# [END bigtable_hw_write_rows]
#%%

# define the row key
row_key = f"device#{device_data_ex1['device']}#{device_data_ex1['timestamp']}".encode()

#%%


def main(project_id, instance_id, table_id):
    # [START bigtable_hw_connect]
    # The client must be created with admin=True because it will create a
    # table.
    client = bigtable.Client(project=project_id, admin=True)
    instance = client.instance(instance_id)
    # [END bigtable_hw_connect]

    # [START bigtable_hw_create_table]
    print("Creating the {} table.".format(table_id))
    table = instance.table(table_id)

    print("Creating column family cf1 with Max Version GC rule...")
    # Create a column family with GC policy : most recent N versions
    # Define the GC policy to retain only the most recent 2 versions
    max_versions_rule = column_family.MaxVersionsGCRule(2)
    column_family_id = "cf1"
    column_families = {column_family_id: max_versions_rule}
    if not table.exists():
        table.create(column_families=column_families)
    else:
        print("Table {} already exists.".format(table_id))
    # [END bigtable_hw_create_table]

    # [START bigtable_hw_write_rows]
    print("Writing some greetings to the table.")
    greetings = ["Hello World!", "Hello Cloud Bigtable!", "Hello Python!"]
    rows = []
    column = "greeting".encode()
    for i, value in enumerate(greetings):
        # Note: This example uses sequential numeric IDs for simplicity,
        # but this can result in poor performance in a production
        # application.  Since rows are stored in sorted order by key,
        # sequential keys can result in poor distribution of operations
        # across nodes.
        #
        # For more information about how to design a Bigtable schema for
        # the best performance, see the documentation:
        #
        #     https://cloud.google.com/bigtable/docs/schema-design
        row_key = "greeting{}".format(i).encode()
        row = table.row(row_key)
        row.set_cell(
            column_family_id, column, value, timestamp=datetime.datetime.utcnow()
        )
        rows.append(row)
    table.mutate_rows(rows)
    # [END bigtable_hw_write_rows]

    # [START bigtable_hw_create_filter]
    # Create a filter to only retrieve the most recent version of the cell
    # for each column accross entire row.
    row_filter = row_filters.CellsColumnLimitFilter(1)
    # [END bigtable_hw_create_filter]

    # [START bigtable_hw_get_with_filter]
    print("Getting a single greeting by row key.")
    key = "greeting0".encode()

    row = table.read_row(key, row_filter)
    cell = row.cells[column_family_id][column][0]
    print(cell.value.decode("utf-8"))
    # [END bigtable_hw_get_with_filter]

    # [START bigtable_hw_scan_with_filter]
    print("Scanning for all greetings:")
    partial_rows = table.read_rows(filter_=row_filter)

    for row in partial_rows:
        cell = row.cells[column_family_id][column][0]
        print(cell.value.decode("utf-8"))
    # [END bigtable_hw_scan_with_filter]

    # [START bigtable_hw_delete_table]
    print("Deleting the {} table.".format(table_id))
    table.delete()
    # [END bigtable_hw_delete_table]


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    parser.add_argument("project_id", help="Your Cloud Platform project ID.")
    parser.add_argument(
        "instance_id", help="ID of the Cloud Bigtable instance to connect to."
    )
    parser.add_argument(
        "--table", help="Table to create and destroy.", default="Hello-Bigtable"
    )

    args = parser.parse_args()
    main(args.project_id, args.instance_id, args.table)
