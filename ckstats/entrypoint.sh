#!/usr/bin/env bash

# Set the default entrypoint to be the ckstats binary
set +e

export FNM_PATH="/root/.local/share/fnm"
export PATH="$FNM_PATH:$PATH"
eval "`fnm env --use-on-cd`"

# create the .env file
echo "Generating .env file..."
# Ensure variables are set or use defaults that work within the docker network
DB_URL=${DATABASE_URL:-"postgres://ckstats:ckstats@db/ckstats"}
SHADOW_DB_URL=${SHADOW_DATABASE_URL:-"postgres://ckstats:ckstats@db/dbshadow"}
API=${API_URL:-"http://bitcoincash-ckpool:4028"}
WAIT_FOR_FULL_SYNC=${WAIT_FOR_FULL_SYNC:-0}

cat <<EOF > /app/ckstats/.env
DATABASE_URL=${DB_URL}
SHADOW_DATABASE_URL=${SHADOW_DB_URL}
API_URL=${API}
DB_HOST=${DB_HOST:-"db"}
DB_USER=${DB_USER:-"ckstats"}
DB_PASSWORD=${DB_PASSWORD:-"ckstats"}
DB_NAME=${DB_NAME:-"ckstats"}
DB_PORT=${DB_PORT:-"5432"}
EOF

echo "Using DATABASE_URL: ${DB_URL}"

# Start the cron service
service cron start

while true; do
# Attempt to call getblockchaininfo
  OUTPUT=$(bitcoin-cli -rpcconnect=bitcoincash-ckpool -rpcport=$RPCPORT -rpcuser=$RPCUSER -rpcpassword=$RPCPASSWORD getblockchaininfo 2>&1)
  RPC_EXIT_CODE=$?

  if [ $RPC_EXIT_CODE -eq 0 ]; then
    # Successfully got JSON; now parse the initialblockdownload field
    IBD=$(echo "$OUTPUT" | jq -r '.initialblockdownload' 2>/dev/null)

    # If .initialblockdownload is false, it's fully synced
    if [ "$IBD" = "false" ]; then
      echo "Bitcoin Cash Node has finished initial block download."
      break
    else
      if [ "$WAIT_FOR_FULL_SYNC" = "1" ]; then
        echo "Bitcoin Cash Node is still syncing. initialblockdownload=$IBD"
      else
        echo "Bitcoin Cash Node is still syncing, continuing startup because WAIT_FOR_FULL_SYNC=${WAIT_FOR_FULL_SYNC}."
        break
      fi
    fi
  else
    echo "Bitcoin Cash Node not ready. RPC error code $RPC_EXIT_CODE."
    echo "Output: $OUTPUT"
  fi

  echo "Sleeping 10s..."
  sleep 10
done

set -e
# migrate the database
cd /app/ckstats
pnpm migration:run
# seed the database
pnpm seed
# build the app
pnpm build
# start the server
service cron restart
pnpm start
