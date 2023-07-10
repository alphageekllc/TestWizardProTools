import common_imports as ci
import configparser
import sys
import time
import json
import sfrest

def process(file_path, test_env='test001'):
    """
    Uploads CSV test file from github into an org

    Args:
        test_file_url (string): Test file url.
        test_env (string): Test environment name.
    """
    connection = sfrest.connect_to_org(test_env)
    instance_url = connection['instance_url']
    access_token = connection['access_token']

    ci.print_json(data=instance_url)
    ci.print_json(data=access_token)

    # upload file into Salesforce org
    response = (sfrest.upload_local_test_file(file_path, access_token, instance_url)).json()
    print(response['id'])
        
    # load test file into TestWizardPro by ContentVersion Id using anonymous apex
    response = sfrest.execute_apex(f"TestCreateHandler.createTestFromContentVersionId('{response['id']}');", access_token, instance_url).json()
    ci.print_json(data=response)
    if(response['success'] == True):
        print(ci.colored(f"Successfully uploaded and processed test file '{file_path}'.", "green"))
    else:
        print(ci.colored(f"Failed to upload and process test file '{file_path}'.", "red"))


    








