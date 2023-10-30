# RSync Backup Script

## Overview

This backup script is designed to automate the backup process of a specified source directory to weekly and monthly backup directories, and to prune old backups in the weekly directories to conserve space. The script logs its operations to a log directory, ensuring traceability and accountability.

Note: Be cautious of your available space. The core script can be modified to keep more records, but you have to ensure the storage medium can support what you need plus one month in advance. In my use case, I mounted a separate drive and dedicated it to running these scripts and maintaining the data.

## Configuration

Before running the script, you need to configure it via a configuration file. The configuration file should be placed beside the core script and named something like backup_config.cfg. Be sure to enter the full path inside the core script. The variables within this file are as follows:

- `LOG_DIR`: The directory where log files will be stored.
- `BACKUP_DIR`: The root directory where backups will be created.
- `SOURCE_DIR`: The directory that needs to be backed up.

The configuration file should look something like this:

```bash
LOG_DIR="/backups/logs"
BACKUP_DIR="/backups"
SOURCE_DIR="/app"
```

## Usage

The script is designed to run without any command line arguments. It's recommended to run as root to ensure all files can be copied. It is ideal to be set up as a cron job to run on a daily basis.

```bash
chmod 777 backup_script.sh
chmod 777 backup_config.cfg
sudo bash backup_script.sh
```

My cron as an example:
```bash
$ sudo crontab -e
# every day at 2 am
0 2 * * * /backups/backup.sh >> /backups/cron/$(date +\%Y-\%m-\%d_\%H-\%M-\%S).log 2>&1
```

## Directory Structure

The script will create the following directory structure under the `BACKUP_DIR`:

```plaintext
├── weekly
│   ├── week_01
│   ├── week_02
│   └── ...
└── monthly
    ├── January
    ├── February
    └── ...
```

## Logging

All operations, including backup and pruning activities, are logged to a file named `backup_<timestamp>.log` in the `LOG_DIR`. Each log entry is timestamped, allowing for precise tracking of when each operation occurred.

## Backup Strategy

- **Weekly Backup**: On every Sunday, the script performs a weekly backup by copying the contents of `SOURCE_DIR` to a new or existing directory under `WEEKLY_DIR` named `week_<week_number>`.
- **Monthly Backup**: On the first day of every month, the script performs a monthly backup by copying the contents of `SOURCE_DIR` to a new or existing directory under `MONTHLY_DIR` named after the current month.
- **Pruning**: 
  - In the weekly backup directory, directories older than 14 days are deleted, keeping only the two most recent weekly backups.
  - In the monthly backup directory, all directories except for the current month's directory are deleted.

## Error Handling

The script does not include explicit error handling. Therefore, it's advisable to check the log files regularly to ensure that backups are being performed as expected, and to consider adding error handling to suit your specific needs.

## Dependencies

- `rsync`: This script depends on `rsync` to perform the backup operations.
- `find`: This script depends on `find` to perform the pruning operations.
- `tee`: This script depends on `tee` to log the operations to both the console and the log file.

## Recommendations

- It's advisable to test this script in a safe environment before deploying it in a production environment.
- Consider setting up monitoring and alerting based on the log files to ensure the backup operations are being performed as expected.
- It's good practice to review and update the backup strategy periodically to ensure it continues to meet your needs.

## To Do
- Add a discord webhook to send a message when the backup is complete