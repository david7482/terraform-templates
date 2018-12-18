provider "aws" {
  region = "${var.region}"
}

resource "aws_instance" "helloworld" {
  ami = "${lookup(var.ami, var.region)}"
  instance_type = "t2.micro"
}

resource "aws_eip" "ip" {
  instance = "${aws_instance.helloworld.id}"
}