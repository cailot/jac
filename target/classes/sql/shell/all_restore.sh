#!/bin/zsh

# Database credentials
DB_USER="javacoffee"
DB_PASS="J@va1973M"
DB_HOST="localhost"
DB_NAME="jac"
BACKUP_FILE="/Users/javacoffee/dev/db/all_backup.sql"

# Drop the existing database
mysql -u $DB_USER -p$DB_PASS -h $DB_HOST -e "DROP DATABASE IF EXISTS $DB_NAME;"

# Recreate the database
mysql -u $DB_USER -p$DB_PASS -h $DB_HOST -e "CREATE DATABASE $DB_NAME;"

# Restore the backup
mysql -u $DB_USER -p$DB_PASS -h $DB_HOST $DB_NAME < $BACKUP_FILE