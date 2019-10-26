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
- terraform 0.12.1
- pip install anything in "requirements.txt"

## Usage

_Listed use cases(ex: template code, utility to make workflows easier, etc.)_

- foo

[![Open in Cloud Shell](http://gstatic.com/cloudssh/images/open-btn.png)](https://console.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/sungchun12/iot-python-webapp.git)

_OR_

1.  Activate Cloud Shell: <https://cloud.google.com/shell/docs/quickstart#start_cloud_shell>
2.  Clone repository

```bash
git clone https://github.com/sungchun12/iot-python-webapp.git
```

## Order of Operations

_Listed steps for how the application/pipeline works_

1. Create bucket for terraform tfstate backups to be stored. Use gcloud manually(only needs to be done once upfront)
2. Create bucket for encrypted service account json ONLY for decrypting KMS secret. Use gcloud manually(only needs to be done once upfront)
3. Build and push docker image using gcloud builds submit command(cloud build)
4. Deploy terraform infrastructure(cloud build, add permissions to cloud build default service account-check tutorial)
5. Allow unauthenticated requests to app. Use gcloud(cloud build)
6. Install Github Cloudbuild app manually through console. One-time setup

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

## Contribute

All feedback is welcome! You can use the issue tracker to submit bugs, ideas, etc. Pull requests are splendid!

## Resources

- [How to choose a repo license?](https://choosealicense.com/)
- [Share a stackshare decision!](https://stackshare.io/sungchun12/my-stack)
- [How to develop in vscode & docker?](https://github.com/sungchun12/dev-containers/blob/master/INSTALLME.md)
