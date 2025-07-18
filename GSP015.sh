#!/bin/bash

get_user_input() {
  echo

  read -p "$(echo -e "Enter ZONE (contoh: us-central1-c): ")" ZONE
  export ZONE
  echo

  echo
}

get_user_input

gcloud config set compute/zone "$ZONE"

# Task 1. Creating a cluster
gcloud container clusters create hello-world --zone="$ZONE"

echo "Task 1. Creating a cluster Completed"

# Task 3. Get the sample code
git clone https://github.com/GoogleCloudPlatform/kubernetes-engine-samples

cd kubernetes-engine-samples/quickstarts/hello-app

# Task 2. Building and publishing the Hello World app
docker build -t gcr.io/$DEVSHELL_PROJECT_ID/hello-app:1.0 .

gcloud docker -- push gcr.io/$DEVSHELL_PROJECT_ID/hello-app:1.0

# Task 4. Deploying the Hello World app
kubectl create deployment hello-app --image=gcr.io/$DEVSHELL_PROJECT_ID/hello-app:1.0

echo "Task 4. Deploying the Hello World app Completed"

kubectl get deployments

kubectl get pods

kubectl expose deployment hello-app --name=hello-app --type=LoadBalancer --port=80 --target-port=8080

kubectl get svc hello-app

echo "All Task Completed"
