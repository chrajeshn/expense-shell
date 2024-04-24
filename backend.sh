#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$( echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log


R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo "Please enter DB password:"
read mysql_root_password


VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2...$R FAILURE $N"
        exit 1
    else 
        echo -e "$2...$G SUCCESS $N"
    fi        
}

if [ $USERID -ne 0 ]
then
    echo "Please run this script with root access."
    exit 1
else
    echo "You are super user"
fi   

dnf module disable nodejs -y &>>$LOGFILE
VALIDATE $? "Disabling Default nodejs"

dnf module enable nodejs:20 -y &>>$LOGFILE
VALIDATE $? "Enable nodejs"

dnf install nodejs -y &>>$LOGFILE
VALIDATE $? "Installing nodejs"

id expense &>>$LOGFILE

if [ $? -ne 0 ]
 then
     useradd expense &>>$LOGFILE
     VALIDATE $? "Creating expense user"
 else
     echo -e "Expense user alreday created... $Y SKIPPING $N"
fi

mkdir -p /app &>>$LOGFILE
VALIDATE $? "Creating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip
VALIDATE $? "Downloading Backend code"

cd /app
rm -rf /app/*
unzip /tmp/backend.zip
VALIDATE $? "Extracting backend code"

npm install &>>$LOGFILE
VALIDATE $? "Installing nodejs dependencise"

cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service &>>$LOGFILE
VALIDATE $? "Copied backend service"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "Daemon Reload"

systemctl start backend &>>$LOGFILE
VALIDATE $? "Start Backend"

systemctl enable backend &>>$LOGFILE
VALIDATE $? "Enable Backend"

dnf install mysql -y &>>$LOGFILE
VALIDATE $? "Installing MySQL Clien"

mysql -h db.crn503.online -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>$LOGFILE
VALIDATE $? "Schema Loading"

systemctl restart backend &>>$LOGFILE
VALIDATE $? "Restart Backend"




