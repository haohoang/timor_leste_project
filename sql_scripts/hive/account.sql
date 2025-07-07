set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.dynamic.partition=true;
set hive.exec.parallel=true;
set mapred.reduce.tasks=10;
      
DROP TABLE IF EXISTS rd_ewallet_account;
        
create external table if not exists rd_ewallet_account (
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
  RE_ACTIVE_TIME String
  ,
    CDR_FILE_NAME string,
    DOWNLOAD_TIME string
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
LOCATION '${HDFS_DIR_RAW_ZONE_FINTECH}/vtl_ewallet_account/${YYYYMMDD}'
TBLPROPERTIES (
    'EXTERNAL'='FALSE'
) 
;
    

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
  RE_ACTIVE_TIME String
  
)       
PARTITIONED BY (partition string)
STORED AS parquet
LOCATION '${HDFS_DIR_WORK_ZONE_FINTECH}/f_ewallet_account'
TBLPROPERTIES (
    'parquet.compression' = 'SNAPPY'
);
    

INSERT OVERWRITE TABLE f_ewallet_account PARTITION (partition)            
SELECT 
  NULLIF(ACCOUNT_ID, '') as ACCOUNT_ID,
  NULLIF(PAN, '') as PAN,
  NULLIF(ACCOUNT_STATE_ID, '') as ACCOUNT_STATE_ID,
  NULLIF(BALANCE, '') as BALANCE,
  NULLIF(ACCOUNT_TYPE_ID, '') as ACCOUNT_TYPE_ID,
  NULLIF(MODIFIED_DATE, '') as MODIFIED_DATE,
  NULLIF(CURRENCY_ID, '') as CURRENCY_ID,
  NULLIF(PARTY_ROLE_ID, '') as PARTY_ROLE_ID,
  NULLIF(CURRENCY, '') as CURRENCY,
  NULLIF(PARTITION_KEY, '') as PARTITION_KEY,
  NULLIF(HOLDING_BALANCE, '') as HOLDING_BALANCE,
  NULLIF(AVAILABLE_BALANCE, '') as AVAILABLE_BALANCE,
  NULLIF(CREATED_DATE, '') as CREATED_DATE,
  NULLIF(PIN, '') as PIN,
  NULLIF(VPAN, '') as VPAN,
  from_unixtime(cast(LAST_RESET_PIN/1000 as bigint),'yyyy-MM-dd HH:mm:ss') as LAST_RESET_PIN,
  NULLIF(IS_CURRENT, '') as IS_CURRENT,
  NULLIF(COUNT_QUERY_CASH, '') as COUNT_QUERY_CASH,
  from_unixtime(cast(ACTIVE_TIME/1000 as bigint),'yyyy-MM-dd HH:mm:ss') as ACTIVE_TIME,
  from_unixtime(cast(LAST_TRANS_TIME/1000 as bigint),'yyyy-MM-dd HH:mm:ss') as LAST_TRANS_TIME,
  from_unixtime(cast(LAST_CHANGE_BALANCE_TIME/1000 as bigint),'yyyy-MM-dd HH:mm:ss') as LAST_CHANGE_BALANCE_TIME,
  NULLIF(CURRENCY_CODE, '') as CURRENCY_CODE,
  from_unixtime(cast(RE_ACTIVE_TIME/1000 as bigint),'yyyy-MM-dd HH:mm:ss') as RE_ACTIVE_TIME,
  ${YYYYMMDD:DD-1} AS partition
FROM rd_ewallet_account;
    