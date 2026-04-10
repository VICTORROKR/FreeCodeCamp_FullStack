#! /bin/bash

# Conexión optimizada para que los tests lean bien la salida
PSQL="psql -X --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # 1. Mostrar lista de servicios con formato id) nombre
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICES" | while IFS="|" read SERVICE_ID NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  # 2. Leer SERVICE_ID_SELECTED
  read SERVICE_ID_SELECTED

  # Verificar si el servicio existe
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  if [[ -z $SERVICE_NAME ]]
  then
    # Si no existe, mostrar la lista de nuevo (User Story)
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    # 3. Leer CUSTOMER_PHONE
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    # Buscar nombre del cliente
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    # 4. Si el cliente NO existe, pedir CUSTOMER_NAME
    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      # Insertar nuevo cliente
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    fi

    # 5. Leer SERVICE_TIME
    echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed -E 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')?"
    read SERVICE_TIME

    # Obtener customer_id para la cita
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    # 6. Insertar la cita en la tabla appointments
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    # 7. Mensaje final con formato exacto requerido
    # Usamos sed para limpiar espacios en blanco si los hubiera
    NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')
    SERVICE_FORMATTED=$(echo $SERVICE_NAME | sed -E 's/^ *| *$//g')
    
    echo -e "\nI have put you down for a $SERVICE_FORMATTED at $SERVICE_TIME, $NAME_FORMATTED."
  fi
}

MAIN_MENU