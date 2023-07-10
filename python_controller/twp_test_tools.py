import sys
sys.path.append(r'C:\Github\TestWizardProTools\python_controller\Modules')

import menu

if __name__ == "__main__":
    arg1 = sys.argv[1] if len(sys.argv) > 1 else None
    arg2 = sys.argv[2] if len(sys.argv) > 2 else None
    
    menu.main_menu(arg1, arg2)