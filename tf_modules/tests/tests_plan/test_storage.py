import os
import re


import tftest

# path to terraform storage module
TF = tftest.TerraformTest(
    os.path.join(os.path.dirname(os.path.abspath(__file__)), "modules/storage")
)


def setup():
    TF.setup(command="plan")


def test_resources():
    """Test that plan contains all expected resources."""
    values = re.findall(r"(?m)^\s*\+\s+(google_storage_bucket\S+)\s*^", TF.setup_output)
    assert values == [
        "google_storage_bucket.data-store",
        "google_storage_bucket.dataflow-staging",
    ], values


def test_attributes():
    """Test that resources have the correct attributes."""
    values = re.findall(r'(?m)^\s*triggers\.foo:\s*"(\S+)"\s*^', TF.setup_output)
    assert values == ["foo"], values


def test_attributes_tfvars():
    """Test that a different variable generates different attributes."""
    plan = TF.plan(tf_vars={"foo_var": '["foo", "spam"]'})
    values = re.findall(r'(?m)^\s*triggers\.foo:\s*"(\S+)"\s*^', plan)
    assert values == ["foo", "spam"], values
