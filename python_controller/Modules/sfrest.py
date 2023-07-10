import common_imports as ci
import configparser
import sys
import time
import json
import os
import base64
import urllib.parse

def connect_to_org(environment):
    # Environment data 
    config = configparser.ConfigParser()
    config.read('.env')
    client_id           = config.get(environment, 'SALESFORCE_CLIENT_ID')
    username            = config.get(environment, 'SALESFORCE_USERNAME')
    private_key_path    = config.get(environment, 'SECRET_KEY_LOCATION')
    login_url           = config.get(environment, 'SALESFORCE_LOGIN_URL')

    # Generate JWT token
    private_key = open(private_key_path, 'r').read()
    jwt_payload = {
        'iss': client_id,
        'sub': username,
        'aud': login_url,
        'exp': int(ci.time.time()) + 300
    }
    jwt_token = ci.jwt.encode(jwt_payload, private_key, algorithm='RS256')
    
    # Get access token
    data = {
        'grant_type': 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        'assertion': jwt_token
    }
    response = ci.requests.post(login_url, data=data)
    if 'error' in response.json():
        ci.print_json(data=response.json())
        print(ci.colored("Response contains an error. ", "red"))
        sys.exit(1)
        
    access_token = response.json()['access_token']
    instance_url = response.json()['instance_url']
    
    return {'access_token':access_token, 'instance_url': instance_url}

def upload_local_test_file(file_path, access_token, instance_url):    
    file_name = os.path.basename(file_path)   
    with open(file_path, 'rb') as file:
        file_data = file.read()
        
    # IMPORTANT - encoding has to be base64_string
    base64_b = base64.b64encode(file_data)
    base64_string = base64_b.decode('utf-8')
    
    payload = {
        'Title': file_name,
        'PathOnClient': file_path,
        'VersionData': base64_string
    }
    headers = {
        'Authorization': f'Bearer {access_token}',
        'Content-Type': 'application/json',
        'Accept' : 'application/json'
    }
    upload_endpoint = f"{instance_url}/services/data/v58.0/sobjects/ContentVersion"
    response = ci.requests.post(upload_endpoint, headers=headers, json=payload)
    print(f'upload_local_test_file response code: {response.status_code}')
    return response
    
def upload_github_test_file(file_url, access_token, instance_url): 
    response = ci.requests.get(file_url)
    file_data = 'NA'
    if response.status_code == 200:
        file_data = response.content
    else:
        print(f"Failed to download file '{file_url}'. Status code: {response.status_code}")
        sys.exit(1)
      
    parsed_url  = urllib.parse.urlparse(file_url)      
    file_name   = os.path.basename(parsed_url.path)
            
    # IMPORTANT - encoding has to be base64_string
    base64_b = base64.b64encode(file_data)
    base64_string = base64_b.decode('utf-8')
    
    payload = {
        'Title': file_name,
        'PathOnClient': file_name,
        'VersionData': base64_string
    }
    headers = {
        'Authorization': f'Bearer {access_token}',
        'Content-Type': 'application/json',
        'Accept' : 'application/json'
    }
    upload_endpoint = f"{instance_url}/services/data/v58.0/sobjects/ContentVersion"
    response = ci.requests.post(upload_endpoint, headers=headers, json=payload)
    print(f'upload_github_test_file response code: {response.status_code}')
    return response    
    
def execute_apex(apex_body, access_token, instance_url):
    escaped_data = urllib.parse.quote(apex_body)
    endpoint = f"{instance_url}/services/data/v58.0/tooling/executeAnonymous/?anonymousBody={escaped_data}"
    headers = {
        'Authorization': f'Bearer {access_token}',
        'Content-Type': 'application/json',
        'Accept' : 'application/json'
    }   
    response = ci.requests.get(endpoint, headers=headers)
    print(f'execute_apex response code: {response.status_code}')
    return response


    
    