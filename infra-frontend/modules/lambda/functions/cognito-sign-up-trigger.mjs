import oauth from 'oauth-1.0a';
import crypto from 'crypto';
import axios from 'axios';

export const handler = async (event, context, callback) => {

  console.log("received event: ", event);
  
  const consumerKey = '34f1e1bb5654c81e0ab9f3ea4d4386df1ff41b043a8a54aec65a96443d4fa272';
  const consumerSecret = '7482fa10e7242d6f5660cf58f46e25d117586d1515c618329a8789a27e816c55';
  const token = '9fe32f5d129fd8defa4ed9e1d49df55ad00b49f606db97e98bd335fd2a28f41b';
  const tokenSecret = '487d5330176ba59397fea49ffcaa2f991e2051b4aafbbab433a36af76e6dee60';
  const realm = '6731274_SB1'
  
  const invoiceId = event.request.userAttributes['custom:invoice_id'];
  const customerId = event.request.userAttributes['custom:customer_id'] ;
  const emailId = event.request.userAttributes.email;
  
  const oauthInstance = oauth({
    consumer: { key: consumerKey, secret: consumerSecret },
    signature_method: 'HMAC-SHA256',
    hash_function(base_string, key) {
      return crypto.createHmac('sha256', key).update(base_string).digest('base64');
    },
  });

  const url = `https://6731274-sb1.restlets.api.netsuite.com/app/site/hosting/restlet.nl?script=816&deploy=1&id=${customerId}&invoiceId=${invoiceId}&emailId=${emailId}`;
  const requestData = {
      url: url,
      method: 'GET',
  };

  const authHeader = oauthInstance.authorize(requestData, { key: token, secret: tokenSecret });
  let authHeaderString = oauthInstance.toHeader(authHeader).Authorization;
  authHeaderString += `, realm="${realm}"`;

  async function fetchData(url, authHeader) {
    try {
      const response = await axios.get(url, {
        headers: {
          Authorization: authHeader
        },
      });
      
      if (response.data.status == "success") {
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
  
  await fetchData(url, authHeaderString);
};


// ###############################################################################################################################

// import oauth from 'oauth-1.0a';
// import crypto from 'crypto';
// import axios from 'axios';
// import { SecretsManager } from '@aws-sdk/client-secrets-manager';

// // 🔑 Helper function to retrieve secrets from AWS Secrets Manager
// async function getNetSuiteSecrets() {
//   // 🔑 Create Secrets Manager client with dynamic region
//   const client = new SecretsManager({ region: process.env.AWS_REGION });
  
//   try {
//     // 🔑 Retrieve secret using environment variable with ARN or Name
//     const response = await client.getSecretValue({
//       SecretId: process.env.NETSUITE_SECRETS_ARN
//     });

//     // 🔑 Parse the secret string
//     if (response.SecretString) {
//       return JSON.parse(response.SecretString);
//     } else {
//       throw new Error('No secret string found');
//     }
//   } catch (error) {
//     // 🔑 Enhanced error logging
//     console.error('Error retrieving NetSuite secrets:', error);
//     throw error;
//   }
// }

// export const handler = async (event, context, callback) => {
//   console.log("Received event: ", event);
  
//   try {
//     // 🔑 Retrieve secrets from AWS Secrets Manager
//     const {
//       consumer_key: consumerKey,
//       consumer_secret: consumerSecret,
//       token,
//       token_secret: tokenSecret,
//       realm
//     } = await getNetSuiteSecrets();
  
//     // Extract user attributes
//     const invoiceId = event.request.userAttributes['custom:invoice_id'];
//     const customerId = event.request.userAttributes['custom:customer_id'];
//     const emailId = event.request.userAttributes.email;
    
//     // Configure OAuth instance
//     const oauthInstance = oauth({
//       consumer: { key: consumerKey, secret: consumerSecret },
//       signature_method: 'HMAC-SHA256',
//       hash_function(base_string, key) {
//         return crypto.createHmac('sha256', key).update(base_string).digest('base64');
//       },
//     });

//     // Construct NetSuite API URL
//     const url = `https://6731274-sb1.restlets.api.netsuite.com/app/site/hosting/restlet.nl?script=816&deploy=1&id=${customerId}&invoiceId=${invoiceId}&emailId=${emailId}`;
//     const requestData = {
//       url: url,
//       method: 'GET',
//     };

//     // Generate OAuth authorization header
//     const authHeader = oauthInstance.authorize(requestData, { key: token, secret: tokenSecret });
//     let authHeaderString = oauthInstance.toHeader(authHeader).Authorization;
//     authHeaderString += `, realm="${realm}"`;

//     // Fetch data from NetSuite
//     async function fetchData(url, authHeader) {
//       try {
//         const response = await axios.get(url, {
//           headers: {
//             Authorization: authHeader
//           },
//         });
        
//         if (response.data.status === "success") {
//           callback(null, event);
//         } else {
//           const error = response.data.message;
//           callback(error, event);
//         }
//       } catch (error) {
//         console.error('Error fetching data from NetSuite:', error);
//         callback(error, event);
//       }
//     }
    
//     // Execute the fetch
//     await fetchData(url, authHeaderString);

//   } catch (error) {
//     console.error('Lambda execution error:', error);
//     callback(error, event);
//   }
// };