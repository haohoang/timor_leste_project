set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.dynamic.partition=true;
set hive.exec.parallel=true;
set mapred.reduce.tasks=10;


------------------------------GET data Soruce ------------------------------------------------
--ewallet_trans_fact_daily
drop table if exists rd_ewallet_trans_fact_daily;
create external table if not exists rd_ewallet_trans_fact_daily(
FACT_DATE string,
ACCOUNT_ID string,
TOTAL_CREDIT string,
TOTAL_DEBIT string,
TOTAL_TRANSFER string,
TOTAL_ENQUIRY string,
TOTAL_LOGIN string,
TOTAL_TRANSFER_FAIL string,
TOTAL_TRANSFER_BLOCK string,
TOTAL_LOGIN_FAIL string,
TOTAL_ACTION string,
OPENING_BALANCE string,
CLOSING_BALANCE string,
CDR_FILE_NAME string,
DOWNLOAD_TIME string
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
LOCATION '${HDFS_DIR_RAW_ZONE_FINTECH}/vtl_ewallet_trans_fact_daily/${YYYYMMDD}' 
;

CREATE EXTERNAL TABLE IF NOT EXISTS f_ewallet_trans_fact_daily (
FACT_DATE string,
ACCOUNT_ID string,
TOTAL_CREDIT string,
TOTAL_DEBIT string,
TOTAL_TRANSFER string,
TOTAL_ENQUIRY string,
TOTAL_LOGIN string,
TOTAL_TRANSFER_FAIL string,
TOTAL_TRANSFER_BLOCK string,
TOTAL_LOGIN_FAIL string,
TOTAL_ACTION string,
OPENING_BALANCE string,
CLOSING_BALANCE string
)
PARTITIONED BY (partition string)
STORED AS parquet
LOCATION '${HDFS_DIR_WORK_ZONE_FINTECH}/f_ewallet_trans_fact_daily'
TBLPROPERTIES (
  'parquet.compression' = 'SNAPPY'
);


INSERT OVERWRITE TABLE f_ewallet_trans_fact_daily PARTITION(partition)
select
FACT_DATE ,
ACCOUNT_ID ,
TOTAL_CREDIT ,
TOTAL_DEBIT ,
TOTAL_TRANSFER ,
TOTAL_ENQUIRY ,
TOTAL_LOGIN ,
TOTAL_TRANSFER_FAIL ,
TOTAL_TRANSFER_BLOCK ,
TOTAL_LOGIN_FAIL ,
TOTAL_ACTION ,
OPENING_BALANCE ,
CLOSING_BALANCE,
from_unixtime(cast(FACT_DATE/1000 as bigint),'yyyyMMdd') partition
from rd_ewallet_trans_fact_daily
;