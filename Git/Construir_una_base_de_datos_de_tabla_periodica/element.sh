#!/bin/bash

# Variable para ejecutar comandos en PSQL
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Comprobar si se pasó un argumento
if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
else
  # Determinar si el argumento es un número (atomic_number) o un texto (symbol o name)
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    ELEMENT_INFO=$($PSQL "SELECT atomic_number, name, symbol, types.type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements JOIN properties USING(atomic_number) JOIN types USING(type_id) WHERE atomic_number = $1")
  else
    ELEMENT_INFO=$($PSQL "SELECT atomic_number, name, symbol, types.type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements JOIN properties USING(atomic_number) JOIN types USING(type_id) WHERE symbol = '$1' OR name = '$1'")
  fi

  # Comprobar si la consulta devolvió resultados
  if [[ -z $ELEMENT_INFO ]]
  then
    echo "I could not find that element in the database."
  else
    # Parsear los resultados y mostrar el mensaje formateado
    echo "$ELEMENT_INFO" | while IFS="|" read ATOMIC_NUMBER NAME SYMBOL TYPE MASS MELTING BOILING
    do
      echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
    done
  fi
fi
# Comentario para commit feat
# Comentario para commit fix
# Comentario para commit refactor
# Comentario para commit chore
