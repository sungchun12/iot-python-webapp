# iot-python-webapp

## Repo Summary

_The TL;DR of what this repo does and why you should care._

Learn how to deploy a live, real-time dashboard in a python web app powered by end to end infrastructure as code!

The repo sets up simulated real-time iot data, 3 data pipelines, cicd trigger automation, and 40 GCP resources in total through terraform-all in under 10 minutes!

_What you can make!_

![Live Webapp Demo](/documentation/live-webapp-demo.gif)

## Use Cases

_Listed use cases(ex: template code, utility to make workflows easier, etc.)_

- Use this as a demo for yourself and your team to launch an end to end data application
- Gain familiarity with terraform infrastructure as code to make launching future data pipelines easier: [terraform modules](/tf_modules/main.tf)
- Explore building a frontend in python using the open source [Dash Framework](https://plot.ly/dash/)
- Reference the build yaml files as starter cicd templates for yourself: [first_build.yaml](first_build.yaml), [cloudbuild.yaml](cloudbuild.yaml), [destroy_build.yaml](destroy_build.yaml)
- See how easy it is to build and push a docker image to a container registry: [Dockerfile](Dockerfile)
- Get a look and feel for encrypting and decrypting credentials using KMS: [secrets creator](/tf_modules/modules/secrets_manager/main.tf)
- Explore how to read and write to a bigtable database with python: [cloud function src](tf_modules/modules/data_pipeline/cloud_function_src/main.py)
- Show me how to do it better and how YOU are using it! ;)

_See bottom of this README for specific directories and links related to the above_

## Architecture Diagram

Insert image of of one slide diagram. Color code phases of the infrastructure and purpose.
Write down multiple steps

## Deployment Instructions

1. [Sign up for a free trial](https://cloud.google.com/free/?hl=ar) _OR_ use an existing GCP account

2. Manually fork the repo through the github interface

![fork git repo](/documentation/fork-git-repo.png)

3. Create a new Google cloud project

![create gcp project](/documentation/create-gcp-project.gif)

4. Manually connect the github app to cloud build through the github/GCP interfaces or [Follow these instructions](https://cloud.google.com/solutions/managing-infrastructure-as-code#directly_connecting_cloud_build_to_your_github_repository)-note the link is for a different tutorial

![create gcp project](/documentation/connect-cloudbuild-to-github.gif)

5. [Open in Cloud Shell](https://console.cloud.google.com/cloudshell/editor) _OR_ [Download the SDK](https://cloud.google.com/sdk/docs/quickstarts)

_Note: The rest of these instructions are written for cloud shell_

6. Clone the repo and get into starting position for deployment

```bash
# set the project ID within cloud shell
gcloud config set project <PROJECT_ID>

git clone https://github.com/<your-github-username>/iot-python-webapp.git

# change directory into the repo
cd iot_python_webapp/
```

_What your terminal should look like_

![verify git clone](/documentation/verify-git-clone.png)

7. Run the initial setup shell script that performs one-time tasks

```bash
# Example: bash ./initial_setup.sh -e example@gmail.com -u user_123 -p ferrous-weaver-256122 -s demo-service-account -g gcp_signup_name_3 -b master

# Notes: leave the GITHUB_BRANCH_NAME as "master" for this demo. You can find the GCP_USERNAME for your project in the cloud shell terminal before the "@" "realsww123@cloudshell"

# template
bash ./initial_setup.sh [-e GITHUB_EMAIL] [-u GITHUB_USERNAME] [-p PROJECT_ID] [-s SERVICE_ACCOUNT_NAME] [-g GCP_USERNAME] [-b GITHUB_BRANCH_NAME]
```

_Double check the secrets file is uploaded to the bucket and terraform files reflect what you set your command line arguments_

![verify initial setup](/documentation/verify-initial-setup.png)

8. Run the first cloud build job that sets up everything in your project

```bash
gcloud builds submit --config=first_build.yaml
```

9. Check to see if the webapp exists in the url listed in the terminal after the `first_build.yaml` completes sucessfully

```bash
gcloud beta run services list --platform managed
```

_Click on the link to launch the web app_

![launch web app](/documentation/launch-web-app.gif)

### Trigger Automatic Deployment Updates

10. Commit and push changes to your github repo. This will automatically trigger a build.

```bash
# this will create a new commit to the master branch in github
git status
git add --all
git commit -m "Update terraform config files"
git push origin
```

_Explore the cloud build history to verify a successful build_

![trigger build example](/documentation/trigger-build-example.gif)

11. Check to see if the app exists after the cloudbuild history updates.

_You should see an updated timestamp to the web app_

```bash
gcloud beta run services list --platform managed
```

### Destroy Terraform-Managed Resources

```bash
# deletes devices in IoT registry
# destroys terraform deployed resources
gcloud builds submit --config=destroy_build.yaml
```

![destroy build example](/documentation/destroy-build-example.gif)

_Note: if you want to destroy everything, you can delete everything via the console OR simply delete the project you ran the deployment instructions in for a clean slate!_

## Languages

- [Python 3.7](https://www.python.org/downloads/release/python-370/)
- [Terraform 12.9](https://www.terraform.io/)
- [Bash 4.4.12](https://www.gnu.org/software/bash/)

## Technical Design Highlights

_Illustrate design choices, and highlight nuances worth pointing out_

- We store the tfstate in a remote storage bucket to prevent multiple deployments overriding each other

- Bigtable was used to taste and see how fast read/writes were for time series data. Turns out each read/write takes less than 500ms on average, which is pretty fast for python

## Lessons Learned

_Pain points, pleasant surprises, and how I would develop this better next time/going forward_

- KMS key rings can NOT be deleted, so that GCP has a record of key ring names that can't be used anymore. If you're going to redeploy, you must rename the key ring or it'll error out.
- An IoT registry can not be force deleted if devices are tied to it
- Cloud Run for terraform is still needing further development. Need work outside terraform to allow app to expose to public internet
- For google apis, if it's the first time enabling, it may error out and force you to manually enable or rerun the terraform build
- Managing secrets and setting up IAM at a granular level is a project of its own. You'll notice most of the roles grant wide permissions for demo purposes.
- Setting up good parameters for interoperability across modules requires robust, upfront repo planning
- Dataflow jobs have to be replaced everytime you redeploy infrastructure with terraform-even if you don't make any changes! This will disrupt the live data flow, so be mindful when redeploying
- Terraform features follow a couple months delay after a new GCP service is released
- Next time, I would create a distinct pub/sub push subscription for the cloud function and pull subscriptions for the dataflow jobs for the same topic to employ the [proper throughput mechanisms](https://cloud.google.com/pubsub/docs/subscriber#push-subscription)

## Further Reading

- [My stackshare decision!](https://stackshare.io/sungchun12/my-stack)

- [IoT Reference Example](https://github.com/GoogleCloudPlatform/professional-services/tree/master/examples/iot-nirvana)

- [Another IoT Reference Example](https://cloud.google.com/solutions/designing-connected-vehicle-platform)

- [Terraform Cloud Build Example](https://github.com/GoogleCloudPlatform/solutions-terraform-cloudbuild-gitops)

## Contribute

All feedback is welcome! You can use the issue tracker to submit bugs, ideas, etc. Pull requests are splendid!

My master branch will be protected, so no changes will come through without my formal approval.
