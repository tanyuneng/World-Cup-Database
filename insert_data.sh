#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
#Delete all rows in all tables
echo $($PSQL "TRUNCATE teams, games")

# read data file
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do

  # WINNER
  # get winner_id
  if [[ $WINNER != "winner" ]]
  then
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'" )

    # if not found
    if [[ -z $WINNER_ID ]]
    then 

      # insert winner team
      INSERT_WINNER_RESULT=$($PSQL"INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_WINNER_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $WINNER
      fi
  
    # get new winner_id
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
    fi

    #OPPONENT
    #get opponent_id
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")
  
    #if not found
    if [[ -z $OPPONENT_ID ]]
    then
      #insert team
      INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES ('$OPPONENT')")
      if [[ $INSERT_OPPONENT_RESULT == 'INSERT 0 1' ]]
      then
        echo Inserted into teams, $OPPONENT
      fi

      #get new team
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    fi

    # get game_id
    GAME_ID=$($PSQL"SELECT game_id FROM games WHERE round='$ROUND' AND winner_id = $WINNER_ID AND year = $YEAR")
    echo game id is $GAME_ID

    # if not found
    if [[ -z $GAME_ID ]]
    then

      # insert game
      INSERT_GAME_RESULT=$($PSQL"INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
      if [[ $INSERT_GAME_RESULT == 'INSERT 0 1' ]]
      then
        echo Inserted into games, $YEAR $ROUND
      fi
    fi
  fi
done