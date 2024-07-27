#!/bin/zsh

# Database credentials
DB_USER="javacoffee"
DB_PASS="J@va1973M"
DB_HOST="localhost"
DB_NAME="jac"

# Drop the existing database and recreate it
mysql -h $DB_HOST -u $DB_USER -p$DB_PASS -e "DROP DATABASE IF EXISTS $DB_NAME; CREATE DATABASE $DB_NAME;"

echo "Database $DB_NAME has been dropped and recreated."