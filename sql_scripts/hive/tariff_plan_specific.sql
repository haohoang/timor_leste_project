
set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.dynamic.partition=true;
set hive.exec.parallel=true;
set mapred.reduce.tasks=10;
        

DROP TABLE IF EXISTS rd_ewallet_tariff_plan_specific;
        

create external table if not exists rd_ewallet_tariff_plan_specific (
    TARIFF_PLAN_ID String,
  ACCOUNT_ID String,
  STATUS String,
  VALID_FROM String,
  VALID_TO String,
  PLAN_NAME String,
  VERSION String,
  PIORITY String,
  CREATED_DATE String,
  CREATED_BY String,
  MODIFIED_DATE String,
  MODIFIED_BY String
  ,
    CDR_FILE_NAME string,
    DOWNLOAD_TIME string
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
LOCATION '${HDFS_DIR_RAW_ZONE_FINTECH}/vtl_ewallet_tariff_plan_specific/${YYYYMMDD}'
TBLPROPERTIES (
    'EXTERNAL'='FALSE'
) 
;
    

CREATE EXTERNAL TABLE IF NOT EXISTS f_ewallet_tariff_plan_specific (
    TARIFF_PLAN_ID String,
  ACCOUNT_ID String,
  STATUS String,
  VALID_FROM String,
  VALID_TO String,
  PLAN_NAME String,
  VERSION String,
  PIORITY String,
  CREATED_DATE String,
  CREATED_BY String,
  MODIFIED_DATE String,
  MODIFIED_BY String
  
)       
PARTITIONED BY (partition string)
STORED AS parquet
LOCATION '${HDFS_DIR_WORK_ZONE_FINTECH}/f_ewallet_tariff_plan_specific'
TBLPROPERTIES (
    'parquet.compression' = 'SNAPPY'
);
    

INSERT OVERWRITE TABLE f_ewallet_tariff_plan_specific PARTITION (partition)            
SELECT 
    NULLIF(TARIFF_PLAN_ID, '') as TARIFF_PLAN_ID,
  NULLIF(ACCOUNT_ID, '') as ACCOUNT_ID,
  NULLIF(STATUS, '') as STATUS,
  from_unixtime(cast(VALID_FROM/1000 as bigint),'yyyy-MM-dd HH:mm:ss') as VALID_FROM,
  from_unixtime(cast(VALID_TO/1000 as bigint),'yyyy-MM-dd HH:mm:ss') as VALID_TO,
  NULLIF(PLAN_NAME, '') as PLAN_NAME,
  NULLIF(VERSION, '') as VERSION,
  NULLIF(PIORITY, '') as PIORITY,
  from_unixtime(cast(CREATED_DATE/1000 as bigint),'yyyy-MM-dd HH:mm:ss') as CREATED_DATE,
  NULLIF(CREATED_BY, '') as CREATED_BY,
  from_unixtime(cast(MODIFIED_DATE/1000 as bigint),'yyyy-MM-dd HH:mm:ss') as MODIFIED_DATE,
  NULLIF(MODIFIED_BY, '') as MODIFIED_BY,
    '${YYYYMMDD:DD-1}' AS partition
FROM rd_ewallet_tariff_plan_specific;
    