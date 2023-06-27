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

def execute_test_by_name(test_name)
  username = ENV['SALESFORCE_USERNAME']
  client_id = ENV['SALESFORCE_CLIENT_ID']

  SFREST.get_token_jwt username, client_id

  response = SFREST.startTestByName test_name
  response_data = JSON.parse(JSON.parse(response.body))
  test_id = response_data['testId']
  puts "Response Status code:  #{response.code} Test ID: #{test_id}".yellow

  if test_id.nil?
    raise "test_id is null, verify test name '#{test_name}' exists in org."
  end

  timeout = 999
  start_time = Time.now
  response_data = nil
  while (Time.now - start_time).to_i < timeout

    response = SFREST.getTestStatus(test_id)
    response_data = JSON.parse(JSON.parse(response.body))
    puts "Executing Tests By TagsTest Status: #{response_data['status']} - #{(Time.now - start_time)}"

    break if response_data['status'] != 'Running'

    sleep 3
  end

  puts response_data['tests']

  if response_data['status'] == 'TEST PASSED'
    puts "Test Status: #{response_data['status']}".green
  else
    puts "Test Status: #{response_data['status']}".red
  end

end
