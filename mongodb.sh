#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"

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

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "copied MongoDB REPO"

dnf install mongodb-org -y &>> $LOGFILE

VALIDATE $? "Instaling MongoDB"

systemctl enable mongod

VALIDATE $? "Enabling MongoDB"

systemctl start mongod

VALIDATE $? "Starting MongoDB"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOGFILE

VALIDATE $? "Remote Access to MongoDB"

systemctl restart mongod &>> $LOGFILE

VALIDATE $? "Restarting MongoDB"

