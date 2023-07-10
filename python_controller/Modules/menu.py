import common_imports as ci
import execute_test_by_name
import execute_test_by_tags
import upload_local_test_file
import upload_github_test_file

def option1(data):
    if data == None:
        print(ci.colored("--------------------------------", "yellow"))
        data = input(ci.colored("Please enter Test Name: ", 'blue'))
    # create_mlt_projects.process(ci.constants.NUMBER_OF_ROWS_TO_PROCESS)
    print("Executing test by name with data: '" + data + "'...")
    execute_test_by_name.process(data)

def option2(data):
    if data == None:
        print(ci.colored("--------------------------------", "yellow"))
        data = input(ci.colored("Please enter Test Tags: ", 'blue'))
    print("Executing test by tags with data: '" + data + "'...")
    execute_test_by_tags.process(data)
    
def option3(data):
    if data == None:
        print(ci.colored("--------------------------------", "yellow"))
        data = input(ci.colored("Please enter local test file path for upload: ", 'blue'))
    print(f"Uploading local test file '{data}' to org ...")
    upload_local_test_file.process(data)
    
def option4(data):
    if data == None:
        print(ci.colored("--------------------------------", "yellow"))
        data = input(ci.colored("Please enter github test file url for upload: ", 'blue'))
    print(f"Uploading github test file '{data}' to org ...")
    upload_github_test_file.process(data)
    
def displayMenu():
        print(ci.colored("\n--------------------------------", "yellow"))
        print(ci.colored("--- TestWizardPro Test Tools ---", "yellow"))
        print(ci.colored("--------------------------------", "yellow"))
        print(ci.colored("1. Execute Test By Name", "blue"))
        print(ci.colored("2. Execute Tests by Tag(s)", "blue"))
        print(ci.colored("3. Upload Local Test file to Org", "blue"))
        print(ci.colored("4. Upload Github Test file to Org", "blue"))
        print("5. Exit")
        print(ci.colored("--------------------------------", "yellow"))
        
def main_menu(choice, data):
    # used for debug, remove
    print("Parameter option:", choice)
    print("Parameter   data:", data)
    
    displayMenu()

    if choice == None:
        try:
            choice = int(input(ci.colored("Please select an option: ", 'yellow')))
        except ValueError:
            print(ci.colored("Invalid input. Please enter a number.", "red"))
    else:
        choice = int(choice)

    if choice == 1:
        option1(data)
    elif choice == 2:
        option2(data)
    elif choice == 3:
        option3(data)
    elif choice == 4:
        option4(data)           
    elif choice == 5:
        print(ci.colored("Exiting...", "green"))
    else:
        print(ci.colored("Invalid choice. Please choose valid option from the menu.", "red"))