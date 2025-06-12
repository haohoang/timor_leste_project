set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.dynamic.partition=true;
set hive.exec.parallel=true;
set mapred.reduce.tasks=10;


------------------------------GET data Soruce ------------------------------------------------
--ewallet_rpt_umoney_sum_bi
drop table if exists rd_ewallet_rpt_umoney_sum_bi;

create external table if not exists rd_ewallet_rpt_umoney_sum_bi(
  ID string,
  SUM_DATE string,
  ITEM_ID string,
  VALUE_DAY string,
  VALUE_MON string,
  INSERT_DATE string,
  DESCRIPTION string,
  SYN_STATUS string,
  SYN_DATE string,
  SYN_DES string,
  CDR_FILE_NAME string,
DOWNLOAD_TIME string
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
LOCATION '${HDFS_DIR_RAW_ZONE_FINTECH}/vtl_ewallet_rpt_umoney_sum_bi/${YYYYMMDD}' 
;

CREATE EXTERNAL TABLE IF NOT EXISTS f_ewallet_rpt_umoney_sum_bi (
ID string,
  SUM_DATE string,
  ITEM_ID string,
  VALUE_DAY string,
  VALUE_MON string,
  INSERT_DATE string,
  DESCRIPTION string,
  SYN_STATUS string,
  SYN_DATE string,
  SYN_DES string
)
PARTITIONED BY (partition string)
STORED AS parquet
LOCATION '${HDFS_DIR_WORK_ZONE_FINTECH}/f_ewallet_rpt_umoney_sum_bi'
TBLPROPERTIES (
  'parquet.compression' = 'SNAPPY'
);


INSERT OVERWRITE TABLE f_ewallet_rpt_umoney_sum_bi PARTITION(partition)
select
  ID,
 SUM_DATE,
  ITEM_ID,
  VALUE_DAY,
  VALUE_MON,
 INSERT_DATE,
  DESCRIPTION,
  SYN_STATUS,
  SYN_DATE,
  SYN_DES,
from_unixtime(cast(SUM_DATE/1000 as bigint),'yyyyMMdd') partition
from rd_ewallet_rpt_umoney_sum_bi
;