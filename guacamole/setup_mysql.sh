#!/bin/bash

# Docker Compose service name for MySQL (from your docker-compose.yml file)
MYSQL_SERVICE_NAME="guac-sql"  # Replace with your MySQL service name from docker-compose.yml
MYSQL_ROOT_PASS="my_passwd"    # Replace with the actual root password
DATABASE_NAME="guacamole_db"
USER_NAME="guacamole_user"
USER_PASSWORD="my_passwd"

COUNT=0
MAX_RETRIES=12

while true
do
    res=$(docker ps --filter "name=$MYSQL_SERVICE_NAME" --format '{{.Status}}' | grep "Up")
    len=${#res}
    if [ $len -gt 0 ]; then
        echo "Container $MYSQL_SERVICE_NAME is running!"

        # Execute MySQL commands inside the container
        docker exec -i "$MYSQL_SERVICE_NAME" mysql -u root -p"$MYSQL_ROOT_PASS" <<EOF
        CREATE DATABASE IF NOT EXISTS $DATABASE_NAME;
        CREATE USER IF NOT EXISTS '$USER_NAME'@'%' IDENTIFIED BY '$USER_PASSWORD';
        GRANT ALL PRIVILEGES ON $DATABASE_NAME.* TO '$USER_NAME'@'%';
        FLUSH PRIVILEGES;
EOF
        echo "Database and user setup complete!"
        break

    else
        echo "Container $MYSQL_SERVICE_NAME is NOT running. Retrying..."
        sleep 5
        COUNT=$((COUNT + 1))
        if [ $COUNT -ge $MAX_RETRIES ]; then
            echo "Error: Container $MYSQL_SERVICE_NAME is not starting after $MAX_RETRIES retries"
            exit 1
        fi
    fi
done