require_relative '../common/sfrest.rb'
require 'awesome_print'
require 'colorize'
require 'base64'
require 'date'
require 'openssl'
require 'uri'
require 'net/http'
require 'json'
require 'parallel'
require 'time'

def upload_local_test_file(test_file_path)
  username = ENV['SALESFORCE_USERNAME']
  client_id = ENV['SALESFORCE_CLIENT_ID']

  SFREST.get_token_jwt username, client_id

  # upload file into Salesforce org
  response = SFREST.upload_local_test_file test_file_path
  ap response

  # load test file into TestWizardPro by ContentVersion Id
  response = SFREST.execute_apex "TestCreateHandler.createTestFromContentVersionId('#{response['id']}');"
  puts 'TestCreateHandler Apex Execution Status:'.blue
  ap response
end
