provider "aws"{
    region = "ap-south-1"
}

resource "aws_instance" "example" {
    ami = "ami-06832d84cd1dbb448"
    instance_type = "t2.micro"

    tags = {
        Name = "terraform-example"
    }
}
