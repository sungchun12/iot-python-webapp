https://cloud.google.com/run/docs/authenticating/public


gcloud beta run services add-iam-policy-binding tf-dash-cloud-run-demo \
--member="allUsers" \
--role="roles/run.invoker" \
--region="us-central1"

gcloud beta run services update tf-dash-cloud-run-demo --allow-unauthenticated