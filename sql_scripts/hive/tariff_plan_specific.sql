set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.dynamic.partition=true;
set hive.exec.parallel=true;
set mapred.reduce.tasks=10;


DROP TABLE IF EXISTS rd_ewallet_tariff_plan_specific;

create external table if not exists rd_ewallet_tariff_plan_specific (
    PIORITY String,
    ACCOUNT_ID String,
    CREATED_BY String,
    VERSION String,
    STATUS String,
    TARIFF_PLAN_ID String,
    VALID_TO String,
    VALID_FROM String,
    CREATED_DATE String,
    MODIFIED_DATE String,
    MODIFIED_BY String,
    PLAN_NAME String,
    CDR_FILE_NAME string,
    DOWNLOAD_TIME string
) ROW FORMAT DELIMITED FIELDS TERMINATED BY '|' 
LOCATION '${HDFS_DIR_RAW_ZONE_FINTECH}/vtl_ewallet_tariff_plan_specific/${YYYYMMDD}';

CREATE EXTERNAL TABLE IF NOT EXISTS f_ewallet_tariff_plan_specific (
    PIORITY String,
    ACCOUNT_ID String,
    CREATED_BY String,
    VERSION String,
    STATUS String,
    TARIFF_PLAN_ID String,
    VALID_TO String,
    VALID_FROM String,
    CREATED_DATE String,
    MODIFIED_DATE String,
    MODIFIED_BY String,
    PLAN_NAME String
) STORED AS parquet
LOCATION '${HDFS_DIR_WORK_ZONE_FINTECH}/f_ewallet_tariff_plan_specific'
TBLPROPERTIES ('parquet.compression' = 'SNAPPY');

INSERT OVERWRITE TABLE f_ewallet_tariff_plan_specific 
SELECT
    PIORITY,
    ACCOUNT_ID,
    CREATED_BY,
    VERSION,
    STATUS,
    TARIFF_PLAN_ID,
    VALID_TO,
    VALID_FROM,
    CREATED_DATE,
    MODIFIED_DATE,
    MODIFIED_BY,
    PLAN_NAME
FROM
    rd_ewallet_tariff_plan_specific;