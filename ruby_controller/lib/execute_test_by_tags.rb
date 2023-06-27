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

def execute_test_by_tags(tags)
  username = ENV['SALESFORCE_USERNAME']
  client_id = ENV['SALESFORCE_CLIENT_ID']

  SFREST.get_token_jwt username, client_id

  response = SFREST.startTestByTags tags
  response_data = JSON.parse(JSON.parse(response.body))
  test_id = response_data['testId']
  puts "Response Status code:  #{response.code} Test ID: #{test_id}".yellow

  if test_id.nil?
    raise "test_id is null, verify test tags '#{tags}' exist."
  end

  timeout = 1200
  start_time = Time.now
  response_data = nil
  while (Time.now - start_time).to_i < timeout

    response = SFREST.getTestSuiteStatus(test_id)
    response_data = JSON.parse(JSON.parse(response.body))
    puts "Test Status: #{response_data['status']} - #{(Time.now - start_time)}"

    break if response_data['status'] != 'Running'

    sleep 3
  end

  puts response_data['tests']

  JSON.parse(response_data['tests']).each do |test|
    if test['TWP__Status__c'] == 'TEST PASSED'
      puts "Test: '#{test['Name']}'  Status: #{test['TWP__Status__c']}".green
    else
      puts "Test: '#{test['Name']}'  Status: #{test['TWP__Status__c']}".red
    end
  end

  if response_data['status'] == 'TEST RUN PASSED'
    puts "Test Run Status: #{response_data['status']}".green
  else
    puts "Test Run Status: #{response_data['status']}".red
  end

end
