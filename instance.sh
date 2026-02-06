#!/bin/bash

SG_ID="sg-0b9e5f45b94d933fa" # replace with your ID
AMI_ID="ami-0220d79f3f480ecf5"

INSTANCE_ID=$( aws ec2 run-instances --image-id $AMI_ID --count 1 --instance-type t3.micro --security-group-ids $SG_ID Tags=[{Key=DB,Value=DEMO}]--query 'Instances[0].InstanceId',',IP:PublicIpAddress' --output text)

if [ $? -eq 0 ]; then
echo "Instance created:) instanceID=$INSTANCE_ID"
echo "PrivateIP:) $IP"
else 
echo "Instance creation failed"
fi

