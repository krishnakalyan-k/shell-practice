#!/bin/bash

SG_ID="sg-0b9e5f45b94d933fa" # replace with your ID
AMI_ID="ami-0220d79f3f480ecf5"
ZONE_ID="Z05013202FKF0ZL12WAOP"
DOMAIN_NAME="daws88s.online"

for instance in $@
do
    INSTANCE_ID=$( aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type "t3.micro" \
    --security-group-ids $SG_ID \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
    --query 'Instances[0].InstanceId' \
    --output text )
    done

    echo "$INSTANCE_ID"