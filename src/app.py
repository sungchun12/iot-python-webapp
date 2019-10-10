# -*- coding: utf-8 -*-
#!/usr/bin/env python

import sys
import datetime
import os
from collections import deque

import dash
import dash_core_components as dcc
import dash_html_components as html
import plotly
from dash.dependencies import Input, Output

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
        try:
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
                self.service_account_json,
                self.project_id,
                self.cloud_region,
                registry_id,
            )
            return devices_list
        except IndexError:
            print(
                "Refresh browser until live data starts flowing through! Exiting application now."
            )
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

    @staticmethod
    def get_name_temp_time(all_device_row_list, device_index):
        """Returns name and temperature objects for single iot device
        """
        device_data = all_device_row_list[device_index][0]
        row_key = list(device_data.keys())[0]
        device_temp = device_data[row_key]["temp"]
        temp_timestamp = device_data[row_key]["temp_timestamp"]
        sensor_name = row_key.split("#")[1]
        return sensor_name, device_temp, temp_timestamp

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


# initialize class and create row keys list once
cbt_data_generator = iot_pipeline_data()
devices_list = cbt_data_generator.get_device_names()
row_keys_list = cbt_data_generator.create_device_rowkeys(devices_list)

# setup empty dictionary lists
device_1 = cbt_data_generator.set_graph_data_limit(n_items=20)
device_2 = cbt_data_generator.set_graph_data_limit(n_items=20)
device_3 = cbt_data_generator.set_graph_data_limit(n_items=20)

external_stylesheets = ["https://codepen.io/chriddyp/pen/bWLwgP.css"]

app = dash.Dash(__name__, external_stylesheets=external_stylesheets)

app.layout = html.Div(
    html.Div(
        [
            html.H4("IoT Temperature Device Live Dashboard"),
            html.Div(id="live-update-text"),
            dcc.Graph(
                id="live-update-graph",
                animate=False,
                style={
                    "width": "49%",
                    "display": "inline-block",
                    "vertical-align": "middle",
                },
            ),
            dcc.Interval(
                id="interval-component",
                interval=1 * 1000,  # in milliseconds
                n_intervals=0,
            ),
        ],
        style={"textAlign": "center"},
    )
)


@app.callback(
    Output("live-update-text", "children"), [Input("interval-component", "n_intervals")]
)
def update_metrics(n):
    style = {"padding": "5px", "fontSize": "16px"}
    all_device_row_list = cbt_data_generator.create_all_device_rows(
        row_keys_list, n_rows=1
    )
    device_name_1, device_temp_1, temp_timestamp_1 = cbt_data_generator.get_name_temp_time(
        all_device_row_list, 0
    )
    device_name_2, device_temp_2, temp_timestamp_2 = cbt_data_generator.get_name_temp_time(
        all_device_row_list, 1
    )
    device_name_3, device_temp_3, temp_timestamp_3 = cbt_data_generator.get_name_temp_time(
        all_device_row_list, 2
    )
    return [
        html.Span("{0}: {1:.2f}".format(device_name_1, device_temp_1), style=style),
        html.Span("{0}: {1:0.2f}".format(device_name_2, device_temp_2), style=style),
        html.Span("{0}: {1:0.2f}".format(device_name_3, device_temp_3), style=style),
    ]


# Multiple components can update everytime interval gets fired.
@app.callback(
    Output("live-update-graph", "figure"), [Input("interval-component", "n_intervals")]
)
def update_graph_live(n):
    all_device_row_list = cbt_data_generator.create_all_device_rows(
        row_keys_list, n_rows=1
    )
    device_name_1, device_temp_1, temp_timestamp_1 = cbt_data_generator.get_name_temp_time(
        all_device_row_list, 0
    )
    device_name_2, device_temp_2, temp_timestamp_2 = cbt_data_generator.get_name_temp_time(
        all_device_row_list, 1
    )
    device_name_3, device_temp_3, temp_timestamp_3 = cbt_data_generator.get_name_temp_time(
        all_device_row_list, 2
    )

    device_1["device_name"] = device_name_1
    device_1["temp"].append(float(device_temp_1))
    device_1["temp_timestamp"].append(temp_timestamp_1)

    device_2["device_name"] = device_name_2
    device_2["temp"].append(float(device_temp_2))
    device_2["temp_timestamp"].append(temp_timestamp_2)

    device_3["device_name"] = device_name_3
    device_3["temp"].append(float(device_temp_3))
    device_3["temp_timestamp"].append(temp_timestamp_3)

    # Create the graph with subplots
    fig = plotly.subplots.make_subplots(rows=3, cols=1, vertical_spacing=0.1)
    fig["layout"]["margin"] = {"l": 30, "r": 10, "b": 30, "t": 10}
    fig["layout"]["legend"] = {
        "x": 0.5,
        "y": 1.1,
        "xanchor": "center",
        "yanchor": "top",
        "orientation": "h",
    }
    fig.update_layout(autosize=True, width=700, height=600)

    # Update xaxis properties
    fig.update_xaxes(title_text="Timestamp", row=3, col=1)

    # Update yaxis properties
    fig.update_yaxes(title_text="Temperature", row=2, col=1)

    fig.append_trace(
        {
            "x": list(device_1["temp_timestamp"]),
            "y": list(device_1["temp"]),
            "name": device_1["device_name"],
            "mode": "lines+markers",
            "type": "scatter",
        },
        1,
        1,
    )
    fig.append_trace(
        {
            "x": list(device_2["temp_timestamp"]),
            "y": list(device_2["temp"]),
            "name": device_2["device_name"],
            "mode": "lines+markers",
            "type": "scatter",
        },
        2,
        1,
    )
    fig.append_trace(
        {
            "x": list(device_3["temp_timestamp"]),
            "y": list(device_3["temp"]),
            "name": device_3["device_name"],
            "mode": "lines+markers",
            "type": "scatter",
        },
        3,
        1,
    )

    return fig


if __name__ == "__main__":
    app.run_server(debug=True, host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))
