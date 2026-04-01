import { LambdaClient, UpdateFunctionConfigurationCommand } from "@aws-sdk/client-lambda";

const client = new LambdaClient();

const user_pool_id = process.env.USER_POOL_ID;
const function_name = process.env.FUNCTION_NAME;

export const handler = async (event, context, callback) => {
  const input = {
    FunctionName: function_name,
    Environment: {
      Variables: {
        "USER_POOL_ID": user_pool_id,
      }
    }
  };
  const command = new UpdateFunctionConfigurationCommand(input);
  await client.send(command)
};