
set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.dynamic.partition=true;
set hive.exec.parallel=true;
set mapred.reduce.tasks=10;
        

DROP TABLE IF EXISTS rd_ewallet_account_type;
        

create external table if not exists rd_ewallet_account_type (
    ACCOUNT_TYPE_ID String,
  NAME String,
  LOCALE_KEY String
  ,
    CDR_FILE_NAME string,
    DOWNLOAD_TIME string
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
LOCATION '${HDFS_DIR_RAW_ZONE_FINTECH}/vtl_ewallet_account_type/${YYYYMMDD}' 
;
    

CREATE EXTERNAL TABLE IF NOT EXISTS f_ewallet_account_type (
    ACCOUNT_TYPE_ID String,
  NAME String,
  LOCALE_KEY String
  
)       
PARTITIONED BY (partition string)
STORED AS parquet
LOCATION '${HDFS_DIR_WORK_ZONE_FINTECH}/f_ewallet_account_type'
TBLPROPERTIES (
    'parquet.compression' = 'SNAPPY'
);
    

INSERT OVERWRITE TABLE f_ewallet_account_type PARTITION (partition)            
SELECT 
    ACCOUNT_TYPE_ID,
  NAME,
  LOCALE_KEY,
    from_unixtime(cast(SUM_DATE/1000 as bigint),'yyyyMMdd') partition
FROM rd_ewallet_account_type;
    