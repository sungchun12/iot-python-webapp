# iot-python-webapp

## Repo Summary

Learn how to deploy a live, real-time dashboard in a Python web app powered by end to end infrastructure as code!

The repo sets up simulated real-time iot data, 3 data pipelines, cicd trigger automation, and 40 GCP resources in total through terraform-all in under 10 minutes!

Questions Explored:

- How do I make future Sung's life easier with this repo?
- Is terraform as easy as to pick up as random internet dwellers say?
- Can I build a frontend application in Python?
- What's it like working with Bigtable and are read/writes as fast as advertised?
- Is cicd worth the setup effort?
- What's it like working with KMS encryption/decryption?
- How do I make your life easier exploring the above with this repo?

_What you'll be making!_

![Live Webapp Demo](/documentation/live-webapp-demo.gif)

## Use Cases

- Use this as a demo for yourself and your team to launch an end to end data application
- Gain familiarity with terraform infrastructure as code to make launching future data pipelines easier: [terraform modules](/tf_modules/main.tf)
- Explore building a frontend in Python using the open source [Dash Framework](https://plot.ly/dash/)
- Reference the build yaml files as starter cicd templates for yourself: [first_build.yaml](first_build.yaml), [cloudbuild.yaml](cloudbuild.yaml), [destroy_build.yaml](destroy_build.yaml)
- See how easy it is to build and push a docker image to a container registry: [Dockerfile](Dockerfile)
- Get a look and feel for encrypting and decrypting credentials using KMS: [secrets creator](/tf_modules/modules/secrets_manager/main.tf)
- Explore how to read and write to a bigtable database with Python: [cloud function src](tf_modules/modules/data_pipeline/cloud_function_src/main.py)
- Show me how to do it better and how YOU are using it! ;)

## Architecture Diagram

_What you'll ALSO be making!_

![architecture diagram](/documentation/architecture-drawio.png)

1. Buckets and core infrastructure to kick off the data pipelines. Decrypts and re-encrypts private service account keys each build
2. Streaming real-time data with Dataflow-provided templates written in Java and a custom Python cloud function to write to Bigtable
3. Store and consume data for multiple audiences
4. The frontend webapp as demonstrated by the gif above! Decrypts once to access IoT Core registered devices
5. Most important part: people worth sharing all this juicy data with
6. Logging and monitoring automatically happen in the background. Some IAM access is created in terraform

| Component              | Product Overview                                                        | Purpose                                                                                                                                         | Azure Equivalents                    | AWS Equivalents                             |
| ---------------------- | ----------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------ | ------------------------------------------- |
| Cloud Storage          | Object store for all kinds of file types                                | Store sensitive files such as tfstate and the private service account key. Raw data for ad hoc usage                                            | File/Blob Storage                    | S3                                          |
| Cloud Build            | Build workflows for testing and deployment across multiple environments | Deploy, CICD, and destroy terraform-managed infrastructure                                                                                      | Pipelines                            | CodePipeline                                |
| Compute Engine         | Scalable virtual machines                                               | Simulate devices registering to IoT Core                                                                                                        | Virtual Machines                     | EC2                                         |
| Cloud IoT Core         | Manage, deploy, and ingest data from dispersed devices                  | Manages the simulated devices and ingests their data to Pub/Sub                                                                                 | IoT Hub                              | IoT Core                                    |
| Cloud Pub/Sub          | Message queue for ingesting and delivering data to other services       | Middleware that serves as a shock-absorber and funnels data for further transformation                                                          | Service Bus, Storage Queues          | Kinesis                                     |
| Key Management Service | Managed encryption keys for secrets protection                          | Encrypts and decrypts the private service account key for each deployment                                                                       | Key Vault                            | KMS                                         |
| Cloud Dataflow         | Serverless stream and batch data processing                             | Loads data into parquet files and into a BigQuery table                                                                                         | Stream Analytics                     | Glue                                        |
| Cloud Functions        | Event-driven serverless compute                                         | Writes simulated temperature device data to Bigtable                                                                                            | Functions                            | Lambda Functions                            |
| Cloud Bigtable         | NoSQL database for large workloads                                      | Stores simulated device data and [configured for time series read operations](https://cloud.google.com/bigtable/docs/schema-design-time-series) | Table Storage                        | DynamoDB                                    |
| BigQuery               | Serverless analytics data warehouse                                     | Stores simulated device data for aggregate reporting metrics using standard SQL                                                                 | Data Lake Analytics, Data Lake Store | Redshift/Athena depending on who you ask ;) |
| Cloud Run              | Run Docker containers in a fully-managed, serverless app                | Hosts the dash app that visualizes simulated device data in real-time by querying Bigtable every second                                         | Container Instances                  | Fargate                                     |
| Cloud IAM              | Access control for managing cloud resources                             | Gives cloud build and terraform access to deploy and edit the services in scope                                                                 | IAM                                  | IAM                                         |

## Deployment Instructions

1. [Sign up for a free trial](https://cloud.google.com/free/?hl=ar) _OR_ use an existing GCP account

2. Manually fork the repo through the github interface

![fork git repo](/documentation/fork-git-repo.png)

3. Create a new Google cloud project

![create gcp project](/documentation/create-gcp-project.gif)

4. Manually connect the github app to cloud build through the github/GCP interfaces or [follow these instructions](https://cloud.google.com/solutions/managing-infrastructure-as-code#directly_connecting_cloud_build_to_your_github_repository)-note the link is for a different tutorial

_Note: you may likely be prompted to manually enable the Cloud Build api_

![create gcp project](/documentation/connect-cloudbuild-to-github.gif)

5. [Open in Cloud Shell](https://console.cloud.google.com/cloudshell/editor) _OR_ [Download the SDK](https://cloud.google.com/sdk/docs/quickstarts)

_Note: The rest of these instructions are written for cloud shell_

6. Clone the repo and get into starting position for deployment

```bash
# set the project ID within cloud shell
gcloud config set project <PROJECT_ID>

git clone https://github.com/<your-github-username>/iot-python-webapp.git

# change directory into the repo
cd iot-python-webapp/
```

_What your terminal should look like_

![verify git clone](/documentation/verify-git-clone.png)

7. Run the initial setup shell script that performs one-time tasks

```bash
# Example: bash ./initial_setup.sh -e example@gmail.com -u user_123 -p ferrous-weaver-256122 -s demo-service-account -g gcp_signup_name_3 -b master

# Notes: leave the GITHUB_BRANCH_NAME as "master" for this demo
# You can find the GCP_USERNAME for your project in the cloud shell terminal before the "@" in "realsww123@cloudshell"
# I recommend you investigate the script which showcases actions to NOT be managed by terraform
# Creates secret encryptions, terraform service accounts, and buckets as pre-requisites to the terraform deployment

# append this syntax to the end of the bash command
# if you want to save your terminal output to a text file
####
2>&1 | tee SomeFile.txt
####

# template
bash ./initial_setup.sh [-e GITHUB_EMAIL] [-u GITHUB_USERNAME] [-p PROJECT_ID] [-s SERVICE_ACCOUNT_NAME] [-g GCP_USERNAME] [-b GITHUB_BRANCH_NAME]
```

_Double check the secrets file is uploaded to the bucket and terraform files reflect what you set your command line arguments_

![verify initial setup](/documentation/verify-initial-setup.png)

8. Run the first cloud build job that sets up everything in your project

```bash
# note: enabling apis may lag behind other services
# it is accounted for in the initial setup script above

gcloud builds submit --config=first_build.yaml
```

9. Check to see if the webapp exists in the url listed in the terminal after the `first_build.yaml` completes sucessfully

```bash
gcloud beta run services list --platform managed
```

_Click on the link to launch the web app_

![launch web app](/documentation/launch-web-app.gif)

## Trigger Automatic Deployment Updates

Commit and push changes to your github repo. This will automatically trigger a build.

```bash
# this will create a new commit to the master branch in github
# Note: MUST be the first commit to trigger build properly
# Any other commit will not reference the appropriate terraform config
# you recently created above

git status
git add --all
git commit -m "Update terraform config files"
git push origin
```

_Explore the cloud build history to verify a successful build_

![trigger build example](/documentation/trigger-build-example.gif)

Check to see if the app exists after the cloudbuild history updates.

_You should see an updated timestamp to the web app_

```bash
gcloud beta run services list --platform managed
```

## Destroy Terraform-Managed Resources

```bash
# deletes devices in IoT registry
# destroys terraform deployed resources
gcloud builds submit --config=destroy_build.yaml
```

![destroy build example](/documentation/destroy-build-example.gif)

_Note: if you want to destroy everything, you can delete everything via the console OR simply delete the project you ran the deployment instructions in for a clean slate!_

## Languages

- [Python 3.7](https://www.python.org/downloads/release/python-370/)
- [Terraform HCL 12.9](https://www.terraform.io/)
- [Bash 4.4.12](https://www.gnu.org/software/bash/)

## Technical Design Highlights

- I store the tfstate in a remote storage bucket to prevent multiple deployments overriding each other

- Bigtable was used to taste and see how fast read/writes were for time series data. Turns out each read/write takes less than 500ms on average, which is pretty fast for Python

- Terraform has yet to create an official module dependency framework. They currently have resource dependency, but it's an incredible amount of code overhead to implement for enabling google apis: [click here](https://github.com/hashicorp/terraform/issues/1178#issuecomment-449158607). Thankfully, module dependency is on the official roadmap, so I'm leaving this in the backlog to enhance after this feature is released: [click here](https://github.com/hashicorp/terraform/issues/10462#issuecomment-527651371)

- Cloud function writes to Bigtable because it's more than enough to handle 3 devices sending concurrent invocations. Dataflow is an alternative

- Dataflow Java templates are used to write to BigQuery and GCS because it was easy as pie to implement

- KMS is used to launch terraform services with specific role access AND for cloud run to access the IoT device registry. In a real-world context, it'd follow least-privilege access principles

- There is no formal testing of this demo outside of multiple walkthroughs of the deployment instructions. My goal was to explore, not to create the most robust app for production on day one

## Lessons Learned

- KMS key rings can NOT be deleted, so that GCP has a record of key ring names that can't be used anymore. If you're going to redeploy, you must rename the key ring or it'll error out

- An IoT registry can not be force deleted if devices are tied to it

- Cloud Run for terraform is still needing further development. Need work outside terraform to allow app to expose to public internet

- For google apis, if it's the first time enabling, it may error out and force you to manually enable or rerun the terraform build

- Managing secrets and setting up IAM at a granular level is a project of its own. You'll notice most of the roles grant wide permissions for demo purposes

- Setting up good parameters for interoperability across modules requires robust, upfront repo planning

- Dataflow jobs have to be replaced everytime you redeploy infrastructure with terraform-even if you don't make any changes! This will disrupt the live data flow, so be mindful when redeploying

- Terraform features follow a couple months delay after a new GCP service is released

- Next time, I would create a distinct pub/sub push subscription for the cloud function and pull subscriptions for the dataflow jobs for the same topic to employ the [proper throughput mechanisms](https://cloud.google.com/pubsub/docs/subscriber#push-subscription)

## Further Reading

- [My stackshare decision!](https://stackshare.io/sungchun12/decisions/103080800236049641): Think twitter for developers

- [IoT Reference Example](https://github.com/GoogleCloudPlatform/professional-services/tree/master/examples/iot-nirvana): The java equivalent of what this repo does

- [Another IoT Reference Example](https://cloud.google.com/solutions/designing-connected-vehicle-platform): Official GCP documentation for reference architecture

- [Terraform Cloud Build Example](https://github.com/GoogleCloudPlatform/solutions-terraform-cloudbuild-gitops): If you want to focus on cloudbuild setup

- [IoT Pipeline Qwiklab](https://www.qwiklabs.com/focuses/605?parent=catalog): Where I got the device simulator scripts and general starting point

## Contribute

All feedback is welcome! You can use the issue tracker to submit bugs, ideas, etc. Pull requests are splendid!

My master branch will be protected, so no changes will come through without my formal approval.
