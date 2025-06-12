-- Set Hive execution parameters
set hive.exec.dynamic.partition.mode = nonstrict;
set hive.exec.dynamic.partition = true;
set hive.exec.parallel = true;
set mapred.reduce.tasks = 10;

-- Drop the raw table if it exists
DROP TABLE IF EXISTS rd_ewallet_account_right;

-- Create the raw external table
CREATE EXTERNAL TABLE IF NOT EXISTS rd_ewallet_account_right (
    ACCOUNT_RIGHT_ID      STRING,
    ACCOUNT_ID            STRING,
    ACCOUNT_STATE_ID      STRING,
    PROCESS_CODE          STRING,
    TRANSACTION_TYPE_ID   STRING,
    ACCOUNT_TYPE_ID       STRING,
    CREATED_BY            STRING,
    MODIFIED_BY           STRING,
    CREATED_TIME          STRING,
    LAST_MODIFIED         STRING,
    STATUS                STRING,
    EFFECT_TYPE           STRING,
    PARTNER_CODE          STRING,
    SERVICE_CODE          STRING,
    CDR_FILE_NAME         STRING,
    DOWNLOAD_TIME         STRING
)
ROW FORMAT DELIMITED 
    FIELDS TERMINATED BY '|'
LOCATION '${HDFS_DIR_RAW_ZONE_FINTECH}/vtl_ewallet_account_right/${YYYYMMDD}';

-- Create the processed external table
CREATE EXTERNAL TABLE IF NOT EXISTS f_ewallet_account_right (
    ACCOUNT_RIGHT_ID      STRING,
    ACCOUNT_ID            STRING,
    ACCOUNT_STATE_ID      STRING,
    PROCESS_CODE          STRING,
    TRANSACTION_TYPE_ID   STRING,
    ACCOUNT_TYPE_ID       STRING,
    CREATED_BY            STRING,
    MODIFIED_BY           STRING,
    CREATED_TIME          STRING,
    LAST_MODIFIED         STRING,
    STATUS                STRING,
    EFFECT_TYPE           STRING,
    PARTNER_CODE          STRING,
    SERVICE_CODE          STRING
)
STORED AS PARQUET
LOCATION '${HDFS_DIR_WORK_ZONE_FINTECH}/f_ewallet_account_right'
TBLPROPERTIES (
    'parquet.compression' = 'SNAPPY'
);

-- Insert data into the processed table with partitioning
INSERT OVERWRITE TABLE f_ewallet_account_right 
SELECT
    ACCOUNT_RIGHT_ID,
    ACCOUNT_ID,
    ACCOUNT_STATE_ID,
    PROCESS_CODE,
    TRANSACTION_TYPE_ID,
    ACCOUNT_TYPE_ID,
    CREATED_BY,
    MODIFIED_BY,
    from_unixtime(cast(CREATED_TIME / 1000 AS BIGINT), 'yyyy-MM-dd HH:mm:ss') AS CREATED_TIME,
    from_unixtime(cast(LAST_MODIFIED / 1000 AS BIGINT), 'yyyy-MM-dd HH:mm:ss') AS LAST_MODIFIED,
    STATUS,
    EFFECT_TYPE,
    PARTNER_CODE,
    SERVICE_CODE
FROM rd_ewallet_account_right;
