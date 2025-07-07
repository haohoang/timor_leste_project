from datetime import timedelta, datetime


PARTITION_DATE = (datetime.today() - timedelta(days=1)).strftime("%Y%m%d")
today = datetime.strptime(PARTITION_DATE, "%Y%m%d") + timedelta(days = 1)
tomorrow = today + timedelta(days = 1)
F_DATE_OF_MONTH_N_1 = ((today).replace(day=1) - timedelta(days=1)).replace(day=1).strftime("%Y%m%d")
L_DATE_OF_MONTH_N_1 = ((today).replace(day=1) - timedelta(days=1)).strftime("%Y%m%d")

SEND_DATE = today.strftime("%d")
PACKAGE_USED = "F013_PRE_VAS_MONTH"
DATA_PACKAGE = "/work_zone/fintech/users/tiennv399/timor_package.csv"
POTENTIAL_LEAD = "/work_zone/fintech/users/tiennv399/potential_lead_data_test"

print(f"Partition Date: {PARTITION_DATE}")
print(f"Today: {today.strftime('%Y-%m-%d')}")
print(f"Tomorrow: {tomorrow.strftime('%Y-%m-%d')}") 
print(f"First Date of Month N-1: {F_DATE_OF_MONTH_N_1}")
print(f"Last Date of Month N-1: {L_DATE_OF_MONTH_N_1}")

import json

def export_to_python(json_file, output_py_file):
    # Load the exported JSON file
    with open(json_file, 'r') as f:
        notebook = json.load(f)

    # Open the output Python file
    with open(output_py_file, 'w') as py_file:
        for paragraph in notebook['paragraphs']:
            # Check if it's a Python code cell
            if paragraph['config']['language'] == 'python':
                py_file.write(paragraph['text'] + "\n\n")

# Usage example
export_to_python('D:\Documents\Timor Leste Project\src\haoht27_potential_lead_data.json', 'notebook.py')
