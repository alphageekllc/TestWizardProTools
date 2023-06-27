require 'colorize'
require 'awesome_print'
require 'json'
require 'dotenv'
require_relative 'lib/execute_test_by_name'
require_relative 'lib/execute_test_by_tags'
require_relative 'lib/upload_local_test_file'
require_relative 'lib/upload_github_test_file'

Dotenv.load

# parse out input parameters
menu_item                   = ARGV[0].nil? ? nil : ARGV[0].to_i
menu_data                   = ARGV[1].nil? ? nil : ARGV[1]

puts '--------------------------'.blue
puts ' TestWizardPro Test Tools '.blue
puts '--------------------------'.blue
puts '1. Execute Test By Name'.yellow
puts '2. Execute Tests by Tag(s)'.yellow
puts '3. Upload Local Test file to Org'.yellow
puts '4. Upload Github Test file to Org'.yellow
puts '5. Exit'.yellow
puts 'Please select an option:'.white

def handle_choice(choice, data)
  case choice
  when 1
    if data.nil?
      puts 'Enter Test Name:'.yellow
      data = $stdin.gets.chomp
    end
    puts "Executing Test by Name: '#{data}'...".blue

    # stability testing debug loop, default value = 1
    cnt = 0
    while cnt < 1
      execute_test_by_name(data)
      cnt += 1
    end

  when 2
    if data.nil?
      puts 'Enter Test Tags:'.yellow
      data = $stdin.gets.chomp
    end
    puts "Executing Tests by Tags: '#{data}'...".blue

    # stability testing debug loop, default value = 1
    cnt = 0
    while cnt < 1
      execute_test_by_tags(data)
      cnt += 1
    end

  when 3
    if data.nil?
      puts 'Enter local test file path'.yellow
      data = $stdin.gets.chomp
    end
    puts "Uploading local test file '#{data}' to org ...".blue
    upload_local_test_file(data)

  when 4
    if data.nil?
      puts 'Enter Github test file path'.yellow
      data = $stdin.gets.chomp
    end
    puts "Uploading Github test file '#{data}' to org ...".blue
    upload_github_test_file(data)

  when 5
    puts 'Exiting...'
    exit
  else
    puts 'Invalid choice. Please try again.'
  end
end

if menu_item.nil?
  menu_item = gets.chomp.to_i
end

handle_choice(menu_item, menu_data)

# api_key = ENV['API_KEY']
# db_host = ENV['DB_HOST']
