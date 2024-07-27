#!/bin/zsh

# Database credentials
DB_USER="javacoffee"
DB_PASS="J@va1973M"
DB_HOST="localhost"
DB_NAME="jac"
BACKUP_FILE="/Users/javacoffee/dev/db/data_backup.sql"


# Backup only data with complete insert statements
mysqldump -h $DB_HOST -u $DB_USER -p$DB_PASS --no-create-info --complete-insert $DB_NAME > $BACKUP_FILE

echo "Data backup completed and saved to $BACKUP_FILE"