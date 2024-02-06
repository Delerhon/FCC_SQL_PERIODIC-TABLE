#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t -c"

EXIT_MESSAGE_NO_DATA="I could not find that element in the database."

EXIT_ON_BAD_ARG_INPUT () {
  echo $EXIT_MESSAGE_NO_DATA
  exit
}

CHECK_IF_DATA_WAS_FOUND_AND_EXIT () {
  if [[ -z $ELEMENT ]]
  then
    EXIT_ON_BAD_ARG_INPUT
  fi
}

# no Argument given
if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
  exit
fi

# find out, what how the element is given

if [[ $1 =~ ^[0-9]+$ ]]
then
  ELEMENT=$($PSQL "SELECT elements.atomic_number, name, symbol, atomic_mass, melting_point_celsius, boiling_point_celsius, types.type FROM properties LEFT JOIN types ON types.type_id = properties.type_id LEFT JOIN elements ON elements.atomic_number = properties.atomic_number WHERE elements.atomic_number = $1")
  CHECK_IF_DATA_WAS_FOUND_AND_EXIT
elif [[ $1 =~ ^[a-zA-Z][a-zA-Z]$ ]] || [[ $1 =~ ^[a-zA-Z]$ ]]
then
  ELEMENT=$($PSQL "SELECT elements.atomic_number, name, symbol, atomic_mass, melting_point_celsius, boiling_point_celsius, types.type FROM properties LEFT JOIN types ON types.type_id = properties.type_id LEFT JOIN elements ON elements.atomic_number = properties.atomic_number WHERE symbol = '${1^}'")
  CHECK_IF_DATA_WAS_FOUND_AND_EXIT
elif [[ $1 =~ ^[a-zA-Z]+$ ]] && [ ${#1} -gt 2 ]
then
  ELEMENT=$($PSQL "SELECT elements.atomic_number, name, symbol, atomic_mass, melting_point_celsius, boiling_point_celsius, types.type FROM properties LEFT JOIN types ON types.type_id = properties.type_id LEFT JOIN elements ON elements.atomic_number = properties.atomic_number WHERE name = '$1'")
  CHECK_IF_DATA_WAS_FOUND_AND_EXIT
else
  EXIT_ON_BAD_ARG_INPUT
fi

echo "$ELEMENT" | while read ATOMIC_NUMBER BAR NAME BAR SYMBOL BAR ATOMIC_MASS BAR MELTING_POINT_CELSIUS BAR BOILING_POINT_CELSIUS BAR TYPE
do
echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT_CELSIUS celsius and a boiling point of $BOILING_POINT_CELSIUS celsius."
done

exit