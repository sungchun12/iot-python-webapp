#build the docker image
docker build -t dash-demo .

#run it on port 8080 for cloud run even though 8050 is the default port
#https://cloud.google.com/run/docs/reference/container-contract#port
docker run -it --rm -p 8080:8080 dash-demo

#name the docker image
docker tag dash-demo justsung/dash-demo:1.0.0

#login to docker hub
docker login

#push docker image to docker hub
docker push justsung/dash-demo:1.0.0

#list of docker images
docker images

#tag image for google container registry
docker tag <image-id> gcr.io/<project-id>/<image-name>

#push image to google container registry
docker push gcr.io/<project-id>/<image-name>

# https://cloud.google.com/kubernetes-engine/docs/tutorials/hello-app#step_5_deploy_your_application
kubectl run dash-demo --image=gcr.io/iconic-range-220603/dash-demo --port 8080

# https://cloud.google.com/run/docs/quickstarts/build-and-deploy
