#!/bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Truncate tables to start fresh
$PSQL "TRUNCATE TABLE games, teams CASCADE;"

# First pass: Insert unique teams from CSV
tail -n +2 games.csv | while IFS=',' read year round winner opponent winner_goals opponent_goals
do
  # Insert winner team (ON CONFLICT avoids duplicates)
  $PSQL "INSERT INTO teams(name) VALUES('$winner') ON CONFLICT(name) DO NOTHING;"
  
  # Insert opponent team (ON CONFLICT avoids duplicates)
  $PSQL "INSERT INTO teams(name) VALUES('$opponent') ON CONFLICT(name) DO NOTHING;"
done

# Second pass: Insert games with correct team IDs using subqueries
tail -n +2 games.csv | while IFS=',' read year round winner opponent winner_goals opponent_goals
do
  # Insert game with subqueries to get team IDs
  $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($year, '$round', (SELECT team_id FROM teams WHERE name='$winner'), (SELECT team_id FROM teams WHERE name='$opponent'), $winner_goals, $opponent_goals);"
done