# Output Values:

output "region" {
  value = "${var.aws_region}"
}
output "domain_name" {
  value = "${var.domainname}"
}

output "bootstrap-public-name" {
  value = "${aws_instance.bootstrap.public_dns}"
}
output "bootstrap-public-ip" {
  value = "${aws_instance.bootstrap.public_ip}"
}
output "bootstrap-private-ip" {
  value = "${aws_instance.bootstrap.private_ip}"
}

output "node-public-names" {
  value = ["${aws_instance.node.*.public_dns}"]
}
output "node-public-ips" {
  value = ["${aws_instance.node.*.public_ip}"]
}
output "node-private-ips" {
  value = ["${aws_instance.node.*.private_ip}"]
}

#output "route53-admin" {
#  value = "${aws_route53_record.admin.name}"
#}
#output "route53-apps" {
#  value = "${aws_route53_record.apps.name}"
#}
#output "route53-bootstrap" {
#  value = ["${aws_route53_record.bootstrap.name}"]
#}
#output "route53-nodes" {
#  value = ["${aws_route53_record.node.*.name}"]
#}

output "elb-admin-public-dns" {
  value = ["${aws_elb.admin.dns_name}"]
}
output "elb-admin-instances" {
  value = ["${aws_elb.admin.*.instances}"]
}
output "elb-apps-instances" {
  value = ["${aws_elb.apps.*.instances}"]
}
