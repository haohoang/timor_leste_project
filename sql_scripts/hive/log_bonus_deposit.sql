
set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.dynamic.partition=true;
set hive.exec.parallel=true;
set mapred.reduce.tasks=10;
        

DROP TABLE IF EXISTS rd_ewallet_log_bonus_deposit;
        

create external table if not exists rd_ewallet_log_bonus_deposit (
    ID String,
  MSISDN String,
  DEPOSIT_AMOUNT String,
  BONUS_AMOUNT String,
  TYPE String,
  DATE_CREATED String,
  STATUS String,
  ERR_CODE String,
  ERR_DES String,
  TRANS_ID String,
  CARRIED_ACC_ID String,
  IMEI String
  ,
    CDR_FILE_NAME string,
    DOWNLOAD_TIME string
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
LOCATION '${HDFS_DIR_RAW_ZONE_FINTECH}/vtl_ewallet_log_bonus_deposit/${YYYYMMDD}'
TBLPROPERTIES (
    'EXTERNAL'='FALSE'
) 
;
    

CREATE EXTERNAL TABLE IF NOT EXISTS f_ewallet_log_bonus_deposit (
    ID String,
  MSISDN String,
  DEPOSIT_AMOUNT String,
  BONUS_AMOUNT String,
  TYPE String,
  DATE_CREATED String,
  STATUS String,
  ERR_CODE String,
  ERR_DES String,
  TRANS_ID String,
  CARRIED_ACC_ID String,
  IMEI String
  
)       
PARTITIONED BY (partition string)
STORED AS parquet
LOCATION '${HDFS_DIR_WORK_ZONE_FINTECH}/f_ewallet_log_bonus_deposit'
TBLPROPERTIES (
    'parquet.compression' = 'SNAPPY'
);
    

INSERT OVERWRITE TABLE f_ewallet_log_bonus_deposit PARTITION (partition)            
SELECT 
    NULLIF(ID, '') as ID,
  NULLIF(MSISDN, '') as MSISDN,
  NULLIF(DEPOSIT_AMOUNT, '') as DEPOSIT_AMOUNT,
  NULLIF(BONUS_AMOUNT, '') as BONUS_AMOUNT,
  NULLIF(TYPE, '') as TYPE,
  from_unixtime(cast(DATE_CREATED/1000 as bigint),'yyyy-MM-dd HH:mm:ss') as DATE_CREATED,
  NULLIF(STATUS, '') as STATUS,
  NULLIF(ERR_CODE, '') as ERR_CODE,
  NULLIF(ERR_DES, '') as ERR_DES,
  NULLIF(TRANS_ID, '') as TRANS_ID,
  NULLIF(CARRIED_ACC_ID, '') as CARRIED_ACC_ID,
  NULLIF(IMEI, '') as IMEI,
    from_unixtime(cast(DATE_CREATED/1000 as bigint),'yyyyMMdd') partition
FROM rd_ewallet_log_bonus_deposit;
    