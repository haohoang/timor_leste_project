set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.dynamic.partition=true;
set hive.exec.parallel=true;
set mapred.reduce.tasks=10;


------------------------------GET data Soruce ------------------------------------------------
--ewallet_trans_cash
drop table if exists rd_ewallet_trans_cash;
create external table if not exists rd_ewallet_trans_cash(
ACTION_ID string,
  FROM_ACCOUNT string,
  TO_ACCOUNT string,
  FROM_NAME string,
  TO_NAME string,
  TO_CURRENCY string,
  ORG_CURRENCY string,
  EX_RATE string,
  CREATED_DATE string,
  ACTION_STATE string,
  SECRET_CODE string,
  LOCK_ACTION_ID string,
  REFER_ACTION_ID string,
  CARRIED_ACCOUNT string,
  CARRIED_NAME string,
  AREA_RECEIVER string,
  ADDRESS string,
  PROCESS_CODE string,
  LAST_MODIFIED string,
  CARRIED_CODE string,
  STAFF_CODE string,
  STAFF_NAME string,
  EXPIRED_DATE string,
  AMOUNT string,
  ORG_AMOUNT string,
  FROM_PHONE string,
  TO_PHONE string,
  CONTENT string,
  RE_CARRIED_ACCOUNT string,
  RE_CARRIED_NAME string,
  RE_STAFF_CODE string,
  RE_STAFF_NAME string,
  RE_CARRIED_PHONE string,
  CARRIED_PHONE string,
  TRANSACTION_ID string,
  CDR_FILE_NAME string,
  DOWNLOAD_TIME string
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
LOCATION '${HDFS_DIR_RAW_ZONE_FINTECH}/vtl_ewallet_trans_cash/${YYYYMMDD}' 
;

CREATE EXTERNAL TABLE IF NOT EXISTS f_ewallet_trans_cash (
ACTION_ID string,
  FROM_ACCOUNT string,
  TO_ACCOUNT string,
  FROM_NAME string,
  TO_NAME string,
  TO_CURRENCY string,
  ORG_CURRENCY string,
  EX_RATE string,
  CREATED_DATE string,
  ACTION_STATE string,
  SECRET_CODE string,
  LOCK_ACTION_ID string,
  REFER_ACTION_ID string,
  CARRIED_ACCOUNT string,
  CARRIED_NAME string,
  AREA_RECEIVER string,
  ADDRESS string,
  PROCESS_CODE string,
  LAST_MODIFIED string,
  CARRIED_CODE string,
  STAFF_CODE string,
  STAFF_NAME string,
  EXPIRED_DATE string,
  AMOUNT string,
  ORG_AMOUNT string,
  FROM_PHONE string,
  TO_PHONE string,
  CONTENT string,
  RE_CARRIED_ACCOUNT string,
  RE_CARRIED_NAME string,
  RE_STAFF_CODE string,
  RE_STAFF_NAME string,
  RE_CARRIED_PHONE string,
  CARRIED_PHONE string,
  TRANSACTION_ID string
)
PARTITIONED BY (partition string)
STORED AS parquet
LOCATION '${HDFS_DIR_WORK_ZONE_FINTECH}/f_ewallet_trans_cash'
TBLPROPERTIES (
  'parquet.compression' = 'SNAPPY'
);


INSERT OVERWRITE TABLE f_ewallet_trans_cash PARTITION(partition)
select
ACTION_ID,
  FROM_ACCOUNT,
  TO_ACCOUNT,
  FROM_NAME,
  TO_NAME,
  TO_CURRENCY,
  ORG_CURRENCY,
  EX_RATE,
  from_unixtime(cast(CREATED_DATE/1000 as bigint),'yyyy-MM-dd HH:mm:ss') CREATED_DATE,
  ACTION_STATE,
  SECRET_CODE,
  LOCK_ACTION_ID,
  REFER_ACTION_ID,
  CARRIED_ACCOUNT,
  CARRIED_NAME,
  AREA_RECEIVER,
  ADDRESS,
  PROCESS_CODE,
  from_unixtime(cast(CREATED_DATE/1000 as bigint),'yyyy-MM-dd HH:mm:ss') LAST_MODIFIED,
  CARRIED_CODE,
  STAFF_CODE,
  STAFF_NAME,
  from_unixtime(cast(CREATED_DATE/1000 as bigint),'yyyy-MM-dd HH:mm:ss') EXPIRED_DATE,
  AMOUNT,
  ORG_AMOUNT,
  FROM_PHONE,
  TO_PHONE,
  CONTENT,
  RE_CARRIED_ACCOUNT,
  RE_CARRIED_NAME,
  RE_STAFF_CODE,
  RE_STAFF_NAME,
  RE_CARRIED_PHONE,
  CARRIED_PHONE,
  TRANSACTION_ID,
from_unixtime(cast(CREATED_DATE/1000 as bigint),'yyyyMMdd') partition
from rd_ewallet_trans_cash
;