# seki-lambda

Lambda authorizer for AWS API Gateway written in Ruby.

## How It Works

- Configure the API Gateway to use this Lambda function as the authorizer.
- Populate the database as below.

## Database Structure (DynamoDB)

- `token` is the string provide as:
  - query string `?token=`
  - HTTP header `Authorization: `
- `path` is a combination of API Gateway ID and route (prefixed by '/')
- `methods` if specified, dictates what is allowed; user lowercase
- `valid` unless true will denied
- `valid_from` timestamp, if specified, will be allowed thereafter
- `valid_until` timestamp, if specified, will be allowed until then
- `context` will be passed as is

```javascript
{
  "token": "abcd1234efgh5678",    // primary key
  "path": "<API_GW_ID><ROUTE>",  // sort key
  "desc": "Admin to internal app",
  "methods": ["get", "post"],
  "valid": true,
  "valid_from": 1609459200,
  "valid_until": 1612137600,
  "context": {
    "id": "123456",
    "name": "User A",
    "isAdmin": true
  }
}
```
