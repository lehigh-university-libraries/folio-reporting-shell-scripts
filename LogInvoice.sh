#!/bin/bash
function main() {

  local okapi_url=$1
  local tenant=$2
  local username=$3
  local password=$4
  local invoice_id=$5

  if [[ -z "$okapi_url" ]]
  then
    read -p "Enter Okapi URL: " okapi_url
    if [[ -z "$okapi_url" ]]
    then
      echo "Okapi URL cannot be empty."
      return 1
    fi
  fi

  if [[ -z "$tenant" ]]
  then
    read -p "Enter Okapi tenant: " tenant
    if [[ -z "$tenant" ]]
    then
      echo "Okapi tenant cannot be empty."
      return 1
    fi
  fi

  if [[ -z "$username" ]]
  then
    read -p "Enter admin username: " username
    if [[ -z "$username" ]]
    then
      echo "Username cannot be empty."
      return 1
    fi
  fi

  if [[ -z "$password" ]]
  then
    read -s -p "Enter admin password: " password
    echo
    if [[ -z "$password" ]]
    then
      echo "Password cannot be empty."
      return 1
    fi
  fi

  # Login by admin
  login_body="{\"username\":\"${username}\",\"password\":\"${password}\"}"
  login_url="${okapi_url}/authn/login"

  token=$(curl -X POST "${login_url}" --silent \
        -H "X-Okapi-Tenant: $tenant" \
        -H "Content-Type: application/json" \
        -d "${login_body}" | awk 'BEGIN { FS="\""; RS="," }; { if ($2 == "okapiToken") {print $4} }')

  if [[ -z $token ]]
  then
    echo "Cannot login. Shutting down the script."
    return 1
  fi

  get_invoice_url="${okapi_url}/invoice-storage/invoices/${invoice_id}"

  response=$(curl -X GET "${get_invoice_url}" --silent \
    -H "X-Okapi-Tenant: $tenant" \
    -H "X-Okapi-Token: $token" \
    -H "Content-Type: application/json" )


  echo "$response" > "response-$(date +'%F-%T').json"
}

function checkAlreadyRunning() {
  for pid in $(pidof -x $(basename "$0")); do
    if [ $pid != $$ ]; then
      echo "[$(date)] : $(basename "$0") : Process is already running with PID $pid"
      exit 1
    fi
  done
}

# Main entry point

checkAlreadyRunning

main $1 $2 $3 $4 $5
