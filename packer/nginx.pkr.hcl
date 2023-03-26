variable "image_tag" {
  type = string
}


source "yandex" "nginx" {
  folder_id           = "b1gnpekpfbd8fa4c4a55"
  source_image_family = "ubuntu-1804-lts"
  ssh_username        = "ubuntu"
  token               = "y0_AgAAAAA1M__hAATuwQAAAADeXjaDH33DPfhlSnGs0YifyiygLRP3pQo"
  use_ipv4_nat        = "true"
}

build {
  sources = ["source.yandex.nginx"]
  provisioner "ansible" {
    playbook_file = "playbook.yml"
  }
}
