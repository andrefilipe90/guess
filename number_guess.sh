#!/bin/bash
PSQL="psql -U freecodecamp -d number_guess -t -X -c"

read -p "Enter your username:" USER_NAME
#while #username -gt 22 long
while [[ ${#USER_NAME} -gt 22 ]]
do
  #echo and read username
  read -p "Enter your username:" USER_NAME
done

# query for user name in users
QUERY_NAME=$($PSQL "SELECT user_id FROM users WHERE name = '$USER_NAME';")
echo $QUERY_NAME
# if -z 
  #insert table user input with name
  #echo Welcome fist time
# else
  #query inner join 
  #echo welcomeback

# query for user_id
# insert table numbers with random number and user_id

#Guess the secret number between 1 and 1000:

#while try diferent random
  #if gt 
    #its higher
  #elif lt
    #its lower
  #elif ==
    #you guessed
  #else
    #that is not a integer