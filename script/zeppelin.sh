curl -u datascientist_4:Telemor@2025 -X GET "http://10.226.39.96:9995/api/notebook/2KX424YZX/20250624-173132_278678366

spark-submit --master yarn --deploy-mode cluster --name my_spark_app \
--executor-memory 4g --driver-memory 2g \
potential_timing_data.py \
--conf spark.executor.cores=2 \
--conf spark.driver.cores=1

curl -u datascientist_4:"Telemor@2025" -X GET "http://10.226.39.96:9995/api/notebook/2KX424YZX/20250624-173132_278678366"


curl -u datascientist_4:"Telemor@2025" -X POST \
  -d '{"noteId": "2KX424YZX", "paragraphId": "20250624-173132_278678366", "params": {}}' \
  -H "Content-Type: application/json" \
  "http://10.226.39.96:9995/api/notebook/job"

curl \
  -X GET \
  "http://10.226.39.96:9995/api/notebook/paragraph/20250624-173132_278678366"


curl -u datascientist_4:"Telemor@2025" \
-X GET \
"http://10.226.39.96:9995/api/notebook"

curl -i --data 'userName=datascientist_4&password=Telemor@2025' -X POST -H "Content-Type: application/x-www-form-urlencoded" http://10.226.39.96:9995/api/login

curl -c cookies.txt -i --data 'userName=datascientist_4&password=Telemor@2025' -X POST http://10.226.39.96:9995/api/login

curl -i -b 'JSESSIONID=d8dd2e8f-c0a4-4f5d-9295-83e08e332d83; Path=/; HttpOnly' -X GET http://10.226.39.96:9995/api/notebook/2KX424YZX/paragraph/20250624-173132_278678366



curl -i -b 'JSESSIONID=d8dd2e8f-c0a4-4f5d-9295-83e08e332d83; Path=/; HttpOnly' \
  -X POST \
  -d '{"noteId": "2KX424YZX", "paragraphId": "20250624-173132_278678366", "params": {}}' \
  -H "Content-Type: application/json" http://10.226.39.96:9995/api/notebook/job/2KX424YZX/paragraph/20250624-173132_278678366

curl -i -b 'JSESSIONID=8363f123-3d84-445a-bb57-d80552c12310; Path=/; HttpOnly' \
-X POST \
-d '{"name": "Potential Leading", "params": {"backdate": "20250623"}}' \
-H "Content-Type: application/json" http://10.226.39.96:9995/api/notebook/run/2KX424YZX/20250624-173132_278678366

curl -i -b 'JSESSIONID=9aa0a7ef-fd38-4a81-b36a-576a26cc1092; Path=/; HttpOnly' \
-X POST \
-d '{"name": "Potential Leading", "params": {"backdate": "20250621"}}' \
-H "Content-Type: application/json" http://10.226.39.96:9995/api/notebook/run/2KX424YZX/20250624-173132_278678366




14578000-0b4d-41bb-848b-d37026991d83
curl -i -b 'JSESSIONID=9aa0a7ef-fd38-4a81-b36a-576a26cc1092; Path=/; HttpOnly' \
-X POST \
-d '{"name": "Potential Leading", "params": {"backdate": "20250621"}}' \
-H "Content-Type: application/json" http://10.226.39.96:9995/api/notebook/run/2KX424YZX/20250624-173132_278678366

curl -b cookies.txt http://ip_address:port/api/notebook

curl -i -b cookies.txt \
  -X POST \
  -H "Content-Type: application/json" \
  "${ZEPP_HOST}/api/notebook/run/${NOTE_ID}/${PARA_ID}"



