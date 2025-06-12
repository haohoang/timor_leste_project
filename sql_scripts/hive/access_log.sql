
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
    ID,
  ACTION_ID,
  CORE_TRANSACTION_ID,
  CREATED_DATE,
  DIRECTION,
  REF_TRANS_ID,
  REQUEST_CONTENT,
  RESPONSE_CODE,
  RESPONSE_CONTENT,
    from_unixtime(cast(SUM_DATE/1000 as bigint),'yyyyMMdd') partition
FROM rd_ewallet_access_log;
    