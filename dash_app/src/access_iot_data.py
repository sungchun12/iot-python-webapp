# -*- coding: utf-8 -*-
#!/usr/bin/env python

import sys
import datetime
import os
import base64
from collections import deque

from google.cloud import bigtable
from google.cloud import kms_v1
from google.cloud.bigtable import column_family
from google.cloud.bigtable import row_filters

# import iot sample utilties
import iot_manager


class iot_pipeline_data(object):
    def __init__(self):
        try:
            # pass in environment variables
            self.project_id = os.environ["GCLOUD_PROJECT_NAME"]
            self.instance_id = os.environ["BIGTABLE_CLUSTER"]
            self.table_id = os.environ["TABLE_NAME"]
            self.cloud_region = os.environ["CLOUD_REGION"]
            self.iot_registry = os.environ["IOT_REGISTRY"]
            self.row_filter_count = int(os.environ["ROW_FILTER"])
            self.key_ring_id = os.environ["KEY_RING_ID"]
            self.crypto_key_id = os.environ["CRYPTO_KEY_ID"]
            self.__service_account_ciphertext = base64.b64decode(
                os.environ["GOOGLE_APP_CREDENTIALS"]
            )

            # setup bigtable variables
            self.row_filter = row_filters.CellsColumnLimitFilter(
                (self.row_filter_count)
            )
            self.bigtable_client = bigtable.Client(project=self.project_id, admin=True)
            self.column = "device-temp".encode()
            self.column_family_id = "device-family"
            self.instance = self.bigtable_client.instance(self.instance_id)
            self.table = self.instance.table(self.table_id)

            # error handling messages
            self.index_error_message = "Refresh browser until live data starts flowing through and infrastructure is deployed! Exiting application now."

            self.type_error_message = (
                "Ensure GOOGLE_APP_CREDENTIALS env var is base64 decoded ciphertext"
            )
        except KeyError as e:
            print(
                f"Make sure this variable is defined in the application env vars: {str(e)}"
            )
            sys.exit()

    def decrpyt_symmetric_text(self, ciphertext):
        """Decrypt data using KMS key used to encrypt file in the first place.
        """
        # Creates an API client for the KMS API.
        client = kms_v1.KeyManagementServiceClient()

        # The resource name of the CryptoKey.
        name = client.crypto_key_path_path(
            self.project_id, self.cloud_region, self.key_ring_id, self.crypto_key_id
        )

        # Use the KMS API to decrypt the data.
        response = client.decrypt(name, ciphertext)

        return response.plaintext

    def get_iot_devices_data(self, n_rows):
        """Main interface to retrieve IOT device data in one payload
        """
        devices_list = self.get_device_names()
        row_keys_list = self.create_device_rowkeys(devices_list)
        all_device_row_list = self.create_all_device_rows(row_keys_list, n_rows)
        return all_device_row_list

    def get_device_names(self):
        """Stores all gcp metadata needed to update live dashboard
        """
        try:
            registries_list = iot_manager.list_registries(
                self.decrpyt_symmetric_text(self.__service_account_ciphertext).decode(),
                self.project_id,
                self.cloud_region,
            )
            # ex: 'iot-registry'
            registry_id = [
                registry.get("id")
                for registry in registries_list
                if registry.get("id") == self.iot_registry
            ][0]

            # ex: [{u'numId': u'2770786279715094', u'id': u'temp-sensor-1482'}, {u'numId': u'2566845666382786', u'id': u'temp-sensor-21231'}, {u'numId': u'2776213510215167', u'id': u'temp-sensor-2719'}]
            devices_list = iot_manager.list_devices(
                self.decrpyt_symmetric_text(self.__service_account_ciphertext).decode(),
                self.project_id,
                self.cloud_region,
                registry_id,
            )
            return devices_list
        except IndexError:
            print(self.index_error_message)
            sys.exit()
        except TypeError:
            print(self.type_error_message)
            sys.exit()

    def create_device_rowkeys(self, devices_list):
        """Create list of iot row keys from all iot devices listed
        """
        device_ids = [i.get("id") for i in devices_list]
        row_keys_list = ["device#{}#".format(device) for device in device_ids]
        return row_keys_list

    def create_device_rows(self, row_key_prefix, n_rows):
        """Create list of nested dictionaries of single iot device with respective
        temperature and timestamp data
        """
        # TODO: try and except block for list index out of range error
        # https://stackoverflow.com/questions/11902458/i-want-to-exception-handle-list-index-out-of-range
        row_key_filter = row_key_prefix.encode()
        row_data = self.table.read_rows(start_key=row_key_filter, limit=n_rows)
        read_rows = [row for row in row_data]
        device_row_list = []
        for row in read_rows:
            # grab the most recent cell
            device_row_dict = {}
            row_key = row.row_key.decode("utf-8")
            cell = row.cells[self.column_family_id][self.column][0]
            temp = float(cell.value.decode("utf-8"))
            # extract the temperature from the reverse timestamp
            temp_timestamp = self.timestamp_converter(
                sys.maxsize - int(row_key.split("#")[2])
            )
            device_row_dict[row_key] = {}
            device_row_dict[row_key]["temp"] = temp
            device_row_dict[row_key]["temp_timestamp"] = temp_timestamp
            device_row_list.append(device_row_dict.copy())
        # ex: [{'device#temp-sensor-17399#9223372035284444464': {'temp': '23.60884369687173', 'temp_timestamp': '2019-10-06 03:09:03'}},
        # {'device#temp-sensor-17399#9223372035284444465': {'temp': '23.61801573226279', 'temp_timestamp': '2019-10-06 03:09:02'}},
        # {'device#temp-sensor-17399#9223372035284444466': {'temp': '23.62735480809774', 'temp_timestamp': '2019-10-06 03:09:01'}},
        # {'device#temp-sensor-17399#9223372035284444467': {'temp': '23.633592416604664', 'temp_timestamp': '2019-10-06 03:09:00'}},
        # {'device#temp-sensor-17399#9223372035284444468': {'temp': '23.637569649711086', 'temp_timestamp': '2019-10-06 03:08:59'}}]
        return device_row_list

    def create_all_device_rows(self, row_keys_list, n_rows):
        """Creates a full list of all devices data
        """
        all_device_row_list = []
        for row_key_prefix in row_keys_list:
            device_row_list = self.create_device_rows(row_key_prefix, n_rows)
            all_device_row_list.append(device_row_list)

        # ex: [[{'device#temp-sensor-14608#9223372035284285863': {'temp': 26.095061796938726, 'temp_timestamp': '2019-10-07 23:12:24'}}], [{'device#temp-sensor-24716#9223372035284285863': {'temp': 16.624428948909912, 'temp_timestamp': '2019-10-07 23:12:24'}}], [{'device#temp-sensor-24716#9223372035284285863': {'temp': 16.624428948909912, 'temp_timestamp': '2019-10-07 23:12:24'}}], [{'device#temp-sensor-24716#9223372035284285863': {'temp': 16.624428948909912, 'temp_timestamp': '2019-10-07 23:12:24'}}], [{'device#temp-sensor-9944#9223372035284285864': {'temp': 27.361626128931505, 'temp_timestamp': '2019-10-07 23:12:23'}}], [{'device#temp-sensor-9944#9223372035284285864': {'temp': 27.361626128931505, 'temp_timestamp': '2019-10-07 23:12:23'}}]]
        return all_device_row_list

    def get_name_temp_time(self, all_device_row_list, device_index):
        """Returns name and temperature objects for single iot device
        """
        try:
            device_data = all_device_row_list[device_index][0]
            row_key = list(device_data.keys())[0]
            device_temp = device_data[row_key]["temp"]
            temp_timestamp = device_data[row_key]["temp_timestamp"]
            sensor_name = row_key.split("#")[1]
            return sensor_name, device_temp, temp_timestamp
        except IndexError:
            print(self.index_error_message)
            sys.exit()

    @staticmethod
    def timestamp_converter(timestamp):
        """Convert timestamp into more useful format"""
        # if you encounter a "year is out of range" error the timestamp
        # may be in milliseconds, try `ts /= 1000` in that case
        timestamp_converted = datetime.datetime.utcfromtimestamp(timestamp).strftime(
            "%Y-%m-%d %H:%M:%S"
        )
        return timestamp_converted

    @staticmethod
    def set_graph_data_limit(n_items):
        """Setup graph data dictionary limits. Can be adjusted for different data max limits."""
        device_data_dict = {"device_name": [], "temp": [], "temp_timestamp": []}
        device_data_dict["device_name"] = deque(maxlen=1)
        device_data_dict["temp"] = deque(maxlen=n_items)
        device_data_dict["temp_timestamp"] = deque(maxlen=n_items)

        return device_data_dict
