# Scripts for backup and test restore mysql database

System of scripts makes backup of desired database, send it to s3 and check old backup by restoring it to another database.
Scripts are writing log (with filename mysql.log by default).
In case of error scipts will send email to administrator.

## mysql_settings.conf file

Contains variables for connecting to mysql and credentials to access s3.
Also it contains admin email to get messages if script exit with error.
File is called by other scripts.

## mysql_backup.sh script

Usage: `mysql_backup.sh`

Script make two backups: data and schema.
Files are uploaded to object storage (s3) to desired bucket and saved with day of month in the names.
Day of month gives backup with depth of month.

## mysql_test_restore.sh script

Usage: `mysql_test_restore.sh [day_of_month]`

Script create temporary database and restores backups there.
Option "day_of_month" gives ability to restore backup for other day.
Number of day must be in two digits format (e.x. 01, 06, 28).
Temporary database is deleting after restore.

## Prerequisites

These utilities need to be installed on a host:
- mysql
- mysqldump
- aws
- mail

S3 bucket with desired name must exists and provided credentials must give access to write objects there.
Utility "mail" need to be properly configured to have ability to send email.
