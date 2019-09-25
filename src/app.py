# -*- coding: utf-8 -*-
#!/usr/bin/env python

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

# import iot sample utilties
import iot_manager

# import class from cloud function src
# from terraform.modules.data_pipeline.cloud_function_src.main import (
#     bigtable_input_generator,
# )

# TODO: call on environment vars from the cloud function and pass through bigtable_input_generator
# TODO: call on core iot to list latest 3 registered devices


class environment_metadata:
    def __init__(self):
        self.project_id = os.environ["GCLOUD_PROJECT_NAME"]
        self.instance_id = os.environ["BIGTABLE_CLUSTER"]
        self.table_id = os.environ["TABLE_NAME"]
        self.cloud_region = os.environ["CLOUD_REGION"]
        # TODO update these clients
        self.bigtable_client = bigtable.Client(project=self.project_id, admin=True)
        # self.iot_client = bigtable.Client(project=self.project_id, admin=True)
        # self.cloud_func_client = bigtable.Client(project=self.project_id, admin=True)
        self.service_account_json = os.path.abspath(
            "../terraform/service_account.json"
        )  # TODO relative path may change
        # self.iot_client = iot_manager.get_client(self.service_account_json)

    def get_metadata(self):
        """Stores all gcp metadata needed to update live dashboard
        """
        registries_list = iot_manager.list_registries(
            self.service_account_json, self.project_id, self.cloud_region
        )
        registry_id = registries_list[0]
        devices_list = iot_manager.list_devices(
            self.service_account_json, self.project_id, self.cloud_region, registry_id
        )
        in_scope_devices = devices_list[3:]
        cloud_func_metadata = self.get_cloud_func_metadata()
        return iot_metadata, cloud_func_metadata

    def get_cloud_func_metadata(self):
        pass


satellite = Orbital("TERRA")

external_stylesheets = ["https://codepen.io/chriddyp/pen/bWLwgP.css"]

app = dash.Dash(__name__, external_stylesheets=external_stylesheets)

# TODO: update layout
# TODO:update intervals to 500 milliseconds? Look at the average execution time of function
app.layout = html.Div(
    html.Div(
        [
            html.H4("TERRA Satellite Live Feed"),
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


@app.callback(
    Output("live-update-text", "children"), [Input("interval-component", "n_intervals")]
)

# TODO: create new  x-axis: Date/time, y-axis: temperature
def update_metrics(n):
    lon, lat, alt = satellite.get_lonlatalt(datetime.datetime.now())
    style = {"padding": "5px", "fontSize": "16px"}
    return [
        html.Span("Longitude: {0:.2f}".format(lon), style=style),
        html.Span("Latitude: {0:.2f}".format(lat), style=style),
        html.Span("Altitude: {0:0.2f}".format(alt), style=style),
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
    # Collect some data
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
