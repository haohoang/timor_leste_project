#!/bin/bash

# Thư mục gốc trong HDFS
parent_dir="/raw_zone/ewallet/TRANSACTION"

# Liệt kê tất cả thư mục (tên dạng yyyyMMdd)
folders=$(hdfs dfs -ls $parent_dir | grep '^[d]' | awk '{print $8}' | sort)

# Lặp qua từng thư mục
for folder in $folders; do
    # Lấy tên thư mục (yyyyMMdd)
    folder_name=$(basename $folder)
    
    # Tính toán ngày mới (dời 1 ngày)
    new_folder_name=$(date -d "$folder_name"'- 1 day' '+%Y%m%d')
    
    # Đổi tên thư mục trong HDFS
    hdfs dfs -mv "$parent_dir/$folder_name" "$parent_dir/$new_folder_name"
    
    echo "Renamed $folder_name to $new_folder_name"
done
