# Ruby Controller 
TestWizardPro test execution and management controller written in ruby.

## Options menu
```ruby
--------------------------
 TestWizardPro Test Tools 
--------------------------
1. Execute Test By Name
2. Execute Tests by Tag(s)
3. Upload Local Test file to Org
4. Upload Github Test file to Org
5. Exit
Please select an option:
```

## Usage examples
### Executing tests by test name:
```bash
ruby twp_test_tools.rb 1 'Example - Assert Field Value All'
```
### Executing tests by test tags:
```bash
ruby twp_test_tools.rb 2 'EXAMPLE'
```
### Uploading local test file to Org:
```bash
ruby twp_test_tools.rb 3 'C:\Github\testwizardpro_example_tests\csv_tests\Example - Assert Field Value All.csv'
```
### Uploading Github test file to Org:
```bash
ruby twp_test_tools.rb 4 'https://raw.githubusercontent.com/alphageekllc/testwizardpro_example_tests/main/csv_tests/Example%20-%20Assert%20Field%20Value%20All.csv'
```

# .env
Create a local .env file in root directory 

## Add the following variables to your .env file:
```bash
SALESFORCE_USERNAME=<user name>
SALESFORCE_CLIENT_ID=<client id>
SECRET_KEY_LOCATION=<path to server.key file>
```
# Install
Prerequisites
- Ruby [3.2.2](https://www.ruby-lang.org/en/documentation/installation/)

Clone repo locally
```bash
gh repo clone alphageekllc/TestWizardProTools
```
Install ruby dependencies 
```bash
bundle install
```
Execute
```bash
ruby twp_test_tools.rb
```
# SF Org Requirements
## Connected App
- Connected App (https://help.salesforce.com/s/articleView?id=sf.connected_app_overview.htm&type=5)

Remote control is performed via a Connected App. Connected App CLIENT_ID, server.crt digital signature, and Org username are used to establish a connection.

