
#########################################################################################################

resource "aws_amplify_app" "portal-app" {
  name       = "pw-amplify-${var.env}-portal-app"
  repository = "https://bitbucket.org/prioritywaste/portal-frontend"
  oauth_token =  "ZLVrFYZJxGfgoQaNZYmnePXbyjSDPrUli-_o2CGGafPC_QjBSKoW4ah_N4oKi-yMgZZRwmrlXS88i0XmDMh8bC_nh8w="
  enable_branch_auto_build = false
  enable_auto_branch_creation   = false
  enable_branch_auto_deletion   = false
  auto_branch_creation_patterns = [var.env]
  platform = "WEB_COMPUTE"
  # auto_branch_creation_config {
  #   enable_auto_build           = true
  #   enable_pull_request_preview = false
  #   enable_performance_mode     = false
  #   framework                   = "Next.js - SSR"
  # }

  build_spec = <<-EOT
    version: 0.1
    frontend:
      phases:
        preBuild:
          commands:
            - npm i
        build:
          commands:
            - npm run build
      artifacts:
        baseDirectory: .next
        files:
          - '**/*'
      cache:
        paths:
          - node_modules/**/*
  EOT

  custom_rule {
    source = "<*>"
    status = "200"
    target = "<*>"
    condition = "<IN>"
  }

  custom_rule {
    source = "<*>"
    status = "200"
    target = "<*>"
    condition = "<US>"
  }

  custom_rule {
    source = "/forgotPassword"
    status = "200"
    target = "/forgotPassword"
  }

  custom_rule {
    source = "<*>"
    status = "302"
    target = "/forgotPassword"
  }

  environment_variables = {
    NEXT_PUBLIC_CLIENT_ID = var.cognito-user-pool-client-id
    NEXT_PUBLIC_USER_POOL_ID = var.cognito-user-pool-id
  }

  tags = var.tags
}

resource "aws_amplify_branch" "amplify_branch_portal" {
  app_id            = aws_amplify_app.portal-app.id
  branch_name       = var.env
  enable_auto_build = false
  tags              = var.tags

}

#########################################################################################################

#website resource
resource "aws_amplify_app" "web-app" {
  name       = "pw-amplify-${var.env}-web-app"
  repository = "https://bitbucket.org/prioritywaste/portal-frontend-website"
  oauth_token = "ZLVrFYZJxGfgoQaNZYmnePXbyjSDPrUli-_o2CGGafPC_QjBSKoW4ah_N4oKi-yMgZZRwmrlXS88i0XmDMh8bC_nh8w="
  enable_branch_auto_build = true
  enable_auto_branch_creation   = true
  enable_branch_auto_deletion   = false
  auto_branch_creation_patterns = [var.env]
  platform = "WEB_COMPUTE"
  # auto_branch_creation_config {
  #   enable_auto_build           = true
  #   enable_pull_request_preview = false
  #   enable_performance_mode     = false
  #   framework                   = "Next.js - SSR"
  # }

  build_spec = <<-EOT
    version: 0.1
    frontend:
      phases:
        preBuild:
          commands:
            - npm i
        build:
          commands:
            - npm run build
      artifacts:
        baseDirectory: .next
        files:
          - '**/*'
      cache:
        paths:
          - node_modules/**/*
  EOT

  custom_rule {
    source = "<*>"
    status = "200"
    target = "<*>"
    condition = "<IN>"
  }

   custom_rule {
    source = "<*>"
    status = "200"
    target = "<*>"
    condition = "<US>"
  }

  custom_rule {
    source = "/forgotPassword"
    status = "200"
    target = "/forgotPassword"
  }

  custom_rule {
    source = "<*>"
    status = "302"
    target = "/forgotPassword"
  }

  environment_variables = {
    NEXT_PUBLIC_CLIENT_ID = var.cognito-user-pool-client-id
    NEXT_PUBLIC_USER_POOL_ID = var.cognito-user-pool-id
    NEXT_PUBLIC_JS_API_KEY   = "https://6635097dc7bd.edge.captcha-sdk.awswaf.com/6635097dc7bd/jsapi.js"
    NEXT_PUBLIC_CAPTCHA_API_KEY = "Iml2+YTR6AGaI3AP77zNe5waepBypbFSlHsi4oieU5pIwYExSMbNsPvWHae9YB1GEnErcwNXF1IDi56DvrL8wYasTcWVJYSEIJ8I/RErb3qeMRlGWcXAD57z9Bc37ojZET/vljGntKi+PYnIQD0GaWfEuSKKNWBMORbOVA28Bte3RL/zQtkcKpE699GHwdYOaCXo18Wmmx6tyXj3AO6f8x1QThUTspe+0ugQrIIxJb/PCgCTd3nfokJdmK7SrMxvbPx+3SWT+BK/i4c5X50DgJPfmDdq+lDu7uQdWLMrJlieB4gCDex5UtrI3382Uw1SiXxsJU6mkQzFbnriHsGMOs68Q/Kts4KKO+IFpIAkKZFZ0JJFw8yr62Q6q8+lPO2MUcTmps1MWB4osN8fNZYY019M90x2Y5efW+lXcf0WcNdb0AYiga9MO0JNmGhX3wHhCvHPvfzWJjMh7K8GwttP8eGkRzNMpPXvDgF+RWAOCQfcYNMOOFEHk8b8adzm8scWXR8D6ML7toEBJkZvPvmQNt46L5kmKzR9puptA8VsQocSgwspOsmoeXhrkOfolMa7a+XigNSV8Abxd+52bOyLFfHxKaLpsiHcEuUGG9BDEY0iy5T8rrTnYp5epozqLUgSIH4H8dEMMOxxzZlVolTlChfIcVrGucc8ITesX2SFoOM=_0_1"
  }

  

  tags = var.tags
}

resource "aws_amplify_branch" "amplify_branch_web" {
  app_id            = aws_amplify_app.web-app.id
  branch_name       = var.env
  enable_auto_build = false
  tags              = var.tags

}


##################################################################################################################################

#scheduler app resources
resource "aws_amplify_app" "scheduler-app" {
  name       = "pw-amplify-${var.env}-scheduler-app"
  repository = "https://bitbucket.org/prioritywaste/portal-frontend-scheduler"
  oauth_token = "ZLVrFYZJxGfgoQaNZYmnePXbyjSDPrUli-_o2CGGafPC_QjBSKoW4ah_N4oKi-yMgZZRwmrlXS88i0XmDMh8bC_nh8w="
  enable_branch_auto_build = false
  enable_auto_branch_creation   = false
  enable_branch_auto_deletion   = false
  auto_branch_creation_patterns = [var.env]
  platform = "WEB_COMPUTE"
  
  # auto_branch_creation_config {
  #   enable_auto_build           = true
  #   enable_pull_request_preview = false
  #   enable_performance_mode     = false
  #   framework                   = "Next.js - SSR"
  # }

  build_spec = <<-EOT
    version: 0.1
    frontend:
      phases:
        preBuild:
          commands:
            - npm i
        build:
          commands:
            - npm run build
      artifacts:
        baseDirectory: .next
        files:
          - '**/*'
      cache:
        paths:
          - node_modules/**/*
  EOT

  custom_rule {
    source = "<*>"
    status = "200"
    target = "<*>"
    condition = "<IN>"
  }

   custom_rule {
    source = "<*>"
    status = "200"
    target = "<*>"
    condition = "<US>"
  }

  custom_rule {
    source = "/forgotPassword"
    status = "200"
    target = "/forgotPassword"
  }

  custom_rule {
    source = "<*>"
    status = "302"
    target = "/forgotPassword"
  }

  environment_variables = {
    NEXT_PUBLIC_CLIENT_ID = var.cognito-user-pool-client-id
    NEXT_PUBLIC_USER_POOL_ID = var.cognito-user-pool-id
  }

  tags = var.tags
}

resource "aws_amplify_branch" "amplify_branch_scheduler" {
  app_id            = aws_amplify_app.scheduler-app.id
  branch_name       = var.env
  enable_auto_build = false
  tags              = var.tags

}

###########################################################################################################


##################################################################################################################################

#scheduler app resources
resource "aws_amplify_app" "fleet-app" {
  name       = "pw-amplify-${var.env}-fleet-app"
  repository = "https://bitbucket.org/prioritywaste/fm-frontend"
  oauth_token = "7TFILE0iS_6ND2veBUcWNHP4BcAhd25VT3K1bqFODMY_wKn5T14gkElnlSk_uPlhGK4tc-oQb7lcYt8jxQFXqHi0uDw="
  enable_branch_auto_build = false
  enable_auto_branch_creation   = false
  enable_branch_auto_deletion   = false
  auto_branch_creation_patterns = [var.env]
  platform = "WEB_COMPUTE"
  
  # auto_branch_creation_config {
  #   enable_auto_build           = true
  #   enable_pull_request_preview = false
  #   enable_performance_mode     = false
  #   framework                   = "Next.js - SSR"
  # }

  build_spec = <<-EOT
    version: 0.1
    frontend:
      phases:
        preBuild:
          commands:
            - npm i
        build:
          commands:
            - npm run build
      artifacts:
        baseDirectory: .next
        files:
          - '**/*'
      cache:
        paths:
          - node_modules/**/*
  EOT

  custom_rule {
    source = "<*>"
    status = "200"
    target = "<*>"
    condition = "<IN>"
  }

   custom_rule {
    source = "<*>"
    status = "200"
    target = "<*>"
    condition = "<US>"
  }

  custom_rule {
    source = "/forgotPassword"
    status = "200"
    target = "/forgotPassword"
  }

  custom_rule {
    source = "<*>"
    status = "302"
    target = "/forgotPassword"
  }

  environment_variables = {
    NEXT_PUBLIC_CLIENT_ID = var.cognito-user-pool-client-id
    NEXT_PUBLIC_USER_POOL_ID = var.cognito-user-pool-id
  }

  tags = var.tags
}

resource "aws_amplify_branch" "amplify_branch_fleet" {
  app_id            = aws_amplify_app.fleet-app.id
  branch_name       = var.env
  enable_auto_build = false
  tags              = var.tags

}
