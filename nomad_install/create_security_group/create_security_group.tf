variable "vpc_id" {
  type = string
}

variable "my_ip" {
  type = string
}

provider "aws" {
   region = "eu-central-1"
}

resource "aws_security_group" "allow_all" {
  name        = "allow_me_ssh"
  description = "Allow ssh from my ip, for demo; Suny July 2019"
  vpc_id      = "${var.vpc_id}"

  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    # get your IP and fill in
    cidr_blocks     = ["${var.my_ip}/32"]
  }
}

output "security_group_id" {
  value = "${aws_security_group.allow_all.id}"
}
