#!/bin/bash
################################################
# MySQL DB backup
#
# Version: 0.1
# Changes:
#   2015-10-26: Initial creation
################################################
# Requirements from the Master script API
#
# INPUT:
#  - $1 -- root destination backup folder
#  - $2 -- archive PREFIX
#  - $3 -- backup config file
#
# OUTPUT:
#  - 1 backup archive tar.gz -- Naming Format: prefix_XXXXX.tar.gz
#  - STDOUT -- to be appened to mail notice
#  - STDERR -- to be appened to error log for mail notice
################################################
# TODO:
#  - backup databases individually
#

SCRIPT_PREFIX="mydump"

# Define default extra files to include in the archive
SOURCE_FOLDER=""

################################################
# BINARY Details
################################################
MYSQLDUMP="/usr/bin/mysqldump"
MYSQL="/usr/bin/mysql"

#
## Check binaries
# MYSQLDUMP
if [ ! -f "$MYSQLDUMP" ]; then
  echo "MYSQLDUMP: $MYSQLDUMP -- binary not found" >&2
  exit 2
fi
if [ ! -x "$MYSQLDUMP" ]; then
  echo "MYSQLDUMP: $MYSQLDUMP -- binary not executable" >&2
  exit 2
fi 

#
## Check binaries
#MYSQL
if [ ! -f "$MYSQL" ]; then
  echo "MYSQL: $MYSQL -- binary not found" >&2
  exit 2
fi
if [ ! -x "$MYSQL" ]; then
  echo "MYSQL: $MYSQL -- binary not executable" >&2
  exit 2
fi 

##################################################
# Manage parameters
##################################################
#
## Save parameters
DESTINATION_FOLDER="$1"
PREFIX="$2"
BACKUP_CONFIG_FILE="$3"

#
## Check for valid destination folder
if [ ! -d "$DESTINATION_FOLDER" ]; then
  echo "$DESTINATION_FOLDER is not a valid folder" >&2
  exit 2
fi

#
## Check parameters
if [ -z "$DESTINATION_FOLDER" ]; then
  echo "Missing destination folder" >&2
  exit 2
fi

if [ -z "$PREFIX" ]; then
  echo "Missing master backup prefix" >&2
  exit 2
fi

#
## Check for valid FULL PATH
if [ ${DESTINATION_FOLDER:0:1} != '/' ]; then
  echo "Need FULL PATH for destination backup folder" >&2
  exit 2
fi

#
## Check for valid configuration file
if [ -f "$BACKUP_CONFIG_FILE" -a -r "$BACKUP_CONFIG_FILE" ]; then 
  source "$BACKUP_CONFIG_FILE"
else
  echo "The master backup config file is not readable" >&2
  echo "$BACKUP_CONFIG_FILE" >&2
  exit 2
fi

## Parameter for binary and creds file
MYSQLDUMP_AND_CREDS="$MYSQLDUMP --defaults-extra-file=$MYDUMP_MYSQL_CREDS"
MYSQL_AND_CREDS="$MYSQL --defaults-extra-file=$MYDUMP_MYSQL_CREDS"
#
## File name definition
BACKUP_FOLDER="$DESTINATION_FOLDER"/"$SCRIPT_PREFIX"
BACKUP_FILE="$BACKUP_FOLDER"/"$PREFIX"_"$SCRIPT_PREFIX".sql

#
## check for custom backup folder
if [ ! -d "$BACKUP_FOLDER" ]; then
  mkdir -p "$BACKUP_FOLDER"
  if [ $? -ne 0 ]; then echo "$DESTINATION_FOLDER folder is not writable, check permissions" ; exit 2 ; fi
fi

#
## Check for writable destination
if [ ! -w "$BACKUP_FOLDER" ]; then
  echo "$BACKUP_FOLDER folder is not writable, check permissions" >&2
   echo "current owner UID: $UID" >&2
   echo "current PWD: $PWD" >&2
   echo " user@host:~$ ls -la $BACKUP_FOLDER" >&2
   ls -la "$BACKUP_FOLDER" >&2
  exit 2
fi
  
#
## check if the finale archive exists already
if [ -f "$BACKUP_FILE" ]; then
  echo "$BACKUP_FILE already exists - Backup job Cancelled" >&2
  exit 2
fi

#
## check if the mysql Credentials are correct
if [ ! -s "$MYDUMP_MYSQL_CREDS" ]; then
	echo "Invalid MySQL credential files: $MYDUMP_MYSQL_CREDS" >&2
	exit 1
fi

########################################
# Log Rotate 
#######################################
#Define SQL
SQL="
\! echo '------------ Flushing logs ----------'
flush logs;
\! echo
\! echo '---- Show master status ----' 
SHOW MASTER STATUS;
\! echo
\! echo '---- Show slave status ----'
SHOW SLAVE STATUS \G
\! echo
"
     $MYSQL_AND_CREDS -e "$SQL" >/dev/null


#########################################
# DB backup
#########################################
#
## backup Database
#echo "Backing up Database : $DB_NAME"
#"$MYSQLDUMP" --defaults-extra-file="$MYDUMP_MYSQL_CREDS"  --add-locks --extended-insert --lock-tables --all-databases > "$BACKUP_FILE"
#echo "Backup Done."; echo
for DB_NAME in $($MYSQL_AND_CREDS -e "show databases" | sed '/Database/d' | grep -v "information_schema");
do
  echo "Backing up Database : $DB_NAME"
  date
  if echo "SHOW TABLE STATUS FROM \`$DB_NAME\`;" | $MYSQL_AND_CREDS --skip-column-name | grep -iv "innodb" >/dev/null;then

	echo "$DB_NAME has MYISAM TABLES , using DUMP backup method"
	$MYSQLDUMP_AND_CREDS --opt --routines --triggers --events --flush-privileges --skip-add-drop-table --dump-date --databases $DB_NAME | gzip > "$BACKUP_FOLDER"/"$PREFIX"_"$SCRIPT_PREFIX"_"$DB_NAME".sql.gz
  else
        echo "$DB_NAME has all InnoDB tables , using InnoDB backup method"
	$MYSQLDUMP_AND_CREDS --opt --routines --triggers --events --flush-privileges --skip-add-drop-table --master-data=2 --single-transaction  --skip-add-locks --skip-lock-tables --dump-date --databases $DB_NAME | gzip > "$BACKUP_FOLDER"/"$PREFIX"_"$SCRIPT_PREFIX"_"$DB_NAME".sql.gz
  fi
  echo "Backup Done."; echo
done

#########################################
# LOG backup
#########################################
#
## backup logs

MYSQL_DATA=/var/lib/mysql/data/

cd $MYSQL_DATA

j=""

        for i in $(ls -l | grep "$(date +%b.%e)" | grep mysql-bin | awk -F" " '{ print $NF }')

                do j="$j $MYSQL_DATA$i"

                done

sudo tar czCf / "$BACKUP_FOLDER"/"$PREFIX"_"$SCRIPT_PREFIX".bin-log.gz $j

## check for FULL PATH only in SOURCE_FOLDER
for folder in ${SOURCE_FOLDER} ${MYDUMP_EXTRA_DATA}
do
  if [ ${folder:0:1} != '/' ]; then
    echo "Need FULL PATH for source backup folders / files" >&2
    exit 2
  fi
done


#
## compress Database and return required format tar.gz
cd "$BACKUP_FOLDER"
echo "Compress file"
#FILE=`basename "$BACKUP_FILE"`
FILE=*.sql.gz
tar czf "$BACKUP_FILE".tar.gz $FILE $SOURCE_FOLDER $MYDUMP_EXTRA_DATA --remove-files
echo "Compress Done."; echo

#
## compress Mysql bin-log  and return required format tar.gz
cd "$BACKUP_FOLDER"
echo "Compress file"
#FILE=`basename "$BACKUP_FILE"`
FILE=*.bin-log.gz
tar czf "$BACKUP_FILE".bin-log.tar.gz $FILE $SOURCE_FOLDER $MYDUMP_EXTRA_DATA --remove-files
echo "Compress Done."; echo


#
## display final archive details
echo "List archive"
ls -la $BACKUP_FOLDER/$PREFIX\_$SCRIPT_PREFIX*
ls -la $SOURCE_FOLDER $MYDUMP_EXTRA_DATA
echo "List Done."; echo

#
## display final archive details
echo "List archive"
ls -la "$BACKUP_FOLDER"
echo "List Details Done."
