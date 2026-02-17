#!/bin/bash

INSTANCE_INFO="/shell-practice/instances_53recordsinfo.txt"
FILE="/shell-practice/instance_name.txt"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


USER_SERVICE="/shell-practice/roboshop_shell/user.service"

for instance in $(cat $FILE)
do

#  ${instance}_privateIP=$(awk -v inst="$instance" '$1==inst {print $2}' "$INSTANCE_INFO")
#  ${instance}_publicIP=$(awk -v inst="$instance" '$1==inst {print $3}' "$INSTANCE_INFO")
#  ${instance}_dnsNAME=$(awk -v inst="$instance" '$1==inst {print $4}' "$INSTANCE_INFO")

if [ "$instance" == "mongodb" ]; then 
public_ip=$(awk -v inst="$instance" '$1==inst {print $3}' "$INSTANCE_INFO")

ssh  root@$public_ip << 'EOF'
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
public_ip=$(awk -v inst="$instance" '$1==inst {print $3}' "$INSTANCE_INFO")
ssh  root@$public_ip << 'EOF'
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

if [ "$instance" == "user" ]; then 
public_ip=$(awk -v inst="$instance" '$1==inst {print $3}' "$INSTANCE_INFO")
ssh  root@$public_ip << 'EOF'
VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N" 
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N" 
    fi
}

dnf module disable nodejs -y
VALIDATE $? "module disable $instance "

dnf module enable nodejs:20 -y
VALIDATE $? "module enable $instance "

dnf install nodejs -y
VALIDATE $? "install nodejs $instance "

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
VALIDATE $? "system user added for $instance "

mkdir /app 
VALIDATE $? "Created dire in $instance "

curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip
VALIDATE $? "Downloaded code file for $instance "

cp /tmp/user.zip /app/user.zip
VALIDATE $? "Copying of user.file for $instance "

unzip /app/tmp/user.zip
VALIDATE $? "Unzipped code file for $instance "

/app/npm install
VALIDATE $? "Installed dependinces $instance "

cp $USER_SERVICE /etc/systemd/system/
VALIDATE $? "copyed user.service file for $instance "

sed -i /s/<REDIS-IP-ADDRESS>/redis.krishnakalyan.online/ /etc/systemd/system/user.service
sed -i /s/<MONGODB-SERVER-IP-ADDRESS>/mongodb.krishnakalyan.online/ /etc/systemd/system/user.service
VALIDATE $? "updated user.service file with DNS records for $instance "

systemctl daemon-reload
VALIDATE $? "daemon-reload $instance "

systemctl enable user
VALIDATE $? "enable user for $instance "

systemctl start user
VALIDATE $? "start server of  $instance "

VALIDATE $? "************ SUCCESSFULLY CONFUGURED "$instance"*****************************"

EOF

 fi

done