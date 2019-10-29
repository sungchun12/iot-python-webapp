# iot-python-webapp

## Repo Summary Statement

_The TL;DR of what this repo does and why you should care._

Learn how to deploy a live, real-time dashboard in a python web app powered by end to end infrastructure as code!

The repo sets up simulated real-time iot data, 3 data pipelines, cicd trigger automation, and 40 GCP resources in total through terraform-all in under 10 minutes!

_What you can make too!_

<p align="center">
  <img src="https://github.com/sungchun12/iot-python-webapp/blob/documentation/documentation/live-webapp-demo.gif">
</p>

## Usage

_Listed use cases(ex: template code, utility to make workflows easier, etc.)_

- Use this as a demo for yourself and your team to launch an end to end data application
- Gain familiarity with terraform infrastructure as code to make launching future data pipelines easier
- Explore building a frontend in python using the open source [Dash Framework](https://plot.ly/dash/)
- Reference the build yaml files as starter cicd templates for yourself
- See how easy it is to build and push a docker image to a container registry
- Get a look and feel for encrypting and decrypting credentials using KMS
- Show me how to do it better and how YOU are using it! ;)

## Reference Architecture Diagram

Insert image of of one slide diagram. Color code phases of the infrastructure and purpose.
Write down multiple steps

## Deployment Instructions

1. Manually fork the repo through the github interface

<p align="center">
  <img src="https://github.com/sungchun12/iot-python-webapp/blob/documentation/documentation/fork-git-repo.png">
</p>

2. Create a new Google cloud project

<p align="center">
  <img src="https://github.com/sungchun12/iot-python-webapp/blob/documentation/documentation/create-gcp-project.gif">
</p>

3. Manually connect the github app to cloud build through the github/GCP interfaces or [Follow these instructions](https://cloud.google.com/solutions/managing-infrastructure-as-code#directly_connecting_cloud_build_to_your_github_repository)-note the link is for a different tutorial

<p align="center">
  <img src="https://github.com/sungchun12/iot-python-webapp/blob/documentation/documentation/connect-cloudbuild-to-github.gif">
</p>

4. [![Open in Cloud Shell](http://gstatic.com/cloudssh/images/open-btn.png)](https://console.cloud.google.com/cloudshell/editor)

5. Clone the repo and get into starting position for deployment

```bash
# set the project ID within cloud shell
gcloud config set project <PROJECT_ID>

git clone https://github.com/<your-github-username>/iot-python-webapp.git

# change directory into the repo
cd iot_python_webapp/
```

_What your terminal should look like_

<p align="center">
  <img src="https://github.com/sungchun12/iot-python-webapp/blob/documentation/documentation/verify-git-clone.png">
</p>

6. Run the initial setup shell script that performs one-time tasks

```bash
# Example: bash $0 -e example@gmail.com -u user_123 -p ferrous-weaver-256122 -s demo-service-account -g gcp_signup_name_3 -b master

# Notes: leave the GITHUB_BRANCH_NAME as "master" for this demo. You can find the GCP_USERNAME for your project in the cloud shell terminal before the "@" "realsww123@cloudshell"

# template
bash /.initial_setup.sh [-e GITHUB_EMAIL] [-u GITHUB_USERNAME] [-p PROJECT_ID] [-s SERVICE_ACCOUNT_NAME] [-g GCP_USERNAME] [-b GITHUB_BRANCH_NAME]
```

_Double check the secrets file is uploaded to the bucket and terraform files reflect what you set your command line arguments_

<p align="center">
  <img src="https://github.com/sungchun12/iot-python-webapp/blob/documentation/documentation/verify-initial-setup.png">
</p>

7. Run the first cloud build job that sets up everything in your project

```bash
gcloud builds submit --config=first_build.yaml
```

8. Check to see if the webapp exists in the url listed in the terminal after the `first_build.yaml` completes sucessfully

```bash
gcloud beta run services list --platform managed
```

_Click on the link to launch the web app_

<p align="center">
  <img src="https://github.com/sungchun12/iot-python-webapp/blob/documentation/documentation/first-build-success.png">
</p>

### Trigger Automatic Deployment Updates

9. Commit and push changes to your github repo. This will automatically trigger a build.

```bash
git status
git add --all
git commit -m "Update terraform config files"
git push origin
```

_Explore the cloud build history to verify a successful build_

<p align="center">
  <img src="https://github.com/sungchun12/iot-python-webapp/blob/documentation/documentation/trigger-build-example.gif">
</p>

10. Check to see if the app exists after the cloudbuild history updates.

_You should see an updated timestamp to the web app_

```bash
gcloud beta run services list --platform managed
```

### Destroy Terraform Resources

```bash
# deletes devices in IoT registry
# destroys terraform deployed resources
gcloud builds submit --config=destroy_build.yaml
```

<p align="center">
  <img src="https://github.com/sungchun12/iot-python-webapp/blob/documentation/documentation/destroy-build-example.gif">
</p>

Note: if you want to destroy everything, you can delete everything via the console OR simply delete the project you ran the deployment instructions in for a clean slate!

## Order of Operations

_Listed steps for how the application/pipeline works_

## Languages

_ex: Python 3.7, SQL(Standard), Terraform, etc._

- Python 3.7
- Terraform 12.9
- Bash 4.4.12

## Technical Concepts

_Illustrate design choices, and highlight nuances worth pointing out_

- foo

## Further Reading

- [IoT Reference Example](https://github.com/GoogleCloudPlatform/professional-services/tree/master/examples/iot-nirvana)

- [Terraform Cloud Build Example](https://github.com/GoogleCloudPlatform/solutions-terraform-cloudbuild-gitops)

## Lessons Learned

_Name pain points, pleasant surprises, and how I would develop this better next time/going forward_

- KMS key rings can NOT be deleted, so that GCP has a record of key ring names that can't be used anymore. If you're going to redeploy, you must rename the key ring or it'll error out.
- An IoT registry can not be force deleted if devices are tied to it
- Cloud Run for terraform is still needing further development. Need work outside terraform to allow app to expose to public internet
- For google apis, if it's the first time enabling, it may error out and force you to manually enable or rerun the terraform build
- Managing secrets and setting up IAM at a granular level is a project of its own. You'll notice most of the roles grant wide permissions for demo purposes.
- Setting up good parameters for interoperability across modules requires robust, upfront repo planning

## Contribute

All feedback is welcome! You can use the issue tracker to submit bugs, ideas, etc. Pull requests are splendid!

## Resources

- [How to choose a repo license?](https://choosealicense.com/)
- [Share a stackshare decision!](https://stackshare.io/sungchun12/my-stack)
- [How to develop in vscode & docker?](https://github.com/sungchun12/dev-containers/blob/master/INSTALLME.md)
