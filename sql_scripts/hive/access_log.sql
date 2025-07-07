
set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.dynamic.partition=true;
set hive.exec.parallel=true;
set mapred.reduce.tasks=10;
        

DROP TABLE IF EXISTS rd_ewallet_access_log;
        

create external table if not exists rd_ewallet_access_log (
    ID String,
  ACTION_ID String,
  CORE_TRANSACTION_ID String,
  CREATED_DATE String,
  DIRECTION String,
  REF_TRANS_ID String,
  REQUEST_CONTENT String,
  RESPONSE_CODE String,
  RESPONSE_CONTENT String
  ,
    CDR_FILE_NAME string,
    DOWNLOAD_TIME string
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
LOCATION '${HDFS_DIR_RAW_ZONE_FINTECH}/vtl_ewallet_access_log/${YYYYMMDD}'
TBLPROPERTIES (
    'EXTERNAL'='FALSE'
) 
;
    

CREATE EXTERNAL TABLE IF NOT EXISTS f_ewallet_access_log (
    ID String,
  ACTION_ID String,
  CORE_TRANSACTION_ID String,
  CREATED_DATE String,
  DIRECTION String,
  REF_TRANS_ID String,
  REQUEST_CONTENT String,
  RESPONSE_CODE String,
  RESPONSE_CONTENT String
  
)       
PARTITIONED BY (partition string)
STORED AS parquet
LOCATION '${HDFS_DIR_WORK_ZONE_FINTECH}/f_ewallet_access_log'
TBLPROPERTIES (
    'parquet.compression' = 'SNAPPY'
);
    

INSERT OVERWRITE TABLE f_ewallet_access_log PARTITION (partition)            
SELECT 
    NULLIF(ID, '') as ID,
  NULLIF(ACTION_ID, '') as ACTION_ID,
  NULLIF(CORE_TRANSACTION_ID, '') as CORE_TRANSACTION_ID,
  NULLIF(CREATED_DATE, '') as CREATED_DATE,
  NULLIF(DIRECTION, '') as DIRECTION,
  NULLIF(REF_TRANS_ID, '') as REF_TRANS_ID,
  NULLIF(REQUEST_CONTENT, '') as REQUEST_CONTENT,
  NULLIF(RESPONSE_CODE, '') as RESPONSE_CODE,
  NULLIF(RESPONSE_CONTENT, '') as RESPONSE_CONTENT,
    from_unixtime(cast(SUM_DATE/1000 as bigint),'yyyyMMdd') partition
FROM rd_ewallet_access_log;
    