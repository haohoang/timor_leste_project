set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.dynamic.partition=true;
set hive.exec.parallel=true;
set mapred.reduce.tasks=10;


DROP TABLE IF EXISTS rd_ewallet_party_role;

create external table if not exists rd_ewallet_party_role (
    PARTY_ID String,
    COMMISSION_FORWARD String,
    ROLE_ID String,
    LAST_PIN_CHANGED String,
    PARTITION_KEY String,
    MODIFY_BY String,
    CUST_ID String,
    BANK_ACCOUNT_ID String,
    PARTY_ROLE_ID String,
    STATUS String,
    PARTY_ROLE_NUMBER String,
    VALID_TO String,
    TIER String,
    PARTY_PAPER_ID String,
    SHOP_CODE String,
    DELEGATE_ID String,
    VALID_FROM String,
    DATE_MODIFIED String,
    CREATED_DATE String,
    PARENT_ID String,
    SUB_ID String,
    MSISDN String,
    PATH String,
    CDR_FILE_NAME string,
    DOWNLOAD_TIME string
) ROW FORMAT DELIMITED FIELDS TERMINATED BY '|' LOCATION '${HDFS_DIR_RAW_ZONE_FINTECH}/vtl_ewallet_party_role/${YYYYMMDD}';

CREATE EXTERNAL TABLE IF NOT EXISTS f_ewallet_party_role (
    PARTY_ID String,
    COMMISSION_FORWARD String,
    ROLE_ID String,
    LAST_PIN_CHANGED String,
    PARTITION_KEY String,
    MODIFY_BY String,
    CUST_ID String,
    BANK_ACCOUNT_ID String,
    PARTY_ROLE_ID String,
    STATUS String,
    PARTY_ROLE_NUMBER String,
    VALID_TO String,
    TIER String,
    PARTY_PAPER_ID String,
    SHOP_CODE String,
    DELEGATE_ID String,
    VALID_FROM String,
    DATE_MODIFIED String,
    CREATED_DATE String,
    PARENT_ID String,
    SUB_ID String,
    MSISDN String,
    PATH String
) PARTITIONED BY (PARTITION_KEY String) STORED AS parquet 
LOCATION '${HDFS_DIR_WORK_ZONE_FINTECH}/f_ewallet_party_role' 
TBLPROPERTIES ('parquet.compression' = 'SNAPPY');

INSERT OVERWRITE TABLE f_ewallet_party_role PARTITION (PARTITION_KEY)
SELECT
    PARTY_ID,
    COMMISSION_FORWARD,
    ROLE_ID,
    LAST_PIN_CHANGED,
    MODIFY_BY,
    CUST_ID,
    BANK_ACCOUNT_ID,
    PARTY_ROLE_ID,
    STATUS,
    PARTY_ROLE_NUMBER,
    VALID_TO,
    TIER,
    PARTY_PAPER_ID,
    SHOP_CODE,
    DELEGATE_ID,
    VALID_FROM,
    DATE_MODIFIED,
    CREATED_DATE,
    PARENT_ID,
    SUB_ID,
    MSISDN,
    PATH,
    PARTITION_KEY
FROM
    rd_ewallet_party_role;