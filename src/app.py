# -*- coding: utf-8 -*-
#!/usr/bin/env python

import sys
import datetime
import os
import dash

import dash_core_components as dcc
import dash_html_components as html
import plotly
from dash.dependencies import Input, Output

# pip install pyorbital
from pyorbital.orbital import Orbital

from google.cloud import bigtable
from google.cloud.bigtable import column_family
from google.cloud.bigtable import row_filters

# import iot sample utilties
import iot_manager


class iot_pipeline_data(object):
    def __init__(self):
        # TODO: may have environment variables created in terraform and have it originate from cloud function terraform environment variables
        self.project_id = os.environ["GCLOUD_PROJECT_NAME"]
        self.instance_id = os.environ["BIGTABLE_CLUSTER"]
        self.table_id = os.environ["TABLE_NAME"]
        self.cloud_region = os.environ["CLOUD_REGION"]
        self.iot_registry = os.environ["IOT_REGISTRY"]
        self.row_filter_count = int(os.environ["ROW_FILTER"])

        self.row_filter = row_filters.CellsColumnLimitFilter((self.row_filter_count))
        self.bigtable_client = bigtable.Client(project=self.project_id, admin=True)
        self.column = "device-temp".encode()
        self.column_family_id = "device-family"

        self.instance = self.bigtable_client.instance(self.instance_id)
        self.table = self.instance.table(self.table_id)
        self.service_account_json = os.path.abspath(
            "../terraform/service_account.json"
        )  # TODO relative path may change

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
        registries_list = iot_manager.list_registries(
            self.service_account_json, self.project_id, self.cloud_region
        )
        # ex: 'iot-registry'
        registry_id = [
            registry.get("id")
            for registry in registries_list
            if registry.get("id") == self.iot_registry
        ][0]

        # ex: [{u'numId': u'2770786279715094', u'id': u'temp-sensor-1482'}, {u'numId': u'2566845666382786', u'id': u'temp-sensor-21231'}, {u'numId': u'2776213510215167', u'id': u'temp-sensor-2719'}]
        devices_list = iot_manager.list_devices(
            self.service_account_json, self.project_id, self.cloud_region, registry_id
        )
        return devices_list

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

    @staticmethod
    def get_device_name_temp(all_device_row_list, device_index):
        """Returns name and temperature objects for single iot device
        """
        device_data = all_device_row_list[device_index][0]
        row_key = list(device_data.keys())[0]
        device_temp = device_data[row_key]["temp"]
        temp_timestamp = device_data[row_key]["temp_timestamp"]
        sensor_name = row_key.split("#")[1]
        return sensor_name, device_temp

    @staticmethod
    def timestamp_converter(timestamp):
        """Convert timestamp into more useful format"""
        # if you encounter a "year is out of range" error the timestamp
        # may be in milliseconds, try `ts /= 1000` in that case
        timestamp_converted = datetime.datetime.utcfromtimestamp(timestamp).strftime(
            "%Y-%m-%d %H:%M:%S"
        )
        return timestamp_converted


cbt_data_generator = iot_pipeline_data()
devices_list = cbt_data_generator.get_device_names()
row_keys_list = cbt_data_generator.create_device_rowkeys(devices_list)
all_device_row_list = cbt_data_generator.create_all_device_rows(row_keys_list, 1)
sensor_name_1, device_temp_1 = cbt_data_generator.get_device_name_temp(
    all_device_row_list, 0
)
print(sensor_name_1)
print(device_temp_1)
print(all_device_row_list)

satellite = Orbital("TERRA")

external_stylesheets = ["https://codepen.io/chriddyp/pen/bWLwgP.css"]

app = dash.Dash(__name__, external_stylesheets=external_stylesheets)

# TODO: update layout
# TODO:update intervals to 500 milliseconds? Look at the average execution time of function
app.layout = html.Div(
    html.Div(
        [
            html.H4("IoT Temperature Device Live Dashboard"),
            html.Div(id="live-update-text"),
            dcc.Graph(id="live-update-graph"),
            dcc.Interval(
                id="interval-component",
                interval=1 * 1000,  # in milliseconds
                n_intervals=0,
            ),
        ]
    )
)

# TODO: create new  x-axis: Date/time, y-axis: temperature


@app.callback(
    Output("live-update-text", "children"), [Input("interval-component", "n_intervals")]
)
def update_metrics(n):
    style = {"padding": "5px", "fontSize": "16px"}
    all_device_row_list = cbt_data_generator.create_all_device_rows(
        row_keys_list, n_rows=1
    )
    sensor_name_1, device_temp_1 = cbt_data_generator.get_device_name_temp(
        all_device_row_list, 0
    )
    sensor_name_2, device_temp_2 = cbt_data_generator.get_device_name_temp(
        all_device_row_list, 1
    )
    sensor_name_3, device_temp_3 = cbt_data_generator.get_device_name_temp(
        all_device_row_list, 2
    )
    return [
        html.Span("{0}: {1:.2f}".format(sensor_name_1, device_temp_1), style=style),
        html.Span("{0}: {1:0.2f}".format(sensor_name_2, device_temp_2), style=style),
        html.Span("{0}: {1:0.2f}".format(sensor_name_3, device_temp_3), style=style),
    ]


# Multiple components can update everytime interval gets fired.
@app.callback(
    Output("live-update-graph", "figure"), [Input("interval-component", "n_intervals")]
)
def update_graph_live(n):
    satellite = Orbital("TERRA")
    data = {"time": [], "Latitude": [], "Longitude": [], "Altitude": []}

    # TODO: Need to parse row_key by "#"
    # TODO: need to parallelize graph updates given the 3 different devices
    # Collect some data in a batch process at first
    # may have to hit a range of values or append to the read_rows list
    for i in range(180):
        time = datetime.datetime.now() - datetime.timedelta(seconds=i * 20)
        lon, lat, alt = satellite.get_lonlatalt(time)
        data["Longitude"].append(lon)
        data["Latitude"].append(lat)
        data["Altitude"].append(alt)
        data["time"].append(time)

    # Create the graph with subplots
    # TODO read through the make_subplots method and see if I can overlap plots easily
    fig = plotly.subplots.make_subplots(rows=2, cols=1, vertical_spacing=0.2)
    fig["layout"]["margin"] = {"l": 30, "r": 10, "b": 30, "t": 10}
    fig["layout"]["legend"] = {"x": 0, "y": 1, "xanchor": "left"}

    # TODO: Create 3 stacks of the subplots or overlap everything?
    fig.append_trace(
        {
            "x": data["time"],
            "y": data["Altitude"],
            "name": "Altitude",
            "mode": "lines+markers",
            "type": "scatter",
        },
        1,
        1,
    )
    fig.append_trace(
        {
            "x": data["Longitude"],
            "y": data["Latitude"],
            "text": data["time"],
            "name": "Longitude vs Latitude",
            "mode": "lines+markers",
            "type": "scatter",
        },
        2,
        1,
    )

    return fig


if __name__ == "__main__":
    app.run_server(debug=True, host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))
