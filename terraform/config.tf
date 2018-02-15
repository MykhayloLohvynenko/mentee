# Configure the AWS Provider
provider "aws" {
  access_key = "AKIAJU5VHD7VAMXJMIRQ"
  # secret_key =  "env.AWS_SECRET_ACCESS_KEY"
  secret_key = "${var.secret_key}"
  region     = "us-west-2"
}

resource "aws_security_group" "HTTP" {
  name  = "HTTP"
  description = "allow access to port 80"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "ssh" {
  name  = "ssh"
  description = "allow access to port 22"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_key_pair" "auth" {
  key_name   = "mlohvynenko-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAq1nN3+7BehgOTuVLybXUqlhbf4D7ciZsX2caa8mQsWqp1iJwYFu/i82dRAt8umQxcr2o+8CBJmEwxWt2dUcL+Y7erRYQvZOr0REIS2xGcC2FJmwrUcyU0LebnAx18IYMUFHDZnBkRvYv8B+byJiWGB6YS662IBe7s7vni7m0sRMzEELkyOE1H7gxBbE+TbCvNfBXLN9Fjde9zQWJSqlodUitxFHsiKP1OXny5AXETURnwoS8cTiBWviViHeth0fM86qjZffJa1o4Yo3w6IRjUIG7/falKqQaSyZyjZG8QQBX9qhU8uKw1LUmJd1GSOJ8slsXqGuOo8dr9QkemJ9n+Q== mlohvynenko"
}

resource "aws_instance" "web" {
    ami = "ami-a58d0dc5" 
    # ami = "ami-1ee65166" # from amazone console
    instance_type = "t2.nano"
    key_name = "${aws_key_pair.auth.key_name}"
    security_groups = [
    "HTTP",
    "default",
    "ssh"
    ]

   connection {
      user = "ubuntu"
      # key_file = "${file("D:\CTCO-SRCH\ssh_keys\private.ppk")}"
      private_key = "${file("D:/CTCO-SRCH/ssh_keys/private.pem")}"
    }

    provisioner "remote-exec" {
      inline = [
        "sudo apt-get -y update",
        "sudo apt-get -y install nginx",
        "sudo service nginx start"
      ]
    }
}