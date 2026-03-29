resource "aws_instance" "instance" {
  for_each =  var.COMPONENTS
  ami           = "ami-0220d79f3f480ecf5"
  instance_type = "t3.small"
  vpc_security_group_ids = ["sg-0ce01673ed9893e29"]

  tags = {
    Name = each.key
  }
}

resource "aws_route53_record" "dns" {
  for_each = var.COMPONENTS
  zone_id = "Z02549774QMYGMZM7W06"
  name    = "${each.key}-dev"
  type    = "A"
  ttl     = 30
  records = [aws_instance.instance[each.key].private_ip]
}

variable "COMPONENTS" {
  default = {
    frontend = "",
    postgresql = "",
    auth-service = "",
    portfolio-service = "",
    analytics-service = ""
  }
}

resource "null_resource" "ansible" {
  depends_on = [aws_route53_record.dns]
  for_each = var.COMPONENTS
  provisioner "remote-exec" {
    connection {
      type = "ssh"
      host = aws_instance.instance[each.key].public_ip
      user = ec2-user
      password = DevOps321
    }
    inline = [
      "sudo dnf install python3.13-pip.noarch -y",
      "sudo pip3.13 install ansible",
      "ansible-pull -i localhost, -U https://github.com/phanikolluri/wmp-ansible-v4.git main.yml -e env=dev -e COMPONENT=${each.key} "
    ]
  }
}







