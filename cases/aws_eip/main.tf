resource "aws_instance" "test1" {
  ami           = "${var.ami}"
  instance_type = "${var.instance_type}"
  subnet_id     = "${aws_subnet.test_subnet.id}"
}

resource "aws_eip" "test1" {
  # NOTE: 'public_ipv4_pull' is not supported.
  instance = "${aws_instance.test1.id}"

  vpc = true
}

resource "aws_instance" "test2" {
  ami           = "${var.ami}"
  instance_type = "${var.instance_type}"
  subnet_id     = "${aws_subnet.test_subnet.id}"
  private_ip    = "${cidrhost(aws_subnet.test_subnet.cidr_block, 100)}"
}

resource "aws_eip" "test2" {
  # NOTE: 'public_ipv4_pull' is not supported.
  vpc = true

  instance                  = "${aws_instance.test2.id}"
  associate_with_private_ip = "${aws_instance.test2.private_ip}"
}

resource "aws_network_interface" "test" {
  subnet_id = "${aws_subnet.test_subnet.id}"
}

resource "aws_eip" "test3" {
  vpc = true
  network_interface = "${aws_network_interface.test.id}"
}
