
provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "c" {
  ami               = var.amiid[1]
  instance_type     = var.intanceid
  key_name          = "awspractice36"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "tomcat-machine"
  }

  connection {
    type="ssh"
    host=self.private_ip
    user="ec2-user"
    private_key=file("/etc/ansible/awspractice36.pem")
    timeout="1m"
  }
  provisioner "remote-exec" {
    inline = ["echo connection ho gya hai"]
  }
  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i '${self.private_ip},' -u 'ec2-user' --private-key='/etc/ansible/awspractice36.pem' tomcat.yml"
  }

}



variable "intanceid" {
  default = "t3.nano"
}
variable "amiid" {
  type    = list(string)
  default = ["ami-0bc7aabcf58d1e02a", "ami-0b1ed96948adabcd9"]
}
#ubuntu_ami=ami-006f82a1d5a27da54
#amazon_linux_ami=ami-0b1ed96948adabcd9
#rhel_ami=ami-0011550b539717e2a

