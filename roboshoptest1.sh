#!/bin/bash
USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
INSTANCE_INFO="instances_53recordsinfo.txt"

if [ $USERID -ne 0 ]; then
    echo -e "$R Please run this script with root user access $N" | tee -a $LOGS_FILE
    exit 1
fi

mkdir -p $LOGS_FOLDER

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N" | tee -a $LOGS_FILE
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N" | tee -a $LOGS_FILE
    fi
}

if [ "$instance" == "mongodb" ]; then 
mongoprivate_ip=$(awk '$1=="mongodb" {print $2}' "$INSTANCE_INFO")
mongopublic_ip=$(awk '$1=="mongodb" {print $3}' "$INSTANCE_INFO")
mongodns_name=$(awk '$1=="mongodb" {print $4}' "$INSTANCE_INFO")

ssh $mongoprivate_ip <<EOF
VALIDATE $? "Lonin to mongodb"

sudo su -
$pwd

git clone https://github.com/krishnakalyan-k/shell-practice.git

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

else 
echo "mongodb details not found in the file"
fi
