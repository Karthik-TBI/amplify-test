data "aws_lb" "customer-alb" {
  name = "pw-alb-customer-${var.env}"
}

data "aws_lb" "internal-alb" {
  name = "pw-alb-internal-${var.env}"
}

data "aws_lb" "customer-website-alb" {
  name = "pw-alb-website-${var.env}"
}