#!/bin/bash

#----------------------------------------------------start--------------------------------------------------#
get_user_input() {
  echo

  read -p "$(echo -e "Enter ZONE (contoh: us-central1-c): ")" ZONE
  export ZONE
  echo

  echo
}

get_user_input

echo "Starting Execution"

export REGION="${ZONE%-*}"

gcloud config set compute/region $REGION

gcloud config set compute/zone $ZONE

export PROJECT_ID=$(gcloud config get-value project)

gcloud compute instances create gcelab2 --machine-type e2-medium --zone $ZONE

gcloud compute instances add-tags gcelab2 --tags http-server,https-server

gcloud compute firewall-rules create default-allow-http --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:80 --source-ranges=0.0.0.0/0 --target-tags=http-server

echo "Congratulations for Completing the Lab !!!"

#-----------------------------------------------------end----------------------------------------------------------#
