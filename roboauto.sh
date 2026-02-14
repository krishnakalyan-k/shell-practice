#!/bin/bash
USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

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

cp mongoDB_verinfo.txt /etc/yum.repos.d/mongo.repo
VALIDATE $1 "copying of mongodb verinfo file"

dnf install mongodb-org -y 
VALIDATE $1 "installation of mongodb"

systemctl enable mongod 
VALIDATE $1 "enable mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $1 "Edited momgodb cfg file"

systemctl start mongod
VALIDATE $1 "MongoDB services started"

echo "Started Working on MYSQL DB Installation********************************************"

dnf install mysql-server -y
VALIDATE $1 "Installation of mysqlDB"

systemctl enable mysqld
VALIDATE $1 "enable mysqld"

systemctl start mysqld
VALIDATE $1 "start mysqld"

mysql_secure_installation --set-root-pass RoboShop@1
VALIDATE $1 "ROOT password setting"

echo "Started Working on Redis DB Installation********************************************"

dnf module disable redis -y
VALIDATE $1 "module disable"

dnf module enable redis:7 -y
VALIDATE $1 "module enable"

dnf install redis -y 
VALIDATE $1 "install redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf
VALIDATE $1 "changed the cfg file"

systemctl enable redis 
VALIDATE $1 "enable redis"

systemctl start redis 
VALIDATE $1 "start redis"

echo "Started Working on RabbitMQ DB Installation********************************************"

cp rabbitmq.txt /etc/yum.repos.d/rabbitmq.repo
VALIDATE $1 "Copying of repo"

dnf install rabbitmq-server -y
VALIDATE $1 "install rabbitmq"

systemctl enable rabbitmq-server
VALIDATE $1 "enable rabbitmq"

systemctl start rabbitmq-server
VALIDATE $1 "start rabbitmq"

rabbitmqctl add_user roboshop roboshop123
VALIDATE $1 "add_user roboshop"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
VALIDATE $1 "set_permissions"