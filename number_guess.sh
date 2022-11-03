#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=guessing_game -t --no-align -c"

# get username
echo "Enter your username:"
read USERNAME

USER_CHECK=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")

# check if user exists on database
if [[ -z $USER_CHECK ]]
then
  # if user not exist then add user
  echo -e "Welcome, $USERNAME! It looks like this is your first time here."
  ADD_USER=$($PSQL "INSERT INTO users(username, games_played) VALUES('$USERNAME', 0)")
else
  DB_USERNAME=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")

  echo -e "\nWelcome back, $DB_USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# generate random number between 1 and 1000
G_NUMBER=$(($RANDOM % 1000 + 1))
let COUNT=1

echo -e "Guess the secret number between 1 and 1000:"
read USER_INPUT

until [ $USER_INPUT -eq $G_NUMBER ];
do
  # verifiy if user input is integer
  while [ $((USER_INPUT)) != $USER_INPUT ];
  do
    echo "That is not an integer, guess again:"
    read USER_INPUT
    let COUNT++
  done

  while [ $USER_INPUT -gt $G_NUMBER ];
  do
    echo "It's lower than that, guess again:"
    read USER_INPUT
    let COUNT++
  done

  while [ $USER_INPUT -lt $G_NUMBER ];
  do
    echo "It's higher than that, guess again:"
    read USER_INPUT
    let COUNT++
  done
done

echo -e "You guessed it in $COUNT tries. The secret number was $G_NUMBER. Nice job!"

# update user guessing game data
INCREMENT_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played=games_played+1 WHERE username='$USERNAME'")
UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game=$COUNT WHERE username='$USERNAME' AND (best_game>$COUNT OR best_game ISNULL)")
