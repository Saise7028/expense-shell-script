#!/bin/bash

LOGS_FOLDER="/var/log/expense"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE="$LOGS_FOLDER/$SCIPT_NAME-$TIMESTAMP.log"
mkdir -p $LOGS_FOLDER

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

CHECK_ROOT(){
    if [ $USERID -ne 0 ]
      then
           echo -e "$R Please run the script with root Priveleges $N" | tee -a $LOG_FILE
           exit 1
    fi       
}

VALIDATE(){
    if [ $1 -ne 0 ]
      then
          echo -e "$2 is... $R Failed $N" | tee -a $LOG_FILE
          exit 1
      else
          echo -e "$2 is... $G Success $N" | tee -a $LOG_FILE
    fi          
}

echo "started script executing date: $(date)" | tee -a $LOG_FILE 

CHECK_ROOT

dnf list modules nodejs -y &>>$LOG_FILE
VALIDATE $? "list modules"

dnf module disable nodejs:18 -y &>>$LOG_FILE
VALIDATE $? "disable nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "enable nodejs"

dnf module install nodejs -y | tee -a $LOG_FILE
VALIDATE $? "install nodejs"

id expense &>>$LOG_FILE
   if [ $? -ne 0 ]
     then
         echo "user is not exisit, $G create user $N"
         useradd expense &>>$LOG_FILE
         VALIDATE $? "user creation"
     else
         echo "user is already exit, $Y SKIPPING $N"
    fi

# mkdir -p /app
# VALIDATE $? "create /app folder"

# curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE
# VALIDATE $? "Downloading backend application"

# cd /app
# rm -rf /app/* # removeing eisting code

# unzip /tmp/backend.zip &>>$LOG_FILE
# VALIDATE $? "Extracting the code"

# npm installation &>>$LOG_FILE
# cp /home/ec2-user/expense-shell-script/backend.service/etc/systemd/system/backend.service

# # installing mysql server before connecting backend server

# dnf install mysql -y &>>$LOG_FILE
# VALIDATE $? "installing mysql"

# mysql -h mysql.awsd81s.online -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$LOG_FILE
# VALIDATE $? "loading schema"

# systemctl daemon-reload &>>$LOG_FILE
# VALIDATE $? "daemon-reloading"

# systemctl enable backend &>>$LOG_FILE
# VALIDATE $? "enabling backend"

# systemctl restart backend &>>$LOG_FILE
# VALIDATE $? "restarted backend"