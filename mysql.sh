#!/bin/bash

# /var/log/expense<mysql.sh>-TIMESTAMP.log

LOGS_FOLDER="/var/log/expense"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log"
mkdir -p $LOGS_FOLDER

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

CHECK_ROOT(){
    if [ $USERID -ne 0 ]
      then
          echo -e "$R please run the script with root priveleges $N" | tee -a &$LOG_FILE
          exit 1
    fi      
}

VALIDATE(){
    if [ $1 -ne 0 ]
      then
          echo "$2 is... $R Failed $N" | tee -a &$LOG_FILE
          exit 1
      else
          echo "$2 is...$G Success $N" | tee -a &$LOG_FILE
    fi      
}

echo "script started executing at: $(date)"

CHECK_ROOT

dnf install mysql-server -y | tee -a &$LOG_FILE
VALIDATE $? "installing mysql server"

systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "enableing mysql server"

systemctl start mysqld &>>$LOG_FILE
VALIDATE $? "started mysql server"

mysql -h awsd81s.online -u root -p ExpenseApp@1 -e 'show databases;' &>>$LOG_FILE

if [ $? -ne 0 ]
   then
       echo "mysql root password is not setting.set up now" &>>$LOG_FILE
       mysql_secure_installation --root-set-pass ExpenseApp@1
       VALIDATE $? "setting up root pasword"
    else
        echo "mysql root password is already setup.. $Y Skipping $N" | tee -a &$LOG_FILE
    fi   
