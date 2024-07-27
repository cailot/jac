#!/bin/zsh

# Database credentials
DB_USER="javacoffee"
DB_PASS="J@va1973M"
DB_HOST="localhost"
DB_NAME="jac"
BACKUP_FILE="/Users/javacoffee/dev/db/all_backup.sql"

# Backup schema and data, ensuring to include foreign keys and not to drop tables
mysqldump -h $DB_HOST -u $DB_USER -p$DB_PASS --routines --triggers --databases $DB_NAME --complete-insert --skip-add-drop-table --add-drop-database --set-gtid-purged=OFF > $BACKUP_FILE

echo "Full backup completed and saved to $BACKUP_FILE"
