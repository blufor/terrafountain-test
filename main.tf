provider "google" {
  credentials = file("/home/blufor/.config/gcloud/application_default_credentials.json")
  project     = "fontana-286108"
  region      = "europe-west4"
  zone        = "europe-west4-a"
	version     = "< 3.0.0"
}

// VPC network
//
resource "google_compute_network" "vpc_network" {
  name                    = "fontana-test"
  auto_create_subnetworks = "true"
}

// Network firewall
resource "google_compute_firewall" "default" {
  name    = "test-firewall"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "9200", "5601"]
  }

	source_ranges = ["94.142.235.197/32"]
  source_tags = ["fontana-test"]
}

// Compute instance
//
resource "google_compute_instance" "elastic" {
  name         = "elastic"
  machine_type = "n1-standard-1"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-minimal-1804-lts"
    }
  }

  // Local SSD disk
  //scratch_disk {
  //  interface = "NVME"
  //}

  network_interface {
    network = google_compute_network.vpc_network.self_link

    access_config {
      // Ephemeral IP
    }
  }

	metadata = {
		ssh-keys = <<EOT
blufor:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDOtTOMlAdpWZdOxNXIk1hK7xZ7VV5cUMdvbfxNjup5jlvmUZhgbgtou1n3ylhFwAhft/BDEUKvnD+t7hBVTZQ10Da+cWaRXj0GBU5vxaZdvzyXa8IcAzVUs6tYJfQSU6gh7uoDfU3F467JnxsSik9843UYAE29bYIYPliDkJZhxPN6VWy+RJ7hDXTBk3bAJXMj9FMcln2q85lRgrIQszixz7CBc79BukdTvq7v/q93Ih968VgbNYQAV0HcSHo+YFDbAUQo2QnwCk3lk7rEEmt2fAQ+VqJ8JscB+VVgrWiqYevEpYTfmgrLV/QbDd6LMLpE52Yh70sGhMUZFFo+v+bkiHvZ7kkgidukZwwzgrkQxXrS5eF1yIUZIm18+edQVcStiabzLtd031EY2+ueJ7OlRvkGapVYe1nhJaIbf2IrDfliLZTIS4XhoYSn5VtYaKjlagXjXMMJGEINha9q2//T9Srq4BCj2mn4sBRjo0woguolzJXaJcg41kQWEYaYsIgNjsHptGRCj82meOczxAZINCo/YE4bRfney0UmjM0VqDy7Ec7JZ6zQx53q2NT+lS4Wbtw6yiuuzX8jcKD5L2ULMyo3bFezzCVlHKBSS7HBHtOFBekT7Xo2aj1AeHCqyYHj2pwYXd6jrqFN00MhxTMY0ALrPWl84gufB2AIvoSbXw== blufor
EOT
	}

  metadata_startup_script = file("./user-script")

}


