set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.dynamic.partition=true;
set hive.exec.parallel=true;
set mapred.reduce.tasks=10;


DROP TABLE IF EXISTS rd_ewallet_account;
drop table if exists f_ewallet_account;

CREATE EXTERNAL TABLE IF NOT EXISTS rd_ewallet_account (
    ACCOUNT_ID String,
    PAN String,
    ACCOUNT_STATE_ID String,
    BALANCE String,
    ACCOUNT_TYPE_ID String,
    MODIFIED_DATE String,
    CURRENCY_ID String,
    PARTY_ROLE_ID String,
    CURRENCY String,
    PARTITION_KEY String,
    HOLDING_BALANCE String,
    AVAILABLE_BALANCE String,
    CREATED_DATE String,
    PIN String,
    VPAN String,
    LAST_RESET_PIN String,
    IS_CURRENT String,
    COUNT_QUERY_CASH String,
    ACTIVE_TIME String,
    LAST_TRANS_TIME String,
    LAST_CHANGE_BALANCE_TIME String,
    CURRENCY_CODE String,
    RE_ACTIVE_TIME String,
    CDR_FILE_NAME String,
    DOWNLOAD_TIME String

     
)
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY '|'
LOCATION '${HDFS_DIR_RAW_ZONE_FINTECH}/vtl_ewallet_account/${YYYYMMDD}';

CREATE EXTERNAL TABLE IF NOT EXISTS f_ewallet_account (
    ACCOUNT_ID String,
    PAN String,
    ACCOUNT_STATE_ID String,
    BALANCE String,
    ACCOUNT_TYPE_ID String,
    MODIFIED_DATE String,
    CURRENCY_ID String,
    PARTY_ROLE_ID String,
    CURRENCY String,
    HOLDING_BALANCE String,
    AVAILABLE_BALANCE String,
    CREATED_DATE String,
    PIN String,
    VPAN String,
    LAST_RESET_PIN String,
    IS_CURRENT String,
    COUNT_QUERY_CASH String,
    ACTIVE_TIME String,
    LAST_TRANS_TIME String,
    LAST_CHANGE_BALANCE_TIME String,
    CURRENCY_CODE String,
    RE_ACTIVE_TIME String
)
PARTITIONED BY (PARTITION_KEY STRING)
STORED AS PARQUET
LOCATION '${HDFS_DIR_WORK_ZONE_FINTECH}/f_ewallet_account'
TBLPROPERTIES (
    'parquet.compression' = 'SNAPPY'
);

INSERT OVERWRITE TABLE f_ewallet_account PARTITION (PARTITION_KEY)
SELECT
    ACCOUNT_ID ,
    PAN ,
    ACCOUNT_STATE_ID ,
    BALANCE ,
    ACCOUNT_TYPE_ID ,
    MODIFIED_DATE ,
    CURRENCY_ID ,
    PARTY_ROLE_ID ,
    CURRENCY ,
    HOLDING_BALANCE ,
    AVAILABLE_BALANCE ,
    CREATED_DATE ,
    PIN ,
    VPAN ,
    LAST_RESET_PIN ,
    IS_CURRENT ,
    COUNT_QUERY_CASH ,
    ACTIVE_TIME ,
    LAST_TRANS_TIME ,
    LAST_CHANGE_BALANCE_TIME ,
    CURRENCY_CODE ,
    RE_ACTIVE_TIME,
    PARTITION_KEY 
FROM rd_ewallet_account;
