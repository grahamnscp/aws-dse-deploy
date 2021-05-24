# ELBs:

resource "aws_elb" "admin" {
  name = "${var.name_prefix}-admin"

  security_groups = ["${aws_security_group.admin-elb.id}" ]
  subnets = ["${aws_subnet.nw-subnet.id}"]

#  availability_zones = ["${split(",", data.aws_availability_zones.available.names[1])}"]

  listener {
    instance_port = 443
    instance_protocol = "tcp"
    lb_port = 443
    lb_protocol = "tcp"
  }

  listener {
    instance_port = 80
    instance_protocol = "tcp"
    lb_port = 80
    lb_protocol = "tcp"
  }

  listener {
    instance_port = 9042
    instance_protocol = "tcp"
    lb_port = 9042
    lb_protocol = "tcp"
  }

  listener {
    instance_port = 61621
    instance_protocol = "tcp"
    lb_port = 61621
    lb_protocol = "tcp"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 10
    timeout = 5
    target = "TCP:9042"
    interval = 30
  }

  instances = ["${aws_instance.node.*.id}"]

  idle_timeout = 240
  cross_zone_load_balancing = true
  connection_draining = true
  connection_draining_timeout = 400
}

resource "aws_elb" "apps" {
  name = "${var.name_prefix}-apps"

  security_groups = [ "${aws_security_group.apps-elb.id}", ]
  subnets = ["${aws_subnet.nw-subnet.id}"]

#  availability_zones = ["${split(",", data.aws_availability_zones.available.names[1])}"]

  listener {
    instance_port = 80
    instance_protocol = "tcp"
    lb_port = 80
    lb_protocol = "tcp"
  }

  listener {
    instance_port = 443
    instance_protocol = "tcp"
    lb_port = 443
    lb_protocol = "tcp"
  }

  listener {
    instance_port = 10000
    instance_protocol = "tcp"
    lb_port = 10000
    lb_protocol = "tcp"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 10
    timeout = 5
    target = "TCP:443"
    interval = 30
  }

  instances = ["${aws_instance.node.*.id}"]

  idle_timeout = 240
  cross_zone_load_balancing = true
  connection_draining = true
  connection_draining_timeout = 400
}

