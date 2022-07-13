# Backend
Dev domain: `api.dev.minter.guru`

Error messages from all endpoints will be in following format:
```json
{
  "code": 500,
  "message": "error short message",
  "detail": "some details on error"
}
```
#### Common errors
##### Validation failed
```json
{
  "code": 400,
  "message": "validation failed",
  "detail": "details"
}
```
##### Internal error
```json
{
  "code": 500,
  "message": "internal error",
  "detail": ""
}
```
##### Error in external call
```json
{
  "code": 503,
  "message": "service unavailable",
  "detail": ""
}
```
## Auth
### Get auth message to sign
`POST /auth/message`

#### Body
```json
{
  "address": "address from wallet"
}
```
#### Response
```json
{
  "message": "message to sign"
}
```
### Auth with signature
`POST /auth`

#### Body
To build signature one must get the message from `/auth/message` request and sign following message:
`"\x19Ethereum Signed Message:\n" + data.length + data`. Usually, web3 providers are wrapping message with above format themselves.

```json
{
  "address": "address from wallet",
  "signature": "signature"
}
```
#### Response
```json
{
  "user": {
    "address": "user address",
    "id": 1
  },
  "accessToken": {
    "token": "access token",
    "expiresAt": 0  // unix-timestamp in milliseconds
  }
}
```
#### Errors
##### Auth message not found for address
```json
{
  "code": 400,
  "message": "auth message not found",
  "detail": ""
}
```
##### Auth message expired
```json
{
  "code": 400,
  "message": "auth message expired",
  "detail": ""
}
```
##### Wrong signature
```json
{
  "code": 400,
  "message": "wrong signature",
  "detail": ""
}
```
## Faucet
### Request faucet
`POST /faucet`

#### Auth
`Authorization header` with `Bearer` Token
#### Body
Empty
#### Response
```json
{
  "id": "hash of faucet transaction"
}
```
#### Errors
##### Balance for user isn't equal to 0
```json
{
  "code": 400,
  "message": "balance is not equal to 0",
  "detail": ""
}
```
##### Already got faucet
```json
{
  "code": 400,
  "message": "already got faucet",
  "detail": ""
}
```
### Request faucet by address
`POST /faucet/by_address`

Public version of request with required authorization
#### Body
```json
{
  "address": "user address"
}
```
## Twitter rewards
### Get rewards list
`POST /twitter/get_records`

#### Auth
`Authorization header` with `Bearer` Token
#### Body
Empty
#### Response
```json
[
  {
    "id": 1,
    "createdAt": 0 // unix-timestamp in milliseconds
  },
  {
    "id": 2,
    "createdAt": 0, // unix-timestamp in milliseconds
    "transaction": {
      "id": "mint transaction hash"
    }
  }
]
```
### Apply for twitter reward
`POST /twitter`

#### Auth
`Authorization header` with `Bearer` Token
#### Body
Empty
#### Response
```json
{
  "id": 1,
  "createdAt": 0 // unix-timestamp in milliseconds
}
```
#### Errors
##### Twitter event closed
```json
{
  "code": 400,
  "message": "twitter event closed",
  "detail": ""
}
```
##### Daily limit reached
```json
{
  "code": 400,
  "message": "twitter limit reached",
  "detail": ""
}
```
### Apply for twitter reward by address
`POST /twitter/by_address`

Public version of request with required authorization
#### Body
```json
{
  "address": "user address"
}
```
### Get rewards list
`POST /twitter/get_records/by_address`

Public version of request with required authorization
#### Body
```json
{
  "address": "user address"
}
```