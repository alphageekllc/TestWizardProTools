# Python Controller 
TestWizardPro test execution and management controller written in python.

## Options menu
```python
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
python twp_test_tools.py 1 'Example - Assert Field Value All'
```
### Executing tests by test tags:
```bash
python twp_test_tools.py 2 'EXAMPLE'
```
### Uploading local test file to Org:
```bash
python twp_test_tools.py 3 'C:\Github\testwizardpro_example_tests\csv_tests\Example - Assert Field Value All.csv'
```
### Uploading Github test file to Org:
```bash
python twp_test_tools.py 4 'https://raw.githubusercontent.com/alphageekllc/testwizardpro_example_tests/main/csv_tests/Example%20-%20Assert%20Field%20Value%20All.csv'
```

# .env
Create a local .env file in root directory 

## Add the following variables to your .env file:
```bash
[environment_name]
SALESFORCE_USERNAME=<user name>
SALESFORCE_CLIENT_ID=<client id>
SECRET_KEY_LOCATION=<path to server.key file>
SALESFORCE_LOGIN_URL=https://test.salesforce.com/services/oauth2/token
```
# Install
Install pip on windows
```bash
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python get-pip.py
```
Clone repo locally
```bash
gh repo clone alphageekllc/TestWizardProTools
```
Enter python controller
```bash
cd python_controller
```
Install dependencies
```bash
.\Scripts\activate
pip install -r requirements.txt
```