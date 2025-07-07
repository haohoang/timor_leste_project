
set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.dynamic.partition=true;
set hive.exec.parallel=true;
set mapred.reduce.tasks=10;
        

DROP TABLE IF EXISTS rd_ewallet_party_role;
        

create external table if not exists rd_ewallet_party_role (
    PARTY_ROLE_ID String,
  ROLE_ID String,
  VALID_FROM String,
  VALID_TO String,
  STATUS String,
  MSISDN String,
  CREATED_DATE String,
  DATE_MODIFIED String,
  TIER String,
  LAST_PIN_CHANGED String,
  PARTITION_KEY String,
  PARTY_ROLE_NUMBER String,
  PATH String,
  PARENT_ID String,
  MODIFY_BY String,
  PARTY_ID String,
  PARTY_PAPER_ID String,
  SUB_ID String,
  CUST_ID String,
  SHOP_CODE String,
  COMMISSION_FORWARD String,
  DELEGATE_ID String,
  BANK_ACCOUNT_ID String
  ,
    CDR_FILE_NAME string,
    DOWNLOAD_TIME string
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
LOCATION '${HDFS_DIR_RAW_ZONE_FINTECH}/vtl_ewallet_party_role/${YYYYMMDD}'
TBLPROPERTIES (
    'EXTERNAL'='FALSE'
) 
;
    

CREATE EXTERNAL TABLE IF NOT EXISTS f_ewallet_party_role (
    PARTY_ROLE_ID String,
  ROLE_ID String,
  VALID_FROM String,
  VALID_TO String,
  STATUS String,
  MSISDN String,
  CREATED_DATE String,
  DATE_MODIFIED String,
  TIER String,
  LAST_PIN_CHANGED String,
  PARTITION_KEY String,
  PARTY_ROLE_NUMBER String,
  PATH String,
  PARENT_ID String,
  MODIFY_BY String,
  PARTY_ID String,
  PARTY_PAPER_ID String,
  SUB_ID String,
  CUST_ID String,
  SHOP_CODE String,
  COMMISSION_FORWARD String,
  DELEGATE_ID String,
  BANK_ACCOUNT_ID String
  
)       
PARTITIONED BY (partition string)
STORED AS parquet
LOCATION '${HDFS_DIR_WORK_ZONE_FINTECH}/f_ewallet_party_role'
TBLPROPERTIES (
    'parquet.compression' = 'SNAPPY'
);
    

INSERT OVERWRITE TABLE f_ewallet_party_role PARTITION (partition)            
SELECT 
    NULLIF(PARTY_ROLE_ID, '') as PARTY_ROLE_ID,
  NULLIF(ROLE_ID, '') as ROLE_ID,
  from_unixtime(cast(VALID_FROM/1000 as bigint),'yyyy-MM-dd HH:mm:ss') as VALID_FROM,
  from_unixtime(cast(VALID_TO/1000 as bigint),'yyyy-MM-dd HH:mm:ss') as VALID_TO,
  NULLIF(STATUS, '') as STATUS,
  NULLIF(MSISDN, '') as MSISDN,
  from_unixtime(cast(CREATED_DATE/1000 as bigint),'yyyy-MM-dd HH:mm:ss') as CREATED_DATE,
  from_unixtime(cast(DATE_MODIFIED/1000 as bigint),'yyyy-MM-dd HH:mm:ss') as DATE_MODIFIED,
  NULLIF(TIER, '') as TIER,
  from_unixtime(cast(LAST_PIN_CHANGED/1000 as bigint),'yyyy-MM-dd HH:mm:ss') as LAST_PIN_CHANGED,
  NULLIF(PARTITION_KEY, '') as PARTITION_KEY,
  NULLIF(PARTY_ROLE_NUMBER, '') as PARTY_ROLE_NUMBER,
  NULLIF(PATH, '') as PATH,
  NULLIF(PARENT_ID, '') as PARENT_ID,
  NULLIF(MODIFY_BY, '') as MODIFY_BY,
  NULLIF(PARTY_ID, '') as PARTY_ID,
  NULLIF(PARTY_PAPER_ID, '') as PARTY_PAPER_ID,
  NULLIF(SUB_ID, '') as SUB_ID,
  NULLIF(CUST_ID, '') as CUST_ID,
  NULLIF(SHOP_CODE, '') as SHOP_CODE,
  NULLIF(COMMISSION_FORWARD, '') as COMMISSION_FORWARD,
  NULLIF(DELEGATE_ID, '') as DELEGATE_ID,
  NULLIF(BANK_ACCOUNT_ID, '') as BANK_ACCOUNT_ID,
  '${YYYYMMDD:DD-1}' AS partition
FROM rd_ewallet_party_role;
    