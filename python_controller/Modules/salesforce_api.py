import jwt
import requests
import time

# Salesforce API credentials
client_id = 'YOUR_CLIENT_ID'
private_key_path = 'PATH_TO_PRIVATE_KEY'
username = 'YOUR_USERNAME'
security_token = 'YOUR_SECURITY_TOKEN'

# Salesforce API endpoints
login_url = 'https://login.salesforce.com/services/oauth2/token'
base_url = 'https://yourinstance.salesforce.com/services/data/vXX.X/'

# Generate JWT token
private_key = open(private_key_path, 'r').read()
jwt_payload = {
    'sub': username,
    'aud': login_url,
    'exp': int(time.time()) + 300
}
jwt_token = jwt.encode(jwt_payload, private_key, algorithm='RS256')

# Get access token
data = {
    'grant_type': 'urn:ietf:params:oauth:grant-type:jwt-bearer',
    'assertion': jwt_token
}
response = requests.post(login_url, data=data)
access_token = response.json()['access_token']
instance_url = response.json()['instance_url']

# Make API request
headers = {
    'Authorization': 'Bearer ' + access_token,
    'Content-Type': 'application/json'
}
api_url = instance_url + 'some_api_endpoint'
response = requests.get(api_url, headers=headers)

# Process API response
if response.status_code == 200:
    api_data = response.json()
    # Process the returned data as needed
    print(api_data)
else:
    print('API request failed with status code:', response.status_code)
    
    
    
# # Make API request
# headers = {
#     'Authorization': 'Bearer ' + access_token,
#     'Content-Type': 'application/json'
# }
# api_url = instance_url + 'some_api_endpoint'
# response = requests.get(api_url, headers=headers)

# # Process API response
# if response.status_code == 200:
#     api_data = response.json()
#     # Process the returned data as needed
#     print(api_data)
# else:
#     print('API request failed with status code:', response.status_code)    