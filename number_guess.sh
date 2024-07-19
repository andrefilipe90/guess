#!/bin/bash
PSQL="psql -U freecodecamp -d number_guess -t -X -c"

## USER NAME IMPUT AND TREATMENT
echo "Enter your username:"
read USER_NAME
#read -p "Enter your username:" USER_NAME
#while #username -gt 22 long
while [[ ${#USER_NAME} -gt 22 ]]
do
  #echo and read username
  read -p "Enter your username:" USER_NAME
done

## USER VALIDATION AND GREETINGS
# query for user name in users
$USER_NAME_CHECK=$($PSQL "SELECT name FROM users WHERE name = '$USER_NAME';")
# if -z
if [[ -z $USER_NAME_CHECK ]]; then
  #insert table user input with name
  INSERT_NAME=$($PSQL "INSERT INTO users(name) VALUES('$USER_NAME');")
  #echo Welcome fist time
  echo "Welcome, $USER_NAME! It looks like this is your first time here."
# else
else
  #query inner join
  QUERY_USER_DATA=$($PSQL "SELECT total_games, best_game FROM users INNER JOIN numbers USING(user_id) WHERE name = '$USER_NAME';")
  #echo welcomeback
  echo $QUERY_USER_DATA | while read TOTAL_GAMES BAR BEST_GAME
  do
    echo "Welcome back, $USER_NAME! You have played $TOTAL_GAMES games, and your best game took $BEST_GAME guesses."
  done
fi

## RANDOM GENERATION OF GUESSING NUMBER
# query for user_id on users and number table
USER_ID=$($PSQL "SELECT user_id FROM users WHERE name = '$USER_NAME';")
CHECK_NUMBERS=$($PSQL "SELECT user_id FROM numbers WHERE user_id = $USER_ID;")
# validate for numbers register
if [[ -z $CHECK_NUMBERS ]]; then
  # insert table numbers with random number and user_id
  INSERT_USER_ID=$($PSQL "INSERT INTO numbers(user_id,total_try) VALUES($USER_ID,0);")
else
  RANDOM_NUM=$((RANDOM % 1000 ))
  echo $RANDOM_NUM
  INSERT_RANDOM=$($PSQL "UPDATE numbers SET random = $RANDOM_NUM WHERE user_id = $USER_ID;")
fi

#Guess the secret number between 1 and 1000:
echo "Guess the secret number between 1 and 1000:"

## GUESSING LOOP
read GUESS
AMOUNT_TRY=1
RANDOM_DB=$($PSQL "SELECT random FROM numbers WHERE user_id = $USER_ID;")
QUERY_FOR_UPDATE=$($PSQL "SELECT total_games, best_game FROM numbers WHERE user_id = '$USER_ID';")
#update total games
echo $QUERY_FOR_UPDATE | while read TOTAL_GAMES BAR BEST_GAME
do
  NEW_TOTAL=$(( $TOTAL_GAMES + 1 ))
  UPDATE_TOTAL_TRY=$($PSQL "UPDATE numbers SET total_games = $NEW_TOTAL WHERE user_id = $USER_ID;")
done
#while try diferent random
while [[ $GUESS != $RANDOM_DB ]]
do
  if [[ $GUESS -lt $RANDOM_DB ]]; then
    #its higher read try
    echo "It's higher than that, guess again:"
    read GUESS
  elif [[ $GUESS -gt $RANDOM_DB ]]; then
    #its lower read try
    echo "It's lower than that, guess again:"
    read GUESS
  elif [[ $GUESS != ^[0-9]+$ ]]; then
    #that is not a integer
    echo "That is not an integer, guess again:"
  else
    break
  fi
  (( AMOUNT_TRY++ ))
  #update database-try
done

#query best game
echo $QUERY_FOR_UPDATE | while read TOTAL_GAMES BAR BEST_GAME
  do
    #update best game if lt new amount_try
    if [[ $AMOUNT_TRY -lt $BEST_GAME ]]; then
      UPDATE_BEST_GAME=$($PSQL "UPDATE numbers SET best_game = $AMOUNT_TRY WHERE user_id = $USER_ID;")
  done
#you guessed
    SUCCESS=$($PSQL "SELECT total_try FROM numbers WHERE user_id = $USER_ID;")
    echo "You guessed it in $SUCCESS tries. The secret number was $RANDOM_DB. Nice job!"
#if [[ $GUESS =~ $TRY_GUESS ]]; then
#  SUCCESS=$($PSQL "SELECT total_try FROM numbers WHERE user_id = $USER_ID;")
#  echo "You guessed it in $SUCCESS tries. The secret number was $TRY_GUESS. Nice job!"
#fi