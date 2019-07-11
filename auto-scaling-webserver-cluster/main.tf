terraform{
    required_version = ">= 0.11, < 0.12"
}

provider "aws"{
    region = "ap-south-1"
}

resource "aws_launch_configuration" "example"{
    image_id = "ami-04125d804acca5692"
    instance_type = "t2.micro"
    security_groups = ["${aws_security_group.instance.id}"]

    user_data = <<-EOF
                #!/bin/bash
                echo "Hello, World" > index.html
                nohup busybox httpd -f -p "${var.server_port}" &
                EOF

    lifecycle{
        create_before_destroy = true
    }
}

resource "aws_security_group" "instance"{
    name = "terraform-example-instance"

    ingress{
        from_port = "${var.server_port}"
        to_port = "${var.server_port}"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    lifecycle{
        create_before_destroy = true
    }
}
resource "auto_scaling_group" "example"{
    launch_configuration = "${aws_launch_configuration.example.id}"
    availabilty_zones = ["${data.aws_availability_zones.all.names}"]

    min_size = 2
    max_size = 10

    tag {
        key = "Name"
        value = "terraform-asg-example"
        propagate_at_launch = true
    }
}

data "aws_availability_zones" "all" {}

resource "aws_elb" "example"{
    name = "terraform_elb_example"
    availabilty_zones = "${data.aws_availability_zones.all.names}"
    security_groups = "${aws_security_group.elb.id}"

    listener {
        lb_port = 80
        lb_protocol = "http"
        instance_port = "${var.server_port}"
        instance_protocol = "http"
    }
    
    health_check{
        health_threshold = 2
        unheathy_threshold = 2
        timeout = 3
        interval = 30
        target = "HTTP:${var.server_port}/"
    }
}

resource "aws_security_group" "elb"{
    name = "terraform_elb_sg"

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}