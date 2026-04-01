resource "aws_wafv2_web_acl" "waf-web-acl" {
  name  = "pw-waf-${var.env}-acl"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "pw-waf-cloudwatch-metric-${var.env}"
    sampled_requests_enabled   = true
  }

  rule {
    name     = "pw-waf-rule-${var.env}-region-block"
    priority = 0

    action {
      block {}
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "pw-waf-cloudwatch-metric-${var.env}-region-block"
      sampled_requests_enabled   = true
    }

    statement {
      not_statement {
        statement {
          geo_match_statement {
            country_codes = ["US", "IN"]
          }
        }
      }
    }
  }

  ####################################################################################################

#     # Create the IP set for whitelisting
#    resource "aws_wafv2_ip_set" "whitelist" {
#   name               = "whitelist"
#   description        = "Whitelisted IPs"
#   scope             = "REGIONAL"  # Regional for ALB
#   ip_address_version = "IPV4"
#   addresses          = ["167.103.21.18/32"]

#   tags = var.tags
# }

# # IP Whitelist rule
# rule {
#   name     = "IPWhitelist"
#   priority = 1  # Higher priority than CommonRuleSet

#   action {
#     allow {}  # Allow the whitelisted IP
#   }

#   statement {
#     ip_set_reference_statement {
#       arn = aws_wafv2_ip_set.whitelist.arn
#     }
#   }

#   visibility_config {
#     cloudwatch_metrics_enabled = true
#     metric_name               = "IPWhitelistMetric"
#     sampled_requests_enabled  = true
#   }
# }

  ###################################################################################################

  rule {
    name     = "enable-captcha"
    priority = 1

    # action {
    #   captcha {}
    # }

    action {
      allow {}
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "pw-waf-cloudwatch-metric-${var.env}-enable-captcha"
      sampled_requests_enabled   = true
    }

    statement {
      geo_match_statement {
        country_codes = ["US", "IN"]
      }
    }

  #   captcha_config {
  #   immunity_time_property {
  #     immunity_time = 1800
  #   }
  # }
  }

  # rule {
  #   name = "captcha-for-uri-paths"
  #   priority = 2

  #   statement {
  #     byte_match_statement {
  #       search_string = "uri_path"
  #       field_to_match {
  #         uri_path {}
  #       }
  #       text_transformation {
  #         priority = 0
  #         type = "NONE"
  #       }
  #       positional_constraint = "EXACTLY"
  #     }
  #   }

  #   action {
  #     captcha {}
  #   }

  #   visibility_config {
  #     sampled_requests_enabled = true
  #     cloudwatch_metrics_enabled = true
  #     metric_name = "pw-waf-cloudwatch-metric-${var.env}-uri-path-captcha"
  #   }
  # }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesAmazonIpReputationList"
    priority = 3

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesAmazonIpReputationList"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesBotControlRuleSet"
    priority = 4

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesBotControlRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesBotControlRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "rate-limit-rule"
    priority = 5

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit                 = 200
        aggregate_key_type    = "IP"
        evaluation_window_sec = 60
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "pw-waf-cloudwatch-metric-${var.env}-rate-limit"
      sampled_requests_enabled   = true
    }
  }


  # Add this rule after your existing rules
rule {
  name     = "AWSManagedRulesKnownBadInputsRuleSet"
  priority = 6  # Next priority after your rate-limit-rule

  override_action {
    none {}
  }

  statement {
    managed_rule_group_statement {
      name        = "AWSManagedRulesKnownBadInputsRuleSet"
      vendor_name = "AWS"
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "AWSManagedRulesKnownBadInputsRuleSet"
    sampled_requests_enabled   = true
  }
}

  tags = var.tags
}

# resource "aws_wafv2_web_acl_association" "waf-web-acl-association-appsync" {
#   resource_arn = var.appsync-graphql-arn
#   web_acl_arn  = aws_wafv2_web_acl.waf-web-acl.arn
# }

resource "aws_wafv2_web_acl_association" "waf-web-acl-association-cognito" {
  resource_arn = var.cognito-arn
  web_acl_arn  = aws_wafv2_web_acl.waf-web-acl.arn
}




######################################################################################

# Create CloudWatch log group for WAF logs
resource "aws_cloudwatch_log_group" "waf_logs" {
  name              = "aws-waf-logs-${var.env}-acl"
  retention_in_days = 365
  
  tags = var.tags

}



######################################################################################

# Configure WAF logging
resource "aws_wafv2_web_acl_logging_configuration" "waf_logging" {
  log_destination_configs = [aws_cloudwatch_log_group.waf_logs.arn]
  resource_arn            = aws_wafv2_web_acl.waf-web-acl.arn
  
  # Optional: Configure redacted fields if you need to hide sensitive data in logs
  # redacted_fields {
  #   single_header {
  #     name = "authorization"
  #   }
    
  #   # Uncomment if you need to redact cookies
  #   # cookies {
  #   #   match_pattern {
  #   #     included_cookies = ["session", "auth"]
  #   #   }
  #   #   match_scope = "ALL"
  #   #   oversize_handling = "TRUNCATE"
  #   # }
  # }
  logging_filter {
    default_behavior = "KEEP"

    filter {
      behavior = "DROP"
      condition {
        action_condition {
          action = "COUNT"
        }
      }
      requirement = "MEETS_ANY"
    }
  }
}
