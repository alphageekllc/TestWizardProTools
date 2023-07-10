import common_imports as ci
import configparser
import sys
import time
import json
import sfrest

def process(test_tags, test_env='test001', timeout=600):
    """
    Executes test by tags, waits for response within timeout and displays results

    Args:
        test_tags (string): Test tags.
        test_env (string): Test environment name as defined in .env where connection is made at tests are ran.
        timeout (int): Timeout within which test is expected to finish. Default value = 60s.
    """
    connection = connect_to_org(test_env)
    instance_url = connection['instance_url']
    access_token = connection['access_token']

    ci.print_json(data=instance_url)
    ci.print_json(data=access_token)

    json_response = http_execute_test_by_tags(test_tags, access_token, instance_url)
    ci.print_json(data=json_response)
    test_id = json_response['testId']

    # send requests with timeout
    start_time = time.time()
    while True:
        json_response   = http_get_test_suite_status(test_id, access_token, instance_url)
        elapsed_time    = time.time() - start_time
        print(ci.colored(f"Executing Test by Tags '{test_tags}', Status: {json_response['status']} - {elapsed_time} s...", "blue"))

        if json_response['status'] != 'Running':
            break
        if elapsed_time >= timeout:
            print("Request timed out!")
            break
        time.sleep(3) 
        
    # Display test events
    print(json_response['tests'])    
    # Display test results
    if json_response['status'] == 'TEST RUN PASSED':
        for item in json.loads(json_response['tests']):
            name = item["Name"]
            status = item["TWP__Status__c"]
            if item["TWP__Status__c"] == 'TEST PASSED':
                print(ci.colored(f"Test Name: '{name}' - Status: {status}", "green"))
            else:
                print(ci.colored(f"Test Name: '{name}' - Status: {status}", "red"))

        print(ci.colored(f"Test Tags: '{test_tags}' - {json_response['status']}", "green"))
    else:
        ci.print_json(data=json_response)     
        print(ci.colored(f"Test Tags: '{test_tags}' - {json_response['status']}", "red"))

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

def http_execute_test_by_tags(test_tags, access_token, instance_url):
    headers     = {
        'Authorization': 'Bearer ' + access_token,
        'Content-Type': 'application/json'
    }
    payload     = { 'tags' : test_tags }
    endpoint    = '/services/apexrest/TWP/startTestByTags'
    api_url     = instance_url + endpoint
    response    = ci.requests.post(api_url, json=payload, headers=headers)
    
    response_data = {}
    if response.status_code == 200:
        response_data = json.loads(response.json())
        if response_data['success'] == False:
            print(ci.colored(response_data['exception'], "red")) 
            sys.exit(1)
    else:
        response_data = response.json()
        ci.print_json(data=response_data)
        print(ci.colored(('API request failed with status code: ', response.status_code), "red"))        
        sys.exit(1)

    return response_data

def http_get_test_suite_status(test_id, access_token, instance_url):
    headers     = {
        'Authorization': 'Bearer ' + access_token,
        'Content-Type': 'application/json'
    }
    payload     = { 'testId' : test_id }
    endpoint    = '/services/apexrest/TWP/getTestSuiteStatus'
    api_url     = instance_url + endpoint
    response    = ci.requests.post(api_url, json=payload, headers=headers)
    
    response_data = {}
    if response.status_code == 200:
        response_data = json.loads(response.json())
        if response_data['success'] == False:
            print(ci.colored(response_data['exception'], "red")) 
            sys.exit(1)
    else:
        response_data = response.json()
        ci.print_json(data=response_data)
        print(ci.colored(('API request failed with status code: ', response.status_code), "red"))        
        sys.exit(1)

    return response_data

    
    
    
    
    








