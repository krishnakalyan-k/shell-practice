#!/bin/bash
INSTANCE_INFO="instances_53recordsinfo.txt"
FILE="instance_name.txt"

for instance in $(cat $FILE)
do
if [ "$instance" == "mongodb" ]; then 
mongoprivate_ip=$(awk '$1=="mongodb" {print $2}' "$INSTANCE_INFO")
mongopublic_ip=$(awk '$1=="mongodb" {print $3}' "$INSTANCE_INFO")
mongodns_name=$(awk '$1=="mongodb" {print $4}' "$INSTANCE_INFO")

ssh -T root@"$mongopublic_ip" <<EOF
VALIDATE(){
    if [ "\$1" -ne 0 ]; then
        echo -e "\$2 ... FAILURE" | tee -a \$LOGS_FILE
        exit 1
    else
        echo -e "\$2 ... SUCCESS" | tee -a \$LOGS_FILE
    fi
}

echo "Connected to mongodb server"
VALIDATE \$? "Connected to $instance server"

rm -rf /root/shell-practice
rm -rf /etc/yum.repos.d/mongo.repo
dnf remove mongodb-org -y

git clone https://github.com/krishnakalyan-k/shell-practice.git
VALIDATE \$? "git clone"

cp shell-practice/mongoDB_verinfo.txt /etc/yum.repos.d/mongo.repo
VALIDATE \$? "copy $instance repo"

dnf install mongodb-org -y 
VALIDATE \$? "$instance installation"

systemctl enable mongod 
VALIDATE \$? "enable $instance"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE \$? "config update"

systemctl start mongod
VALIDATE \$? "$instance started"
EOF

fi
done