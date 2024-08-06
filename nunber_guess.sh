#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

ASK_USER() {
echo "Enter your username:"
read USERNAME

NAME=$(echo $USERNAME | wc -c)
if [[ $NAME -gt 22 ]]
then
  echo "Invalid username. Username must have 22 characters at maximum. Run script again."
  exit
fi
}

ASK_USER

GUESS_GAME() {
  SECRET_NUMBER=$((RANDOM % 1000 + 1))
  echo "Guess the secret number between 1 and 1000:"
  read GUESS

  #Verification the input is a positive integer
  re='^[0-9]+$'
  while ! [[ $GUESS =~ $re ]]
  do
    echo "That is not an integer, guess again:"
    read GUESS
  done

  #Number of valid guesses 
  NUMBER_OF_GUESSES=1
  #Loop tests until the number has been guessed
  while [[ $GUESS -ne $SECRET_NUMBER ]]
  do
    if [[ $SECRET_NUMBER -lt GUESS ]]
    then
      echo "It's lower than that, guess again:"
      read GUESS
    else
      echo "It's higher than that, guess again:"
      read GUESS
    fi
    ((NUMBER_OF_GUESSES++))
  done
  
}

PLAY_AGAIN() {
  if [[ $ANSWER == "yes" ]]; then
    GUESS_GAME

  INSERTED_GAME=$($PSQL "INSERT INTO games(guesses,u_id) VALUES ('$GUESS', $USER_ID)")  
  echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
  
  elif [[ $ANSWER == "not" ]]; then
    echo -e "\nThank's for visiting us"
  else
    echo -e "\nWrong answer, you need answer 'yes' or 'not'. Run script again."
    exit
   fi
}

#Check if USERNAME exists
USER_ID=$($PSQL "SELECT u_id FROM users WHERE name='$USERNAME'")

#If not empty
if [[ -n $USER_ID ]]
then

  G_PLAYED=$($PSQL "SELECT COUNT(*) FROM users u JOIN games g ON u.u_id=g.u_id WHERE u.name='$USERNAME'")

  BEST_GAMES=$($PSQL "SELECT MIN(g.guesses) AS min_guesses FROM users u JOIN games g ON u.u_id=g.u_id WHERE u.name='$USERNAME'")
  
  echo -e "\nWelcome back, $USERNAME! You have played $G_PLAYED games, and your best game took $BEST_GAMES guesses."

  echo -e "\nDo you want to play again? Answer yes or not."
  read ANSWER
  
  PLAY_AGAIN

#If empty
else
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."

  GUESS_GAME

  #Insert results
  INSERTED_NAME=$($PSQL "INSERT INTO users(name) VALUES('$USERNAME')")

  i_d=$($PSQL "SELECT U_id FROM users WHERE name='Joao' ORDER BY u_id DESC LIMIT 1")

  INSERTED_GAME=$($PSQL "INSERT INTO games(guesses,u_id) VALUES ('$GUESS', $i_d)")

  #Print results of the game
  echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
fi
