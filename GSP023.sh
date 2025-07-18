#!/bin/bash

#----------------------------------------------------start--------------------------------------------------#
get_user_input() {
  echo

  read -p "$(echo -e "Enter REGION (contoh: us-central1): ")" REGION
  export REGION
  echo

  read -p "$(echo -e "Enter PROJECT ID (contoh: qwiklabs-gcp-03-01688e208e14):")" PROJECT_ID
  export PROJECT_ID
  echo

  echo
}

get_user_input

echo "Starting Execution"

# Task 1. Get the sample code
gcloud storage cp -r gs://spls/gsp023/flex_and_vision/ .

cd flex_and_vision

# Task 2. Authenticate API requests
gcloud iam service-accounts create qwiklab \
  --display-name "My qwiklab Service Account"

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
--member serviceAccount:qwiklab@${PROJECT_ID}.iam.gserviceaccount.com \
--role roles/owner

gcloud iam service-accounts keys create ~/key.json \
--iam-account qwiklab@${PROJECT_ID}.iam.gserviceaccount.com

export GOOGLE_APPLICATION_CREDENTIALS="/home/${USER}/key.json"

# Task 3. Testing the application locally
virtualenv -p python3 env

source env/bin/activate

pip install -r requirements.txt

gcloud app create --region=$REGION

export CLOUD_STORAGE_BUCKET=${PROJECT_ID}

gsutil mb gs://${PROJECT_ID}

# Task 5. Deploying the App to App Engine Flexible
cat> app.yaml <<EOF
runtime: python
env: flex
entrypoint: gunicorn -b :8080 main:app

runtime_config:
    operating_system: "ubuntu22"
    runtime_version: "3.12"

env_variables:
  CLOUD_STORAGE_BUCKET: $PROJECT_ID

manual_scaling:
  instances: 1
EOF

gcloud config set app/cloud_build_timeout 1000

gcloud app deploy --quiet

sleep 30 

echo "All Task Completed"

python main.py  
