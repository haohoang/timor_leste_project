import jaydebeapi
import jpype
import os
from dotenv import load_dotenv
import re

hive_path = "D:\Documents\Timor Leste Project\sql_scripts\hive"
oracle_path = "D:\Documents\Timor Leste Project\sql_scripts\oracle"

def get_oracle_table_schema(jdbc_url, user, password, table_name, driver_path):
    """
    Connects to Oracle DB using JDBC and retrieves the schema of the specified table.

    Args:
        jdbc_url (str): JDBC URL for Oracle connection.
        user (str): Username for Oracle DB.
        password (str): Password for Oracle DB.
        table_name (str): Table name to get schema for.
        driver_path (str): Path to the Oracle JDBC driver .jar file.

    Returns:
        list of tuples: Each tuple contains (column_name, data_type).
    """
    # Start the JVM if not already started
    if not jpype.isJVMStarted():
        jpype.startJVM(classpath=[driver_path])
    jpype.addClassPath(driver_path)

    conn = jaydebeapi.connect(
        "oracle.jdbc.driver.OracleDriver",
        jdbc_url,
        [user, password],
        jars=driver_path
    )
    curs = conn.cursor()
    query = f"""
        SELECT DISTINCT COLUMN_NAME, DATA_TYPE
        FROM ALL_TAB_COLUMNS
        WHERE TABLE_NAME = '{table_name.upper()}'
    """
    curs.execute(query)
    columns = [(row[0], row[1]) for row in curs.fetchall()]
    curs.close()
    conn.close()
    jpype.shutdownJVM() # Shutdown JVM after use
    return columns


def get_oracle_list_table_schema(jdbc_url, user, password, table_name_list, driver_path):
    """
    Connects to Oracle DB using JDBC and retrieves the schema of the specified table.

    Args:
        jdbc_url (str): JDBC URL for Oracle connection.
        user (str): Username for Oracle DB.
        password (str): Password for Oracle DB.
        table_name (str): Table name to get schema for.
        driver_path (str): Path to the Oracle JDBC driver .jar file.

    Returns:
        dict: A dictionary where the keys are table names and the values are lists of (column_name, data_type) tuples.
    """
    # Start the JVM if not already started
    if not jpype.isJVMStarted():
        jpype.startJVM(classpath=[driver_path])

    conn = jaydebeapi.connect(
        "oracle.jdbc.driver.OracleDriver",
        jdbc_url,
        [user, password],
        jars=driver_path
    )
    curs = conn.cursor()
    schema = {}
    for table_name in table_name_list:
        query = f"""
            SELECT DISTINCT COLUMN_NAME, DATA_TYPE
            FROM ALL_TAB_COLUMNS
            WHERE TABLE_NAME = '{table_name.upper()}'
        """
        curs.execute(query)
        columns = [(row[0], row[1]) for row in curs.fetchall()]
        schema[table_name] = columns
    curs.close()
    conn.close()
    jpype.shutdownJVM()  # Shutdown JVM after use
    return schema

def generate_hive_sql(table_name, columns_list):

    setup_template = """
set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.dynamic.partition=true;
set hive.exec.parallel=true;
set mapred.reduce.tasks=10;
        """
    drop_template = """
DROP TABLE IF EXISTS rd_ewallet_{table_name};
        """
    create_rd_table_template = """
create external table if not exists rd_ewallet_{table_name} (
    {columns},
    CDR_FILE_NAME string,
    DOWNLOAD_TIME string
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
LOCATION '${{HDFS_DIR_RAW_ZONE_FINTECH}}/vtl_ewallet_{table_name}/${{YYYYMMDD}}'
TBLPROPERTIES (
    'EXTERNAL'='FALSE'
) 
;
    """

    create_f_table_template = """
CREATE EXTERNAL TABLE IF NOT EXISTS f_ewallet_{table_name} (
    {columns}
)       
PARTITIONED BY (partition string)
STORED AS parquet
LOCATION '${{HDFS_DIR_WORK_ZONE_FINTECH}}/f_ewallet_{table_name}'
TBLPROPERTIES (
    'parquet.compression' = 'SNAPPY'
);
    """

    insert_template = """
INSERT OVERWRITE TABLE f_ewallet_{table_name} PARTITION (partition)            
SELECT 
    {columns},
    from_unixtime(cast(SUM_DATE/1000 as bigint),'yyyyMMdd') partition
FROM rd_ewallet_{table_name};
    """

    drop_statement = drop_template.format(table_name=table_name.lower())
    column_definitions = " String,\n  ".join([f"{col[0]}" for col in columns_list]) + " String\n  "
    create_rd_table_statement = create_rd_table_template.format(
        table_name=table_name.lower(),
        columns=column_definitions
    )
    create_f_table_statement = create_f_table_template.format(
        table_name=table_name.lower(),
        columns=column_definitions
    )
    # Build columns for insert statement, converting DATE types
    insert_columns = []
    for col in columns_list:
        if col[1].lower() == 'date':
            insert_columns.append(
                f"from_unixtime(cast({col[0]}/1000 as bigint),'yyyy-MM-dd HH:mm:ss') as {col[0]}"
            )
        else:
            insert_columns.append(f"NULLIF({col[0]}, '') as {col[0]}")
    insert_statement = insert_template.format(
        table_name=table_name.lower(),
        columns=",\n  ".join(insert_columns)
    )

    sql_statement = f"{setup_template}\n{drop_statement}\n{create_rd_table_statement}\n{create_f_table_statement}\n{insert_statement}"
    return sql_statement

def generate_oracle_sql(table_name, columns_list):
    """
    Generates a SQL CREATE TABLE statement based on the provided table name and columns.

    Args:
        table_name (str): The name of the table to create.
        columns (list of tuples): A list of tuples where each tuple contains the column name and its data type.

    Returns:
        str: A SQL CREATE TABLE statement.
    """
    template = """
SELECT
    {columns}
FROM
    {table_name}
WHERE
    {col} >= TRUNC(SYSDATE - 1)
            AND {col} < TRUNC(SYSDATE)
        """
    column_definitions = ",\n  ".join([
        f"NULL as {col[0]}" if 'raw' in col[1].lower() else f"{col[0]}"
        for col in columns_list
    ])
    sql_statement = template.format(
        table_name=table_name,
        columns=column_definitions,
        col=columns_list[0][0]  # Assuming the first column is used for the WHERE clause
    )
    return sql_statement


def save_sql_to_file(table_name, schema):
    """
    Saves the generated SQL statement to a file.

    Args:
        sql_statement (str): The SQL statement to save.
        table_name (str): The name of the table for which the SQL is generated.
        path (str): The directory where the file will be saved.
    """
    # Oracle paths
    oracle_file_path = os.path.join(oracle_path, f"{table_name.lower()}.sql")
    oracle_sql_statement = generate_oracle_sql(table_name, schema)
    with open(oracle_file_path, 'w') as file:
        file.write(oracle_sql_statement)
    # Hive paths
    hive_file_path = os.path.join(hive_path, f"{table_name.lower()}.sql")       
    hive_sql_statement = generate_hive_sql(table_name, schema)
    with open(hive_file_path, 'w') as file:
        file.write(hive_sql_statement)  

def get_schema_from_file(file_path):
    """
    Reads a schema from a DDL file and returns it as a list of tuples (column_name, data_type).

    Args:
        file_path (str): Path to the file containing the schema.

    Returns:
        list of tuples: Each tuple contains (column_name, data_type).
    """
    schema = []
    with open(file_path, 'r') as file:
        content = file.read()

    # Extract the column definitions block between the first '(' after CREATE TABLE and the matching ')'
    match = re.search(r'CREATE\s+TABLE.*?\((.*?)(?:,?\s*PRIMARY\s+KEY|\)\s*SEGMENT|\)\s*PCTFREE|\)\s*TABLESPACE|\)\s*ENABLE|\)\s*NOCOMPRESS)', content, re.IGNORECASE | re.DOTALL)
    if not match:
        return schema

    columns_block = match.group(1)
    # Split by lines and process each line
    for line in columns_block.splitlines():
        line = line.strip().rstrip(',')
        if not line or line.startswith('PRIMARY KEY'):
            continue
        # Match pattern: "COLUMN_NAME" DATATYPE ...
        col_match = re.match(r'"?([\w\d_]+)"?\s+([A-Z0-9_]+(?:\([^)]+\))?)', line, re.IGNORECASE)
        if col_match:
            col_name = col_match.group(1)
            data_type = col_match.group(2)
            schema.append((col_name, data_type))
    return schema

if __name__ == "__main__":
    # Example usage
    # Load environment variables from .env file
    # env_path = os.path.join(os.path.dirname(__file__), '..', '.env')
    # load_dotenv(dotenv_path=env_path)

    # jdbc_url = os.getenv("ORACLE_JDBC")
    # user = os.getenv("ORACLE_USER")
    # password = os.getenv("ORACLE_PASSWORD")
    # driver_path = os.getenv("ORACLE_DRIVER_PATH")
    
    # table_name_list = ["ACCOUNT_RIGHT"]
    
    file_path = r"D:\Documents\Timor Leste Project\sql_scripts\oracle\ddl\\"
    for filename in os.listdir(file_path):
        if filename.endswith(".sql"):
            table_name = os.path.splitext(filename)[0]
            schema = get_schema_from_file(os.path.join(file_path, filename))
            print(f"{table_name}: {schema}")
            save_sql_to_file(table_name, schema)
    # table_name = "ACCOUNT_TYPE"
    # schema = get_schema_from_file(file_path + table_name + ".sql")
    # print(schema)
    # save_sql_to_file(table_name, schema)
    # schemas = get_oracle_list_table_schema(jdbc_url, user, password, table_name_list, driver_path)
    # try:
    #     for table in schemas.keys():
    #         print(f"Schema for {table}:")
    #         # print(schemas[table])
    #         save_sql_to_file(table, schemas[table])

            
    #         print(f"SQL files for {table} generated successfully.")
    # except Exception as e:
    #     print(f"Error occurred while processing {table}: {e}")
    #     print(schemas[table])
