#!/bin/bash
#----------------------------------------------------start--------------------------------------------------#
get_user_input() {
  echo
  
  read -p "$(echo -e "Enter BUCKET (contoh: tf-bucket-287061): ")" BUCKET
  export BUCKET
  echo
  
  read -p "$(echo -e "Enter INSTANCE (contoh: tf-instance-367742): ")" INSTANCE
  export INSTANCE
  echo
  
  read -p "$(echo -e "Enter VPC (contoh: tf-vpc-255292): ")" VPC
  export VPC
  echo
  
  echo
}

get_user_input

echo "Starting Execution"

export ZONE=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-zone])")

export REGION=$(echo "$ZONE" | cut -d '-' -f 1-2)

export PROJECT_ID=$DEVSHELL_PROJECT_ID

instances_output=$(gcloud compute instances list --format="value(id)")

# Read instance IDs into variables
IFS=$'\n' read -r -d '' instance_id_1 instance_id_2 <<< "$instances_output"

# Output instance IDs with custom name

export INSTANCE_ID_1=$instance_id_1

export INSTANCE_ID_2=$instance_id_2

touch main.tf
touch variables.tf
mkdir modules
cd modules
mkdir instances
cd instances
touch instances.tf
touch outputs.tf
touch variables.tf
cd ..
mkdir storage
cd storage
touch storage.tf
touch outputs.tf
touch variables.tf
cd

cat > variables.tf <<EOF_END
variable "region" {
 default = "$REGION"
}

variable "zone" {
 default = "$ZONE"
}

variable "project_id" {
 default = "$PROJECT_ID"
}
EOF_END

cat > main.tf <<EOF_END
terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.53.0"
    }
  }
}

provider "google" {
  project     = var.project_id
  region      = var.region
  zone        = var.zone
}

module "instances" {
  source     = "./modules/instances"
}
EOF_END

terraform init

echo "Task 1. Create the configuration files Completed"

cat > modules/instances/instances.tf <<EOF_END
resource "google_compute_instance" "tf-instance-1" {
  name         = "tf-instance-1"
  machine_type = "n1-standard-1"
  zone         = "$ZONE"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
 network = "default"
  }
  metadata_startup_script = <<-EOT
        #!/bin/bash
    EOT
  allow_stopping_for_update = true
}

resource "google_compute_instance" "tf-instance-2" {
  name         = "tf-instance-2"
  machine_type = "n1-standard-1"
  zone         =  "$ZONE"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
	  network = "default"
  }
  metadata_startup_script = <<-EOT
        #!/bin/bash
    EOT
  allow_stopping_for_update = true
}
EOF_END

terraform import module.instances.google_compute_instance.tf-instance-1 $INSTANCE_ID_1

terraform import module.instances.google_compute_instance.tf-instance-2 $INSTANCE_ID_2

terraform plan

terraform apply -auto-approve

echo "Task 2. Import infrastructure Completed"

cat > modules/storage/storage.tf <<EOF_END
resource "google_storage_bucket" "storage-bucket" {
  name          = "$BUCKET"
  location      = "us"
  force_destroy = true
  uniform_bucket_level_access = true
}
EOF_END

cat >> main.tf <<EOF_END
module "storage" {
  source     = "./modules/storage"
}
EOF_END

terraform init

terraform apply -auto-approve

cat > main.tf <<EOF_END
terraform {
	backend "gcs" {
		bucket = "$BUCKET"
		prefix = "terraform/state"
	}
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.53.0"
    }
  }
}

provider "google" {
  project     = var.project_id
  region      = var.region
  zone        = var.zone
}

module "instances" {
  source     = "./modules/instances"
}

module "storage" {
  source     = "./modules/storage"
}
EOF_END

terraform init

echo "Task 3. Configure a remote backend Completed"

cat > modules/instances/instances.tf <<EOF_END
resource "google_compute_instance" "tf-instance-1" {
  name         = "tf-instance-1"
  machine_type = "e2-standard-2"
  zone         = "$ZONE"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
 network = "default"
  }
  metadata_startup_script = <<-EOT
        #!/bin/bash
    EOT
  allow_stopping_for_update = true
}

resource "google_compute_instance" "tf-instance-2" {
  name         = "tf-instance-2"
  machine_type = "e2-standard-2"
  zone         =  "$ZONE"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
	  network = "default"
  }
  metadata_startup_script = <<-EOT
        #!/bin/bash
    EOT
  allow_stopping_for_update = true
}

resource "google_compute_instance" "$INSTANCE" {
  name         = "$INSTANCE"
  machine_type = "e2-standard-2"
  zone         = "$ZONE"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
 network = "default"
  }
  metadata_startup_script = <<-EOT
        #!/bin/bash
    EOT
  allow_stopping_for_update = true
}
EOF_END

terraform init

terraform apply -auto-approve

echo "Task 4. Modify and update infrastructure Completed"

terraform taint module.instances.google_compute_instance.$INSTANCE

terraform init

terraform plan

terraform apply -auto-approve

cat > modules/instances/instances.tf <<EOF_END
resource "google_compute_instance" "tf-instance-1" {
  name         = "tf-instance-1"
  machine_type = "e2-standard-2"
  zone         = "$ZONE"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
 network = "default"
  }
  metadata_startup_script = <<-EOT
        #!/bin/bash
    EOT
  allow_stopping_for_update = true
}

resource "google_compute_instance" "tf-instance-2" {
  name         = "tf-instance-2"
  machine_type = "e2-standard-2"
  zone         =  "$ZONE"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
	  network = "default"
  }
  metadata_startup_script = <<-EOT
        #!/bin/bash
    EOT
  allow_stopping_for_update = true
}
EOF_END

terraform apply -auto-approve

echo "Task 5. Destroy resources Completed"

cat >> main.tf <<EOF_END
module "vpc" {
    source  = "terraform-google-modules/network/google"
    version = "~> 6.0.0"

    project_id   = "$PROJECT_ID"
    network_name = "$VPC"
    routing_mode = "GLOBAL"

    subnets = [
        {
            subnet_name           = "subnet-01"
            subnet_ip             = "10.10.10.0/24"
            subnet_region         = "$REGION"
        },
        {
            subnet_name           = "subnet-02"
            subnet_ip             = "10.10.20.0/24"
            subnet_region         = "$REGION"
            subnet_private_access = "true"
            subnet_flow_logs      = "true"
            description           = "Hola"
        },
    ]
}
EOF_END

terraform init

terraform plan

terraform apply -auto-approve

cat > modules/instances/instances.tf <<EOF_END
resource "google_compute_instance" "tf-instance-1" {
  name         = "tf-instance-1"
  machine_type = "e2-standard-2"
  zone         = "$ZONE"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
	  network = "$VPC"
    subnetwork = "subnet-01"
  }
  metadata_startup_script = <<-EOT
        #!/bin/bash
    EOT
  allow_stopping_for_update = true
}

resource "google_compute_instance" "tf-instance-2" {
  name         = "tf-instance-2"
  machine_type = "e2-standard-2"
  zone         = "$ZONE"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
	  network = "$VPC"
    subnetwork = "subnet-02"
  }
  metadata_startup_script = <<-EOT
        #!/bin/bash
    EOT
  allow_stopping_for_update = true
}
EOF_END

terraform init

terraform plan

terraform apply -auto-approve

echo "Task 6. Use a module from the Registry Completed"

cat >> main.tf <<EOF_END
resource "google_compute_firewall" "tf-firewall"{
  name    = "tf-firewall"
	network = "projects/$PROJECT_ID/global/networks/$VPC"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_tags = ["web"]
  source_ranges = ["0.0.0.0/0"]
}
EOF_END

terraform init

terraform plan

terraform apply -auto-approve

echo "Task 6. Configure a firewall Completed"

echo "Congratulations For Completing The Lab !!!"

#-----------------------------------------------------end----------------------------------------------------------#
