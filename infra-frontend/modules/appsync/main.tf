resource "aws_appsync_graphql_api" "appsync-graphql-api" {
  authentication_type = "AMAZON_COGNITO_USER_POOLS"
  name                = "pw-appsync-${var.env}-api"

  user_pool_config {
    aws_region     = var.region
    default_action = "ALLOW"
    user_pool_id   = var.cognito-user-pool-id
  }

   log_config {
   cloudwatch_logs_role_arn = aws_iam_role.appsync_logs.arn
   field_log_level         = "ALL"
 }


  schema = <<EOF
enum DIRECTION {
	UP
	DOWN
}

type PaginatedPosts @aws_cognito_user_pools {
	posts: [Post!]!
	nextToken: String
}

type Post @aws_cognito_user_pools {
	id: ID!
	author: String
	title: String
	content: String
	url: String
	ups: Int!
	downs: Int!
	version: Int!
}

type Mutation @aws_cognito_user_pools {
	addPost(
		id: ID!,
		author: String!,
		title: String!,
		content: String!,
		url: String!
	): Post!
	updatePost(
		id: ID!,
		author: String,
		title: String,
		content: String,
		url: String,
		expectedVersion: Int!
	): Post
	vote(id: ID!, direction: DIRECTION!): Post
	deletePost(id: ID!, expectedVersion: Int): Post
}

type Query @aws_cognito_user_pools {
	getPost(id: ID): Post
	allPost(limit: Int, nextToken: String): PaginatedPosts!
	allPostsByAuthor(author: String!, limit: Int, nextToken: String): PaginatedPosts!
}

type Subscription @aws_cognito_user_pools {
	addedPost: Post
		@aws_subscribe(mutations: ["addPost"])
	updatedPost(id: ID): Post
		@aws_subscribe(mutations: ["updatePost"])
}

schema {
	query: Query
	mutation: Mutation
	subscription: Subscription
}
EOF

 tags = var.tags
}


resource "aws_cloudwatch_log_group" "appsync_logs" {
 name              = "/aws/appsync/apis/${aws_appsync_graphql_api.appsync-graphql-api.name}"
 retention_in_days = 14
 tags              = var.tags
}

resource "aws_iam_role" "appsync_logs" {
 name = "appsync-logs-${var.env}-role"

 assume_role_policy = jsonencode({
   Version = "2012-10-17"
   Statement = [
     {
       Action = "sts:AssumeRole"
       Effect = "Allow"
       Principal = {
         Service = "appsync.amazonaws.com"
       }
     }
   ]
 })
}

resource "aws_iam_role_policy" "appsync_logs" {
  name = "appsync-logs-${var.env}-policy"
  role = aws_iam_role.appsync_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream", 
          "logs:PutLogEvents"
        ]
        Resource = [
          "${aws_cloudwatch_log_group.appsync_logs.arn}",
          "${aws_cloudwatch_log_group.appsync_logs.arn}:*"
        ]
      }
    ]
  })
}


resource "aws_appsync_datasource" "appsync-dynamodb-datasource" {
  api_id           = aws_appsync_graphql_api.appsync-graphql-api.id
  name             = "pw_datasource_${var.env}_location_data"
  service_role_arn = var.appsync-dynamo-access-role-arn
  type             = "AMAZON_DYNAMODB"

  dynamodb_config {
    table_name = var.dynamo-table-name
  }
}


locals {
  query = toset(["getPost", "allPost", "allPostsByAuthor"])
  mutation = toset(["addPost", "deletePost", "updatePost", "vote"])
}

resource "aws_appsync_resolver" "appsync-resolver-query" {
  for_each    = local.query
  api_id      = aws_appsync_graphql_api.appsync-graphql-api.id
  data_source = aws_appsync_datasource.appsync-dynamodb-datasource.name
  type        = "Query"
  field       = each.value
  code        = file("${path.module}/appsync_js_resolvers/queries/${each.value}.js")

  runtime {
    name            = "APPSYNC_JS"
    runtime_version = "1.0.0"
  }
}

resource "aws_appsync_resolver" "appsync-resolver-mutation" {
  for_each    = local.mutation
  api_id      = aws_appsync_graphql_api.appsync-graphql-api.id
  data_source = aws_appsync_datasource.appsync-dynamodb-datasource.name
  type        = "Mutation"
  field       = each.value
  code        = file("${path.module}/appsync_js_resolvers/mutations/${each.value}.js")

  runtime {
    name            = "APPSYNC_JS"
    runtime_version = "1.0.0"
  }
}
