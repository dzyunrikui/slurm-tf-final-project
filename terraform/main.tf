data "yandex_compute_image" "this" {
  name="packer-1679820521"
}


resource "yandex_compute_instance_group" "slurm_group" {
  count = var.vm_count
  name                = "test-ig"
  folder_id           = "$YC_FOLDER_ID"
  service_account_id  = "${yandex_iam_service_account.tfadmin.id}"
  deletion_protection = true
  instance_template {
    platform_id = "standard-v1"
    resources {
      memory = 2
      cores  = 2
    }
    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = "${data.yandex_compute_image.this.id}"
        size     = 4
      }
    }
    network_interface {
      network_id = "${yandex_vpc_network.this.id}"
      subnet_ids = ["${yandex_vpc_subnet.this[var.az[count.index % 3 ]].id }"]
    }
    labels = {
      label1 = "label1-value"
      label2 = "label2-value"
    }
    metadata = {
      foo      = "bar"
      ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    }
    network_settings {
      type = "STANDARD"
    }
  }

  variables = {
    test_key1 = "test_value1"
    test_key2 = "test_value2"
  }

  scale_policy {
    fixed_scale {
      size = 3
    }
  }

  allocation_policy {
    zones = ["ru-central1-a"]
  }

  deploy_policy {
    max_unavailable = 2
    max_creating    = 2
    max_expansion   = 2
    max_deleting    = 2
  }
}

resource "yandex_iam_service_account" "tfadmin"{
  name        = "tfadmin"
  description = "service acocunt for resource manager"
  folder_id   = "YC_FOLDER_ID"
}


data "yandex_resourcemanager_folder" "slurm-tf-final-project" {
  folder_id = "YC_FOLDER_ID"
}

resource "yandex_resourcemanager_folder_iam_binding" "tfadmin" {
  folder_id = "${data.yandex_resourcemanager_folder.slurm-tf-final-project.id}"
  role = "editor"
  members = [
    "serviceAccount:some_user_id",
  ]
}



