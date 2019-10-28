# iot-python-webapp

## Repo Summary Statement

_The TLDR of what this repo does and why someone should care._

Use this repo template to isolate development workloads, and share it with your team. Hopefully, this minimizes the administrative overhead in starting and documenting your projects.

Live, real-time dashboard in a cloud run web app end to end.

<p align="center">
  <img src="https://github.com/sungchun12/iot-python-webapp/blob/cloud-build-config/documentation/iot-dashboard-example.gif">
</p>

Main Docker Dev Components:

- Debian Linux
- Python
- bash
- git
- gcloud SDK
- terraform 0.12.9
- pip install anything in "requirements.txt"

## Usage

_Listed use cases(ex: template code, utility to make workflows easier, etc.)_

- foo

## Reference Architecture Diagram

Insert image of of one slide diagram. Color code phases of the infrastructure and purpose.
Write down multiple steps

## Deployment Instructions

1. Manually fork the repo through the github interface

Insert image here of circling fork repo from a stranger's perspective

2. Create a new Google cloud project

Insert image here of creating new google project

3. Manually connect the github app to cloud build through the github/GCP interfaces: [Follow these instructions](https://cloud.google.com/solutions/managing-infrastructure-as-code#directly_connecting_cloud_build_to_your_github_repository)

[![Open in Cloud Shell](http://gstatic.com/cloudssh/images/open-btn.png)](https://console.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/sungchun12/iot-python-webapp.git)

_OR_

4.  Activate Cloud Shell: <https://cloud.google.com/shell/docs/quickstart#start_cloud_shell>
5.  Clone repository

```bash
# set the project ID within cloud shell
gcloud config set project <PROJECT_ID>

git clone https://github.com/<your-github-username>/iot-python-webapp.git

# change directory into the repo
cd iot_python_webapp/
```

Insert image here of example terminal at this point

6. Run the initial setup shell script that performs one-time tasks

```bash
# Example: bash $0 -e example@gmail.com -u user_123 -p ferrous-weaver-256122 -s demo-service-account -g gcp_signup_name_3 -b master

#template
bash /.initial_setup.sh [-e GITHUB_EMAIL] [-u GITHUB_USERNAME] [-p PROJECT_ID] [-s SERVICE_ACCOUNT_NAME] [-g GCP_USERNAME] [-b GITHUB_BRANCH_NAME]
```

Insert image of example terminal output

7. Run the first cloud build job that sets up everything in your project

```bash
gcloud builds submit --config=first_build.yaml
```

8. Check to see if the webapp exists in the url listed in the terminal after the `first_build.yaml` completes sucessfully

```bash
gcloud beta run services list
```

Insert image of example terminal output

### Triggering automatic deployment updates

9. Commit and push changes to your github repo. This will automatically trigger a build.

```bash
git status
git add --all
git commit -m "Update terraform config files"
git push origin
```

10. Check to see if the app exists after the cloudbuild history updates.

Insert link and image of cloud build history

```bash
gcloud beta run services list
```

### Destroying Terraform Resources

```bash
# deletes devices in IoT registry
# destroys terraform deployed resources
gcloud builds submit --config=destroy_build.yaml
```

Note: if you want to destroy everything, you can delete everything via the console OR simply delete the project you ran the deployment instructions in

## Order of Operations

_Listed steps for how the application/pipeline works_

_Destruction Steps_

1. Delete devices in iot registry
2. Terraform destroy
3. Delete manually created buckets

## Technologies

_List out the technical components(ex: database, serverless function, etc.)_

- Database:
- Middleware:

## Languages

_ex: Python 3.7, SQL(Standard), Terraform, etc._

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
- Setting up good parameters for interoperability across modules requires robust upfront repo planning

## Contribute

All feedback is welcome! You can use the issue tracker to submit bugs, ideas, etc. Pull requests are splendid!

## Resources

- [How to choose a repo license?](https://choosealicense.com/)
- [Share a stackshare decision!](https://stackshare.io/sungchun12/my-stack)
- [How to develop in vscode & docker?](https://github.com/sungchun12/dev-containers/blob/master/INSTALLME.md)
