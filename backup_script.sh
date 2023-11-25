#!/bin/bash

# Backup Script
# This script performs a backup of the specified source directory 
# into weekly, and monthly backup directories.
# Old backups in the weekly directories are pruned.

# Source the configuration file
source ./backup_config.cfg

# Create log directory
mkdir -p $LOG_DIR

# Log file name
LOG_FILE="$LOG_DIR/backup_$(date +%Y-%m-%d_%H-%M-%S).log"

# Configuration
WEEKLY_DIR="$BACKUP_DIR/weekly"  # Weekly backup directory
MONTHLY_DIR="$BACKUP_DIR/monthly"  # Monthly backup directory

# Ensure backup directories exist
mkdir -p $WEEKLY_DIR $MONTHLY_DIR

# Date format for folder naming
# Week number for weekly backup folder naming
WEEK_NUM=$(date +%U)
# Month name for monthly backup folder naming
MONTH_NAME=$(date +%B)

{
    
    # Weekly Backup (Assuming the week ends on Sunday)
    if [ $(date +%u) -eq 7 ]; then
        WEEK_FOLDER="week_$WEEK_NUM"
        echo "Performing weekly backup into $WEEK_FOLDER..."
        rsync -a $SOURCE_DIR/ $WEEKLY_DIR/$WEEK_FOLDER/
        
        # Prune additional weekly backups, keeping only the 2 most recent ones
        echo "Pruning additional weekly backups..."
        find $WEEKLY_DIR/ -maxdepth 1 -type d -mtime +14 -exec rm -rf {} +
    fi

    # Monthly Backup (On the first day of the month)
    if [ $(date +%d) -eq 01 ]; then
        echo "Performing monthly backup for $MONTH_NAME..."
        rsync -a $SOURCE_DIR/ $MONTHLY_DIR/$MONTH_NAME/
        ls -lart $MONTHLY_DIR
        
        # Prune previous months' backups
        echo "Pruning previous months' backups..."
        find $MONTHLY_DIR/ -maxdepth 1 -type d ! -name $MONTH_NAME -exec rm -rf {} +
    fi

    echo "Backup and pruning complete."

} | tee -a $LOG_FILE
