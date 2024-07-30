#!/bin/zsh

# Database credentials
DB_USER="javacoffee"
DB_PASS="J@va1973M"
DB_HOST="localhost"
DB_NAME="jac"
BACKUP_FILE="/Users/javacoffee/dev/db/all_backup.sql"

# Function to check if the database exists
check_database_exists() {
    RESULT=$(mysql -u $DB_USER -p$DB_PASS -h $DB_HOST -e "SHOW DATABASES LIKE '$DB_NAME';")
    if [[ "$RESULT" == "" ]]; then
        return 1
    else
        return 0
    fi
}

# Check if the database exists
check_database_exists
DB_EXISTS=$?
echo "DB Exists: $DB_EXISTS"  # Debugging line

# If the database does not exist, create it
if [ $DB_EXISTS -eq 1 ]; then
    echo "Database $DB_NAME does not exist. Creating database..."
    mysql -u $DB_USER -p$DB_PASS -h $DB_HOST -e "CREATE DATABASE $DB_NAME;"
    echo "Database $DB_NAME created."
else
    echo "Database $DB_NAME already exists."
fi

# Restore the data from the backup file
echo "Restoring data from $BACKUP_FILE into database $DB_NAME..."
mysql -u $DB_USER -p$DB_PASS -h $DB_HOST $DB_NAME < $BACKUP_FILE
if [ $? -eq 0 ]; then
    echo "Data restoration completed successfully."
else
    echo "Data restoration encountered an error."
fi