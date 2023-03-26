variable "vm_name" {
  type        = string
  description = "Name of the virtual machine"
}



variable "cidr_blocks" {
  type        = list(list(string))
  description = "List of lists of IPv4 cidr blocks for subnets"
}

variable "labels" {
  type        = map(string)
  description = "Labels to add to resources"
}

variable "vpc_id" {
  type = string
  default = ""
  description = "VPC ID"
}

variable "az" {
  type = list(string)
  default = [
    "ru-central1-a",
    "ru-central1-b",
    "ru-central1-c"
  ]
}

variable "vm_count" {
  type = number
  description = "Number of vm to create"
}

