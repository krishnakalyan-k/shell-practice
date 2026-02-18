#!/bin/bash

INSTANCE_INFO="instances_53recordsinfo.txt"

FILE="instance_name.txt"

for instance in $(cat $FILE)
do
if [ "$instance" == "mongodb" ]; then 
mongoprivate_ip=$(awk '$1=="mongodb" {print $2}' "$INSTANCE_INFO")
mongopublic_ip=$(awk '$1=="mongodb" {print $3}' "$INSTANCE_INFO")
mongodns_name=$(awk '$1=="mongodb" {print $4}' "$INSTANCE_INFO")

ssh -T root@$mongopublic_ip << 'EOF'
VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N" | tee -a $LOGS_FILE
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N" | tee -a $LOGS_FILE
    fi
}

VALIDATE $? "Connected to MongoDB server"

rm -rf /shell-practice
rm -rf /etc/yum.repos.d/mongo.repo
rm -rf /etc/mongod.conf


git clone https://github.com/krishnakalyan-k/shell-practice.git
VALIDATE $? "git clone"
cp shell-practice/mongoDB_verinfo.txt /etc/yum.repos.d/mongo.repo
VALIDATE $? "copying of mongodb verinfo file"

dnf install mongodb-org -y 
VALIDATE $? "installation of mongodb"

systemctl enable mongod 
VALIDATE $? "enable mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Edited momgodb cfg file"

systemctl start mongod
VALIDATE $? "MongoDB services started"
EOF

fi
done