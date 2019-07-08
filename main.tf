provider "aws"{
    region = "ap-south-1"
}

resource "aws_instance" "example" {
    ami = "ami-06832d84cd1dbb448"
    instance_type = "t2.micro"

    user_data = <<-EOF
		#!/bin/bash
		echo "Hello, World" > index.html
		nohup busybox httpd -f -p 8080 &
		EOF

    tags = {
        Name = "terraform-example"
    }
}
