# Route53 DNS Entries:

resource "aws_route53_record" "admin" {
  zone_id = "${var.route53_zone_id}"
  name = "${var.admin_dns}.${var.domainname}."
  type = "CNAME"
  ttl = "300"
  records = ["${aws_elb.admin.dns_name}"]
}

resource "aws_route53_record" "apps" {
  zone_id = "${var.route53_zone_id}"
  name = "*.${var.apps_dns}.${var.domainname}."
  type = "CNAME"
  ttl = "300"
  records = ["${aws_elb.apps.dns_name}"]
}

resource "aws_route53_record" "api" {
  zone_id = "${var.route53_zone_id}"
  name = "api.${var.domainname}."
  type = "CNAME"
  ttl = "300"
  records = ["${aws_elb.apps.dns_name}"]
}

resource "aws_route53_record" "bootstrap" {
  zone_id = "${var.route53_zone_id}"
  name = "bootstrap.${var.domainname}"
  type = "A"
  ttl = "300"
  records = ["${aws_instance.bootstrap.public_ip}"]
}

resource "aws_route53_record" "node" {
  count = "${var.node_count}"
  zone_id = "${var.route53_zone_id}"
  name = "node${count.index + 1}.${var.domainname}"
  type = "A"
  ttl = "300"
  records = ["${element(aws_instance.node.*.public_ip, count.index)}"]
}

