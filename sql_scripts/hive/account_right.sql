
set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.dynamic.partition=true;
set hive.exec.parallel=true;
set mapred.reduce.tasks=10;
        

DROP TABLE IF EXISTS rd_ewallet_account_right;
        

create external table if not exists rd_ewallet_account_right (
    ACCOUNT_RIGHT_ID String,
  ACCOUNT_ID String,
  ACCOUNT_STATE_ID String,
  PROCESS_CODE String,
  TRANSACTION_TYPE_ID String,
  ACCOUNT_TYPE_ID String,
  CREATED_BY String,
  MODIFIED_BY String,
  CREATED_TIME String,
  LAST_MODIFIED String,
  STATUS String,
  EFFECT_TYPE String,
  PARTNER_CODE String,
  SERVICE_CODE String
  ,
    CDR_FILE_NAME string,
    DOWNLOAD_TIME string
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
LOCATION '${HDFS_DIR_RAW_ZONE_FINTECH}/vtl_ewallet_account_right/${YYYYMMDD}'
TBLPROPERTIES (
    'EXTERNAL'='FALSE'
) 
;
    

CREATE EXTERNAL TABLE IF NOT EXISTS f_ewallet_account_right (
    ACCOUNT_RIGHT_ID String,
  ACCOUNT_ID String,
  ACCOUNT_STATE_ID String,
  PROCESS_CODE String,
  TRANSACTION_TYPE_ID String,
  ACCOUNT_TYPE_ID String,
  CREATED_BY String,
  MODIFIED_BY String,
  CREATED_TIME String,
  LAST_MODIFIED String,
  STATUS String,
  EFFECT_TYPE String,
  PARTNER_CODE String,
  SERVICE_CODE String
  
)       
PARTITIONED BY (partition string)
STORED AS parquet
LOCATION '${HDFS_DIR_WORK_ZONE_FINTECH}/f_ewallet_account_right'
TBLPROPERTIES (
    'parquet.compression' = 'SNAPPY'
);
    

INSERT OVERWRITE TABLE f_ewallet_account_right PARTITION (partition)            
SELECT 
    NULLIF(ACCOUNT_RIGHT_ID, '') as ACCOUNT_RIGHT_ID,
  NULLIF(ACCOUNT_ID, '') as ACCOUNT_ID,
  NULLIF(ACCOUNT_STATE_ID, '') as ACCOUNT_STATE_ID,
  NULLIF(PROCESS_CODE, '') as PROCESS_CODE,
  NULLIF(TRANSACTION_TYPE_ID, '') as TRANSACTION_TYPE_ID,
  NULLIF(ACCOUNT_TYPE_ID, '') as ACCOUNT_TYPE_ID,
  NULLIF(CREATED_BY, '') as CREATED_BY,
  NULLIF(MODIFIED_BY, '') as MODIFIED_BY,
  from_unixtime(cast(CREATED_TIME/1000 as bigint),'yyyy-MM-dd HH:mm:ss') as CREATED_TIME,
  from_unixtime(cast(LAST_MODIFIED/1000 as bigint),'yyyy-MM-dd HH:mm:ss') as LAST_MODIFIED,
  NULLIF(STATUS, '') as STATUS,
  NULLIF(EFFECT_TYPE, '') as EFFECT_TYPE,
  NULLIF(PARTNER_CODE, '') as PARTNER_CODE,
  NULLIF(SERVICE_CODE, '') as SERVICE_CODE,
    from_unixtime(cast(SUM_DATE/1000 as bigint),'yyyyMMdd') partition
FROM rd_ewallet_account_right;
    