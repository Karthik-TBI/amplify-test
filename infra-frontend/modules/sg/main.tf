# modules/security_groups/data.tf
data "aws_vpc" "selected" {
  tags = {
    Name = "pw-vpc-${var.env}"
  }
}



# Create a security group for Lambda functions
resource "aws_security_group" "lambda_sg" {
  name        = "pw-sg-${var.env}-lambda"
  description = "Security group for Lambda functions"
  vpc_id      = data.aws_vpc.selected.id

  # Outbound rules - allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # No inbound rules by default since Lambda functions don't need incoming traffic
  # Add specific inbound rules only if other services need to communicate with Lambda
  
  # Add specific inbound rules only if other services need to communicate with Lambda
  tags = merge(
    var.tags,
    {
      Name = "pw-sg-${var.env}-lambda"
    }
  )
}