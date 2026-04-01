provider "aws" {
  alias  = "us-west-2"
  region = "us-west-2"

  assume_role {
    role_arn = var.assume_role_arn
  }
}

resource "aws_devicefarm_project" "device-farm-project" {
  name = "pw-devicefarm-${var.env}-testing"
  provider = aws.us-west-2
  tags = var.tags
}

resource "aws_devicefarm_device_pool" "android-device-pool" {
  name        = "android-device-pool"
  project_arn = aws_devicefarm_project.device-farm-project.arn
  max_devices = 3
  provider = aws.us-west-2
  tags        = var.tags

  rule {
    attribute = "AVAILABILITY"
    operator  = "EQUALS"
    value     = "\"AVAILABLE\""
  }

  rule {
    attribute = "FLEET_TYPE"
    operator  = "EQUALS"
    value     = "\"PUBLIC\""
  }

  rule {
    attribute = "FORM_FACTOR"
    operator  = "EQUALS"
    value     = "\"PHONE\""
  }

  rule {
    attribute = "PLATFORM"
    operator  = "EQUALS"
    value     = "\"ANDROID\""
  }

  rule {
    attribute = "OS_VERSION"
    operator  = "GREATER_THAN"
    value     = "\"5\""
  }
}


resource "aws_devicefarm_device_pool" "ios-device-pool" {
  name        = "ios-device-pool"
  project_arn = aws_devicefarm_project.device-farm-project.arn
  max_devices = 3
  provider = aws.us-west-2
  tags        = var.tags

  rule {
    attribute = "AVAILABILITY"
    operator  = "EQUALS"
    value     = "\"AVAILABLE\""
  }

  rule {
    attribute = "FLEET_TYPE"
    operator  = "EQUALS"
    value     = "\"PUBLIC\""
  }

  rule {
    attribute = "FORM_FACTOR"
    operator  = "EQUALS"
    value     = "\"PHONE\""
  }

  rule {
    attribute = "PLATFORM"
    operator  = "EQUALS"
    value     = "\"IOS\""
  }

  rule {
    attribute = "OS_VERSION"
    operator  = "GREATER_THAN"
    value     = "\"12\""
  }
}