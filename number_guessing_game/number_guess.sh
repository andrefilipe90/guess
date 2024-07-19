#!/bin/bash
PSQL="psql -U andrefilipe90 -d number_guess -t -X -c"

## USER NAME IMPUT AND TREATMENT FOR 23 OR LONGER
echo "Enter your username:"
read USER_NAME
while [[ ${#USER_NAME} -gt 22 ]]
do
  read -p "Enter your username:" USER_NAME
done

## USERS.NAME EXISTANCE VALIDATION, INSERTION AND GREETINGS
USER_NAME_CHECK=$($PSQL "SELECT name FROM users WHERE name = '$USER_NAME';")
if [[ -z $USER_NAME_CHECK ]]; then
  INSERT_NAME=$($PSQL "INSERT INTO users(name) VALUES('$USER_NAME');")
  echo "Welcome, $USER_NAME! It looks like this is your first time here."
else
  QUERY_USER_DATA=$($PSQL "SELECT total_games, best_game FROM users INNER JOIN numbers USING(user_id) WHERE name = '$USER_NAME';")
  echo $QUERY_USER_DATA | while read TOTAL_GAMES BAR BEST_GAME
  do
    echo "Welcome back, $USER_NAME! You have played $TOTAL_GAMES games, and your best game took $BEST_GAME guesses."
  done
fi

## NUMBERS.USER_ID VALIDATION, INSERTION AND RANDOM GENERATION OF GUESSING NUMBER
USER_ID=$($PSQL "SELECT user_id FROM users WHERE name = '$USER_NAME';")
UID_IN_NUMBERS=$($PSQL "SELECT user_id FROM numbers WHERE user_id = $USER_ID;")
if [[ -z $UID_IN_NUMBERS ]]; then
  INSERT_USER_ID=$($PSQL "INSERT INTO numbers(user_id) VALUES($USER_ID);")
else
  INSERT_RANDOM=$($PSQL "UPDATE numbers SET random = $(( (RANDOM % 1000 ) + 1 )) WHERE user_id = $USER_ID;")
fi

## FIRST ATTEMPT AND TOTAL GAMES UPDATE
echo "Guess the secret number between 1 and 1000:"
read GUESS
AMOUNT_GUESSED=1
RANDOM_DB=$($PSQL "SELECT random FROM numbers WHERE user_id = $USER_ID;")
TOTAL_GAMES_DB=$($PSQL "SELECT total_games FROM numbers WHERE user_id = '$USER_ID';")
UPDATE_TOTAL_TRY=$($PSQL "UPDATE numbers SET total_games = $(( $TOTAL_GAMES_DB + 1 )) WHERE user_id = $USER_ID;")


## WHILE NO RIGHT GUESS, VALIDATE FOR LOWER, HIGHER OR NOT A INTEGER
while [[ $GUESS -ne $RANDOM_DB ]]
do
  if [[ ! $GUESS =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    read GUESS
  elif [[ $GUESS -lt $RANDOM_DB ]]; then
    echo "It's higher than that, guess again:"
    read GUESS
  elif [[ $GUESS -gt $RANDOM_DB ]]; then
    echo "It's lower than that, guess again:"
    read GUESS
  else
    break
  fi
  (( AMOUNT_GUESSED++ ))
done

## AFTER THE WHILE LOOP NEED TO UPDATE AMOUNT_GUESSED IN DB USING A IF == TEST FOR RANDOM_DB AND GUESS
if [[ $GUESS -eq $RANDOM_DB ]]; then
  UPDATE_BEST_GAME=$($PSQL "UPDATE numbers SET best_game = $AMOUNT_GUESSED WHERE user_id = $USER_ID;")
  echo "You guessed it in $AMOUNT_GUESSED tries. The secret number was"$RANDOM_DB". Nice job!"
fi
