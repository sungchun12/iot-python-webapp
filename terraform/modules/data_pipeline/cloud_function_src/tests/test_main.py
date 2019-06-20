import os
import random

from terraform.modules.data_pipeline.cloud_function_src.main import main

os.environ[
    "GOOGLE_APPLICATION_CREDENTIALS"
] = "C:/Users/sungwon.chung/Desktop/repos/serverless_dash_repo/serverless_dash/terraform/service_account.json"
PROJECT = os.environ["GCLOUD_PROJECT"] = "iconic-range-220603"
BIGTABLE_CLUSTER = os.environ["BIGTABLE_CLUSTER"] = "iot-stream-database"
TABLE_NAME_FORMAT = "hello-bigtable-system-tests-{}"
TABLE_NAME_RANGE = 10000


def test_main(capsys):
    table_name = TABLE_NAME_FORMAT.format(random.randrange(TABLE_NAME_RANGE))

    main(PROJECT, BIGTABLE_CLUSTER, table_name)

    out, _ = capsys.readouterr()
    assert "Creating the {} table.".format(table_name) in out
    assert "Writing a row of device data to the table." in out
    assert "Getting a single row of device data by row key." in out
    assert "25.875" in out
    assert "Scanning for all device data:" in out
    assert "25.87" in out
