#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
# $PSQL "truncate table customers,appointments"
MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  SERVICES=$($PSQL "select * from services order by service_id")
  echo "$SERVICES" | sed 's/|/) /g'
  read SERVICE_ID_SELECTED
  CHECK_OPTION $SERVICE_ID_SELECTED
}
CHECK_OPTION()
{
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    SERVICE_ID_SELECTED_NAME=$($PSQL "select name from services where service_id=$1")
    if [[ -z $SERVICE_ID_SELECTED_NAME ]]
    then
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      PHONE_CHECK $1 $SERVICE_ID_SELECTED_NAME
    fi
  else
    MAIN_MENU "Please enter a number. What would you like today?"
  fi

}
PHONE_CHECK()
{
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_NAME_RESULT=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE' ")
  if [[ -z $CUSTOMER_NAME_RESULT ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    INSERT_NAME_RESULT=$($PSQL "insert into customers(name,phone) values('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
    APPOINTMENT $1 $2 $CUSTOMER_NAME
  else
    APPOINTMENT $1 $2 $CUSTOMER_NAME_RESULT
  fi
}
APPOINTMENT()
{
  echo -e "\nWhat time would you like your $2, $3?"
  read SERVICE_TIME
  CUSTOMER_ID=$($PSQL "select customer_id from customers where name='$3' ")
  APPOINTMENT_INSERT_RESULT=$($PSQL "insert into appointments(service_id,customer_id,time) values($1,$CUSTOMER_ID,'$SERVICE_TIME')")
  echo -e "\nI have put you down for a $2 at $SERVICE_TIME, $3."
}
MAIN_MENU "Welcome to My Salon, how can I help you?"
