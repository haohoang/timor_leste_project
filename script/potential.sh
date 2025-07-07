#!/bin/bash

# Define Zeppelin server URL and credentials
ZEPP_HOST="http://10.226.39.96:9995"  # Change to your Zeppelin host
USERNAME="datascientist_4"
PASSWORD="Telemor@2025"
NOTE_ID="2KZ6JZJGQ"  
PARA_ID="20250626-153901_1632767906"  

# Step 1: Login to Zeppelin to get the JSESSIONID
echo "Logging into Zeppelin..."

RESPONSE=$(curl -s -i --data "userName=${USERNAME}&password=${PASSWORD}" -X POST "${ZEPP_HOST}/api/login" | grep -i 'Set-Cookie' | grep -o 'JSESSIONID=[^;]*' )

SESSION_COOKIE=$(echo "$RESPONSE" | grep -o 'JSESSIONID=[^;]*' | grep -v 'deleteMe' | tail -n 1 | sed 's/JSESSIONID=//')

echo $RESPONSE
# Check if login was successful by verifying JSESSIONID
if [ -z "$SESSION_COOKIE" ]; then
  echo "Login failed. No session cookie received."
  exit 1
else
  echo "Login successful. JSESSIONID: $SESSION_COOKIE"
fi

# Step 2: Trigger the paragraph in the notebook using the JSESSIONID
echo "Triggering the paragraph execution...${ZEPP_HOST}/api/notebook/run/${NOTE_ID}/${PARA_ID}"
RESPONSE=$(curl -i -b "JSESSIONID=$SESSION_COOKIE; Path=/; HttpOnly" \
  -X POST \
  -H "Content-Type: application/json" \
  "${ZEPP_HOST}/api/notebook/run/${NOTE_ID}/${PARA_ID}"  )

# Check if the paragraph was triggered successfully
if echo "$RESPONSE" | grep -q "HTTP/1.1 200 OK"; then
  echo "Paragraph triggered successfully!"
  exit 0 
else
  echo "Failed to trigger the paragraph."
  echo "Response: $RESPONSE"
  exit 1
fi


