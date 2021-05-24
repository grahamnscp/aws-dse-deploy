# Instances:

# Bootstrap Instance:
#
resource "aws_instance" "bootstrap" {
  instance_type = "${var.bootstrap_instance_type}"
  ami           = "${var.aws_centos_ami}"
  key_name      = "${var.key_name}"

  root_block_device {
    volume_type = "gp2"
    volume_size = "50"
    delete_on_termination = true
  }

  vpc_security_group_ids = ["${aws_security_group.instance.id}"]
  subnet_id              = "${aws_subnet.nw-subnet.id}"

  user_data              = "${file("./terraform/userdata.sh")}"

  tags = {
    Name = "${var.name_prefix}_bootstrap"
    owner = "${var.owner_tag}"
    expiration = "${var.expiration_tag}"
    purpose = "${var.purpose_tag}"
  }
}

# Node Instances:
#
resource "aws_instance" "node" {
  ami           = "${var.aws_centos_ami}"
  instance_type = "${var.node_instance_type}"
  key_name      = "${var.key_name}"

  root_block_device {
    volume_type = "gp2"
    volume_size = "100"
    delete_on_termination = true
  }

  # Second disk for data volumes
  ebs_block_device {
    device_name = "/dev/sdb"
    volume_size = "${var.data_volume_size}"
    volume_type = "gp2"
    delete_on_termination = true
  }

  count = "${var.node_count}"

  vpc_security_group_ids = ["${aws_security_group.instance.id}"]
  subnet_id              = "${aws_subnet.nw-subnet.id}"

  user_data              = "${file("./terraform/userdata.sh")}"

  tags = {
    Name = "${var.name_prefix}_node${count.index + 1}"
    owner = "${var.owner_tag}"
    expiration = "${var.expiration_tag}"
    purpose = "${var.purpose_tag}"
  }
}

