import re
import os 
# Read the file content
with open('D:\Documents\Timor Leste Project\sql_scripts\ddl.txt', 'r', encoding='utf-8') as file:
    content = file.read()

# Extract all CREATE TABLE statements using regex
create_table_statements = re.findall(r'(CREATE\s+TABLE\s+"?(\w+)"?\."([\w\d_]+)"[\s\S]*?;)', content)

output_dir = 'D:\Documents\Timor Leste Project\sql_scripts\oracle\ddl'

# Ensure the output directory exists
os.makedirs(output_dir, exist_ok=True)

# Loop through each CREATE TABLE statement and save to a file
for full_statement, schema, table_name in create_table_statements:
    # Create a valid filename from the table name, which includes schema and table name (e.g., ACCOUNT_RIGHT_DEFAULT_20181024)
    file_name = f"{table_name}.sql"
    file_path = os.path.join(output_dir, file_name)
    
    # Save the CREATE TABLE statement to the file
    with open(file_path, 'w', encoding='utf-8') as output_file:
        output_file.write(full_statement + '\n\n')

    print(f"Saved {table_name} table creation statement to {file_path}")