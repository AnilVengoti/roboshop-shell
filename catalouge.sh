#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m'
N="\e[0m"
MONGODB_HOST=mongodb.daws79.cloud

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script started executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0]
    then 
        echo -e "$2.... $R FAILED $N"
    else 
        echo -e "$2 ... $G SUCCESS $N"
    fi
}


if [ $ID -ne 0 ]
then 
    echo "ERROR:: Please run this script with root access"
    exit 1 # you can give other than 0
else 
    echo "You are root user"
fi

dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "Disabling current NodeJS"

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "Enabling NODEJS:18"

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? "Installing NodeJS:18" 

useradd roboshop &>> $LOGFILE

VALIDATE $? "creating roboshop user"

mkdir /app

VALIDATE $? "creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE
VALIDATE $? "Downloading catalouge application"

cd /app

unzip /tmp/catalogue.zip &>> $LOGFILE

VALIDATE $? "unziping catalogue"

npm install &>> $LOGFILE

VALIDATE $? "Installing dependencies"

#use absolute path beacuse catalouge.service exists there  
cp /home/centos/roboshop-shell/catalouge.service /etc/systemd/system/catalouge.service

VALIDATE $? "copying catalouge service file"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "catalouge daemon-reload"

systemctl enable catalouge &>> $LOGFILE

VALIDATE $? "Enable catalouge"

systemctl start catalogue &>> $LOGFILE

VALIDATE $? "Starting catalouge"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo

VALIDATE $? "copying mongodb repo"

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "Installing MongoDB client"

mongo --host $MONGODB_HOST </app/schema/catalogue.js 

VALIDATE $? "Loading catalouge data into MongoDB"