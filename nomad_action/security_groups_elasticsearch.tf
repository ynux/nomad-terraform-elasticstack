resource "aws_security_group_rule" "allow_elasticsearch_rest" {
  type        = "ingress"
  from_port   = "9200"
  to_port     = "9200"
  protocol    = "tcp"
  cidr_blocks = "${var.allowed_inbound_cidr_blocks}"

  security_group_id = "${var.security_group_id}"
}
resource "aws_security_group_rule" "allow_elasticsearch_intra" {
  type        = "ingress"
  from_port   = "9300"
  to_port     = "9300"
  protocol    = "tcp"
  cidr_blocks = "${var.allowed_inbound_cidr_blocks}"

  security_group_id = "${var.security_group_id}"
}

