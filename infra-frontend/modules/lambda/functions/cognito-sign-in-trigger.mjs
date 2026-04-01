import { CognitoIdentityProviderClient, AdminGetUserCommand } from "@aws-sdk/client-cognito-identity-provider";
import axios from 'axios';

const client = new CognitoIdentityProviderClient();

export const handler = async (event, context, callback) => {

  console.log("received event: ", event);
  
  const userpoolId = process.env.USER_POOL_ID;
  const emailId = event.request.userAttributes.email;

  let response;
  try {
    const input = {
      UserPoolId: userpoolId,
      Username: emailId,
    };
    const command = new AdminGetUserCommand(input);
    response = await client.send(command);
  } catch (error) {
    console.log("Error fetching user attributes: ", error);
    callback(error, event);
  }
  
  let customerId;
  for (const attribute of response.UserAttributes) {
    if (attribute.Name == "custom:customer_id") {
      customerId = attribute.Value;
    }
    else {
      customerId = '52580';
    }
  }

  const url = `https://customerprtlbe.dev.prioritywaste.com/customer/isCustomerActive`;
  const body = {
    customerId: customerId
  };

  async function fetchData(url, body) {
    try {
      const response = await axios.get(url, {data:body});
      
      if (response.data.data) {
        callback(null, event);
      }
      else {
        const error = response.data.message;
        callback(error, event);
      }
    } catch (error) {
      console.error('Error fetching data:', error);
    }
  }
  
  await fetchData(url, body);
};