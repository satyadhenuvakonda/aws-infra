variable "AWS_ACCESS_KEY" {
}

variable "AWS_SECRET_KEY" {
}

variable "AWS_REGION" {
  default = "eu-west-1"
}

variable "AMIS" {
  type = map(string)
  default = {
    eu-west-1 = "ami-035966e8adab4aaad"
  }
}

# ami-047bb4163c506cd98
variable "PATH_TO_PRIVATE_KEY" {
  default = "k8s-key"
}

variable "PATH_TO_PUBLIC_KEY" {
  default = "k8s-key.pub"
}

variable "INSTANCE_USERNAME" {
  default = "ubuntu"
}


