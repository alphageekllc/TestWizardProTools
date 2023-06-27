# Ruby controller 
TestWizardPro controller written in ruby

## Options menu

--------------------------
 TestWizardPro Test Tools 
--------------------------
1. Execute Test By Name
2. Execute Tests by Tag(s)
3. Upload Local Test file to Org
4. Upload Github Test file to Org
5. Exit
Please select an option:

## Usage examples
### Executing tests by test name
ruby twp_test_tools.rb 1 'Example - Assert Field Value All'
### Executing tests by test tags
ruby twp_test_tools.rb 2 'EXAMPLE'
### Uploading local test file to Org
ruby twp_test_tools.rb 3 'C:\Github\testwizardpro_example_tests\csv_tests\Example - Assert Field Value All.csv'
### Uploading Github test file to Org
ruby twp_test_tools.rb 4 'https://raw.githubusercontent.com/alphageekllc/testwizardpro_example_tests/main/csv_tests/Example%20-%20Assert%20Field%20Value%20All.csv'

# .env
Create a local .env file in root directory 

## Add the following variables to .env file:
SALESFORCE_USERNAME=<user name>
SALESFORCE_CLIENT_ID=<client id>
SECRET_KEY_LOCATION=<path to server.key file>

# Install
Clone repo locally
Run 'bundle install' command
Run 'ruby twp_test_tools.rb command'