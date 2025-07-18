sudo apt-get update

sudo apt-get -y -qq install git

sudo apt-get install -y python-mpltoolkits.basemap

sudo apt install python3-pip -y

pip install --upgrade basemap basemap-data basemap-data-hires pyproj

pip install matplotlib==3.3.4  numpy==1.23.5

git clone https://github.com/GoogleCloudPlatform/training-data-analyst

cd training-data-analyst/CPB100/lab2b

bash ingest.sh

bash install_missing.sh

python3 transform.py

export PROJECT_ID=$(gcloud config get-value project)

gsutil cp earthquakes.* gs://$PROJECT_ID/earthquakes/
