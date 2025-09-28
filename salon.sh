#!/bin/bash

# PSQL helper
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only --no-align -c"

print_header() {
  echo -e "\n~~~~~ MY SALON ~~~~~\n"
  echo "Welcome to My Salon, how can I help you?"
}

list_services() {
  # List all services in the required format: id) name
  $PSQL "SELECT service_id, name FROM services ORDER BY service_id;" | while IFS='|' read -r SID NAME; do
    [[ -n "$SID" ]] && echo "${SID}) ${NAME}"
  done
}

get_service() {
  local INPUT="$1"
  # Validate numeric
  if [[ ! "$INPUT" =~ ^[0-9]+$ ]]; then
    echo ""
    echo "I could not find that service. What would you like today?"
    list_services
    read SERVICE_ID_SELECTED
    get_service "$SERVICE_ID_SELECTED"
    return
  fi

  local ROW
  ROW=$($PSQL "SELECT service_id, name FROM services WHERE service_id = $INPUT;")
  if [[ -z "$ROW" ]]; then
    echo ""
    echo "I could not find that service. What would you like today?"
    list_services
    read SERVICE_ID_SELECTED
    get_service "$SERVICE_ID_SELECTED"
  else
    SERVICE_ID_SELECTED=$(cut -d'|' -f1 <<<"$ROW")
    SERVICE_NAME=$(cut -d'|' -f2 <<<"$ROW")
  fi
}

main() {
  print_header
  echo ""
  list_services

  read SERVICE_ID_SELECTED
  get_service "$SERVICE_ID_SELECTED"

  # Ask for phone
  echo ""
  echo "What's your phone number?"
  read CUSTOMER_PHONE

  # Lookup customer by phone
  CUSTOMER_ROW=$($PSQL "SELECT customer_id, name FROM customers WHERE phone = '$CUSTOMER_PHONE';")

  if [[ -z "$CUSTOMER_ROW" ]]; then
    echo ""
    echo "I don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    # Insert new customer
    INSERT_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
    # Lookup id after insert
    CUSTOMER_ROW=$($PSQL "SELECT customer_id, name FROM customers WHERE phone = '$CUSTOMER_PHONE';")
  fi

  CUSTOMER_ID=$(cut -d'|' -f1 <<<"$CUSTOMER_ROW")
  CUSTOMER_NAME=$(cut -d'|' -f2 <<<"$CUSTOMER_ROW")

  # Ask for time
  echo ""
  echo "What time would you like your ${SERVICE_NAME}, ${CUSTOMER_NAME}?"
  read SERVICE_TIME

  # Insert appointment
  INSERT_APPT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")

  echo ""
  echo "I have put you down for a ${SERVICE_NAME} at ${SERVICE_TIME}, ${CUSTOMER_NAME}."
}

main
