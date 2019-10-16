# -*- coding: utf-8 -*-
#!/usr/bin/env python

import os

import dash
import dash_daq as daq
import dash_core_components as dcc
import dash_html_components as html
import plotly
from dash.dependencies import Input, Output, State

# import created class to access bigtable iot data
import access_iot_data

# initialize class and create row keys list once
cbt_data_generator = access_iot_data.iot_pipeline_data()
devices_list = cbt_data_generator.get_device_names()
row_keys_list = cbt_data_generator.create_device_rowkeys(devices_list)

# setup empty dictionary lists
device_1 = cbt_data_generator.set_graph_data_limit(n_items=20)
device_2 = cbt_data_generator.set_graph_data_limit(n_items=20)
device_3 = cbt_data_generator.set_graph_data_limit(n_items=20)

external_stylesheets = ["https://codepen.io/chriddyp/pen/bWLwgP.css"]

app = dash.Dash(__name__, external_stylesheets=external_stylesheets)

colors = {
    "background": "#303030",
    "text": "#FFFFFF",
    "graph-text": "#FFFFFF",
    "toggle-switch-text": "#07e9fe",
}

app.layout = html.Div(
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
            id="interval-component", interval=1 * 1000, n_intervals=0  # in milliseconds
        ),
    ],
    style={
        "textAlign": "center",
        "background-color": colors["background"],
        "color": colors["text"],
    },
)

# Callbacks for stopping interval update
# @app.callback(
#     Output("interval-component", "disabled"),
#     [Input("live-toggle-switch", "value")],
# )
# def stop_live_updates(value):
#     if value == False:
#         return "Live data stopped"
#     else:
#         return "Live data streaming"


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
    fig.update_layout(
        autosize=True,
        width=700,
        height=600,
        plot_bgcolor=colors["background"],
        paper_bgcolor=colors["background"],
        font={"color": colors["graph-text"]},
    )

    # Update xaxis properties
    fig.update_xaxes(title_text="Timestamp", row=3, col=1)

    # Update yaxis properties
    fig.update_yaxes(title_text="Temperature", row=2, col=1)

    # setup data
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

    # append data to each device subplot
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
