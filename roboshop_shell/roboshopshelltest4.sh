#!/bin/bash

INSTANCE_INFO="/shell-practice/instances_53recordsinfo.txt"
FILE="/shell-practice/instance_name.txt"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

eval "${instance}_privateIP=$(awk -v inst="$instance" '$1==inst {print $2}' "$INSTANCE_INFO")"
eval "${instance}_publicIP=$(awk -v inst="$instance" '$1==inst {print $3}' "$INSTANCE_INFO")"
eval "${instance}_dnsNAME=$(awk -v inst="$instance" '$1==inst {print $4}' "$INSTANCE_INFO")"


for instance in $(cat $FILE)
do
if [ "$instance" == "mongodb" ]; then 

ssh  root@${instance}_publicIP << 'EOF'
VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N" | tee -a $LOGS_FILE
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N" | tee -a $LOGS_FILE
    fi
}

VALIDATE $? "Connected to MongoDB server"

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

VALIDATE $? "************ SUCCESSFULLY CONFUGURED MONGODB*****************************"
EOF

fi

if [ "$instance" == "mysql" ]; then 

ssh  root@${instance}_publicIP << 'EOF'
VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N" | tee -a $LOGS_FILE
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N" | tee -a $LOGS_FILE
    fi
}

VALIDATE $? "Connected to $instance server"

dnf install mysql-server -y
VALIDATE $? "Installation of mysqlDB"

systemctl enable mysqld
VALIDATE $? "enable mysqld"

systemctl start mysqld
VALIDATE $? "start mysqld"

mysql_secure_installation --set-root-pass RoboShop@1
VALIDATE $? "ROOT password setting"

VALIDATE $? "************ SUCCESSFULLY CONFUGURED "$instance"*****************************"
EOF

fi
done