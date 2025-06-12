set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.dynamic.partition=true;
set hive.exec.parallel=true;
set mapred.reduce.tasks=10;


------------------------------GET data Soruce ------------------------------------------------
--ewallet_trans_accounting_pending
drop table if exists rd_ewallet_trans_accounting_pending;
create external table if not exists rd_ewallet_trans_accounting_pending(
TRANS_ACCOUNTING_ID string,
TRANSACTION_ID string,
ACTION_ID string,
PROCESS_CODE string,
TRANS_TYPE_ID string,
ACTION_NODE_ID string,
FROM_ACC_ID string,
FROM_PARTY_ROLE_ID string,
TO_ACC_ID string,
TO_PARTY_ROLE_ID string,
AMOUNT string,
CURRENCY_CODE string,
DATE_CREATED string,
ACCOUNTING_TYPE_ID string,
TRANS_STATE_ID string,
STATUS string,
ERROR_CODE string,
ERROR_DES string,
TRANS_COMMISSION_ID string,
CDR_FILE_NAME string,
DOWNLOAD_TIME string
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
LOCATION '${HDFS_DIR_RAW_ZONE_FINTECH}/vtl_ewallet_trans_accounting_pending/${YYYYMMDD}' 
;

CREATE EXTERNAL TABLE IF NOT EXISTS f_ewallet_trans_accounting_pending (
TRANS_ACCOUNTING_ID string,
TRANSACTION_ID string,
ACTION_ID string,
PROCESS_CODE string,
TRANS_TYPE_ID string,
ACTION_NODE_ID string,
FROM_ACC_ID string,
FROM_PARTY_ROLE_ID string,
TO_ACC_ID string,
TO_PARTY_ROLE_ID string,
AMOUNT string,
CURRENCY_CODE string,
DATE_CREATED string,
ACCOUNTING_TYPE_ID string,
TRANS_STATE_ID string,
STATUS string,
ERROR_CODE string,
ERROR_DES string,
TRANS_COMMISSION_ID string
)
PARTITIONED BY (partition string)
STORED AS parquet
LOCATION '${HDFS_DIR_WORK_ZONE_FINTECH}/f_ewallet_trans_accounting_pending'
TBLPROPERTIES (
  'parquet.compression' = 'SNAPPY'
);


INSERT OVERWRITE TABLE f_ewallet_trans_accounting_pending PARTITION(partition)
select
TRANS_ACCOUNTING_ID
,TRANSACTION_ID
,ACTION_ID
,PROCESS_CODE
,TRANS_TYPE_ID
,ACTION_NODE_ID
,FROM_ACC_ID
,FROM_PARTY_ROLE_ID
,TO_ACC_ID
,TO_PARTY_ROLE_ID
,AMOUNT
,CURRENCY_CODE
,DATE_CREATED 
,ACCOUNTING_TYPE_ID
,TRANS_STATE_ID
,STATUS
,ERROR_CODE
,ERROR_DES
,TRANS_COMMISSION_ID
from_unixtime(cast(DATE_CREATED/1000 as bigint),'yyyyMMdd') partition
from rd_ewallet_trans_accounting_pending
;