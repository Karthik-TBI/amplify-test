output "devicefarm-project-arn" {
  value = aws_devicefarm_project.device-farm-project.arn
}

output "devicefarm-android-devicepool-arn" {
  value = aws_devicefarm_device_pool.android-device-pool.arn
}

output "devicefarm-ios-devicepool-arn" {
  value = aws_devicefarm_device_pool.ios-device-pool.arn
}