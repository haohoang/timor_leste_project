# from pyspark.sql.functions import *
# from pyspark.sql import SparkSession
from datetime import timedelta, datetime
import sys

# spark = SparkSession.builder.appName("potential_timing_data").getOrCreate()
# spark.sparkContext.setLogLevel("ERROR")

if len(sys.argv) == 1:
    PARTITION_DATE = (datetime.today() - timedelta(days=1)).strftime("%Y%m%d")
else:
    PARTITION_DATE = sys.argv[1]

print(f"Partition Date: {PARTITION_DATE}")
PARTITION_MONTH = PARTITION_DATE[:6]
today = datetime.strptime(PARTITION_DATE, "%Y%m%d") + timedelta(days = 1)
F_DATE_OF_MONTH_N_1 = ((today).replace(day=1) - timedelta(days=1)).replace(day=1).strftime("%Y%m%d")
L_DATE_OF_MONTH_N_1 = ((today).replace(day=1) - timedelta(days=1)).strftime("%Y%m%d")

DATA_TRANS = "F013_PRE_VAS_MONTH"
DATA_PACKAGE = "/work_zone/fintech/users/tiennv399/timor_package.csv"
POTENTIAL_LEAD = "/work_zone/fintech/level2/f_ewallet_potential_lead"

# def mosan_user(partition_date):
#     mosan_customer = spark.read.parquet("/work_zone/fintech/level1/f_ewallet_account_status_view/partition='{}'".format(partition_date))\
#                     .select("msisdn", "role_name", "account_state_name")\
#                     .filter((col("role_name") == "Customer") & (col("account_state_name") == "ACTIVE"))\
#                     .withColumn("isdn", substring("msisdn", 4, 8))\
#                     .select("isdn")\
#                     .withColumn("mosan_user", lit(1)).dropDuplicates()
#     return mosan_customer
# def data_trans(partition_date):
#     data_trans = spark.read.table(DATA_TRANS)\
#                     .filter((col("partition") == partition_date) & (col("vas_type") == "VAS_MO_HIS"))\
#                     .withColumn("pack_name", regexp_replace(upper(col("vas_service")), ' ', ''))\
#                     .select("isdn", "pack_name", "partition")\
#                     .dropDuplicates()
    
#     return data_trans

# if __name__ == "__main__":
#     ransu_list = ["DL", "DF"]
#     du_list = ["DUB1", "D1", "4G1", "DU4G", "DUB2", "DUE", "DU2"]
#     dj_list = ["D2", "FBU"]

#     mosan_list = mosan_user(PARTITION_DATE)
#     data_package = spark.read.csv(DATA_PACKAGE, header=True, inferSchema=True)

#     data_transaction = data_trans(PARTITION_DATE)

#     package_used_detail = data_transaction.join(data_package, "pack_name", "inner")

#     potential_lead = package_used_detail.withColumn("rule_type", 
#                                                when(col("pack_name").isin(ransu_list), "ransu")
#                                                .when(col("pack_name").isin(du_list), "du")
#                                                .when(col("pack_name") == "DU4G7", "du7")
#                                                .when(col("pack_name").isin(dj_list), "dj")
#                                                .when(col("pack_name") == "FB", "fb2")
#                                                .when(col("pack_name") == "DU4G30", "du30")
#                                                .otherwise("extend")
#                                               )\
#                                     .withColumn("SEND_DATE", 
#                                                 date_format(expr("date_add(to_date(partition, 'yyyyMMdd'), cast(date_add as int))"), "yyyyMMdd")
#                                     )
    
#     potential_lead = potential_lead.join(mosan_list, "isdn", "left")\
#                                 .fillna(0, "mosan_user")\
#                                 .select("isdn", "mosan_user", "rule_type", "partition")\
#                                 .dropDuplicates().cache()    
#     potential_lead.write.partitionBy("partition").mode("append").parquet(POTENTIAL_LEAD)
    

