DROP TABLE IF EXISTS rd_ewallet_log_bonus_deposit;

create external table if not exists rd_ewallet_log_bonus_deposit (
    IMEI String,
    CARRIED_ACC_ID String,
    TYPE String,
    ERR_CODE String,
    STATUS String,
    DATE_CREATED String,
    ERR_DES String,
    BONUS_AMOUNT String,
    TRANS_ID String,
    ID String,
    MSISDN String,
    DEPOSIT_AMOUNT String,
    CDR_FILE_NAME String,
    DOWNLOAD_TIME String
) ROW FORMAT DELIMITED FIELDS TERMINATED BY '|' 
LOCATION '${HDFS_DIR_RAW_ZONE_FINTECH}/vtl_ewallet_log_bonus_deposit/${YYYYMMDD}';

CREATE EXTERNAL TABLE IF NOT EXISTS f_ewallet_log_bonus_deposit (
    IMEI String,
    CARRIED_ACC_ID String,
    TYPE String,
    ERR_CODE String,
    STATUS String,
    DATE_CREATED String,
    ERR_DES String,
    BONUS_AMOUNT String,
    TRANS_ID String,
    ID String,
    MSISDN String,
    DEPOSIT_AMOUNT String 
) PARTITIONED BY (partition string) STORED AS parquet 
LOCATION '${HDFS_DIR_WORK_ZONE_FINTECH}/f_ewallet_log_bonus_deposit' 
TBLPROPERTIES ('parquet.compression' = 'SNAPPY');

INSERT OVERWRITE TABLE f_ewallet_log_bonus_deposit PARTITION (partition)
SELECT
    IMEI,
    CARRIED_ACC_ID,
    TYPE,
    ERR_CODE,
    STATUS,
    DATE_CREATED,
    ERR_DES,
    BONUS_AMOUNT,
    TRANS_ID,
    ID,
    MSISDN,
    DEPOSIT_AMOUNT,
    from_unixtime (cast(DATE_CREATED / 1000 as bigint), 'yyyyMMdd') partition
FROM
    rd_ewallet_log_bonus_deposit;