#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$( echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

# echo "Please enter DB password:"
# read mysql_root_password

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
    echo "Please run this script with root access"
    exit 1
else
    echo "You are super user"
fi

dnf install mysql-server -y &>>$LOGFILE
VALIDATE $? "Installing MySQL Server"
systemctl enable mysqld &>>$LOGFILE
VALIDATE $? "Enableing MySQL Server"
systemctl start mysqld &>>$LOGFILE
VALIDATE $? "Starting MySQl Server"



#  mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
#  VALIDATE $? "Setting up root password"

#Below code will be useful for idempotent nature
mysql -h db.crn503.online -uroot -pExpenseApp@1 -e 'show databases;' &>>$LOGFILE

if [ $? -ne 0 ]
then 
    mysql_secure_installation --set-root-pass ExpenseApp@1} &>>$LOGFILE
    VALIDATE $? "MySQL Root Password setup"
else
    echo -e "MYSQL Root Paasword is alreday setup..$Y SKIPPING $N"
fi        