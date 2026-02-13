#!/bin/bash

SG_ID="sg-0b9e5f45b94d933fa" # replace with your ID
AMI_ID="ami-0220d79f3f480ecf5"
FILE="instance_name.txt"

for instance in $(cat $FILE)

do

INSTANCE_ID=$( aws ec2 run-instances --image-id $AMI_ID --count 1 --instance-type t3.micro --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Instances[0].InstanceId' --output text)

if [ $? -eq 0 ]; then
echo "Instance created:) instanceID=$INSTANCE_ID"
else 
echo "Instance creation failed"

fi

if [ "$instance" == "frontend" ]; then

publicIP=$( aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
echo "$instance PUBLIC_IP:) $publicIP"

else
 privateIP=$( aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
echo "$instance PRIVATE_IP:) $privateIP"

fi 

if [ "$instance" != "frontend" ]; then

aws route53 change-resource-record-sets \
--hosted-zone-id Z02527032EZS54C6SX6MK \
--change-batch '{
  "Changes": [{
    "Action": "CREATE",
    "ResourceRecordSet": {
      "Name": "$instance.krishnakalyan.online",
      "Type": "A",
      "TTL": 1,
      "ResourceRecords": [{"Value": "privateIP"}]
    }
  }]
}'

else
 aws route53 change-resource-record-sets \
--hosted-zone-id Z02527032EZS54C6SX6MK \
--change-batch '{
  "Changes": [{
    "Action": "CREATE",
    "ResourceRecordSet": {
      "Name": "$instance.krishnakalyan.online",
      "Type": "A",
      "TTL": 1,
      "ResourceRecords": [{"Value": "publicIP"}]
    }
  }]
}'
if 

aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=running" \
  --query 'Reservations[].Instances[].{
    Name: Tags[?Key==`Name`].Value | [0],
    PublicIP: PublicIpAddress,
    PrivateIP: PrivateIpAddress
  }' \
--output text | while read NAME PUB PRIV
do
    DNS=$(aws route53 list-resource-record-sets \
        --hosted-zone-id $ZONE_ID \
        --query "ResourceRecordSets[?ResourceRecords[?Value=='$PUB']].Name" \
        --output text)

    echo "$NAME | $PRIV | $PUB | $DNS"
done