import os

with open("D:\Documents\Timor Leste Project\script\list_folders.txt", "r") as f:
    lines = f.readlines()

results = []
for line in lines:
    parts = line.strip().split()
    if len(parts) >= 8:
        filepath = parts[-1]
        # Tách các phần trong đường dẫn
        path_parts = filepath.strip("/").split("/")
        # print(f"Processing path: {path_parts}")  # Debugging line to see the path structure
        try:
            table = path_parts[3]  # ví dụ: f_ewallet_transaction
            # partition_folder = path_parts[5]  # ví dụ: partition=20250622
            # partition = partition_folder.split("=")[-1]
            results.append(table)
        except IndexError:
            continue  # Bỏ qua nếu dòng không đủ cấu trúc

check_tables = [
'f_ewallet_account',
'f_ewallet_account_right',
'f_ewallet_account_status_view',
'f_ewallet_action_log',
'f_ewallet_agent',
'f_ewallet_agent_location',
'f_ewallet_blacklist',
'f_ewallet_blacklist_bonus_deposit',
'f_ewallet_bonus_data_log',
'f_ewallet_change_state_action',
'f_ewallet_customer_register_temp',
'f_ewallet_enquiry_action',
'f_ewallet_log_account_audit',
'f_ewallet_log_agent_transaction_detail',
'f_ewallet_log_bonus_deposit',
'f_ewallet_log_buy_package',
'f_ewallet_log_emoney_flow_by_trans_type',
'f_ewallet_log_finish_transfer',
'f_ewallet_log_money_gram',
'f_ewallet_log_trans_commission',
'f_ewallet_log_trans_revenue',
'f_ewallet_log_trans_summary_by_range',
'f_ewallet_mssi_cus_infor',
'f_ewallet_mssi_cus_infor_payment',
'f_ewallet_mt_his',
'f_ewallet_party',
'f_ewallet_party_role',
'f_ewallet_plan_business_report',
'f_ewallet_reconcile_report_lotto',
'f_ewallet_register_action',
'f_ewallet_request_pos',
'f_ewallet_tariff_plan_specific',
'f_ewallet_trans_accounting',
'f_ewallet_trans_cash',
'f_ewallet_trans_finance',
'f_ewallet_trans_log',
'f_ewallet_trans_merchant',
'f_ewallet_trans_step',
'f_ewallet_trans_vpg',
'f_ewallet_transaction',
'f_ewallet_transaction_fact_daily',
'f_ewallet_log_master_account_audit'
]

result = list(set(results))  # Lấy các giá trị duy nhất
not_sync_tables = [table for table in check_tables if table not in results]
print(not_sync_tables)
print(len(not_sync_tables))