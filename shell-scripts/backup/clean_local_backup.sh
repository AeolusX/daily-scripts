#!/bin/bash
##############################
# Local backup cleanup
#
# Description: Clean old backup files
#
# Details: There is generally not enough space locally on the
# server to store all the backup on a long period of time
# The purpose of this script is to limit the number of files
# and keep only the last few days of backup
##############################
# ChangeLog:
##############################

# Binaries
FIND="/usr/bin/find"

# Parameters
AGE="+2" # by default keep only 2 days of backup locally
LOCAL_BACKUP_DIR="/opt/backup"

#
## log the error in logger + display error message + exit script
log_error() {
  VALUE="$1"
  echo $VALUE >&2
  logger `basename $0`"- $VALUE"
  exit 2
}

# Checks
if [ -z $LOCAL_BACKUP_DIR ]; then
  log_error "Missing local backup directory - edit script"
fi

if [ "${LOCAL_BACKUP_DIR:0:1}" != "/" ];then 
  log_error "Please use absolute path."
fi 

if [ "$LOCAL_BACKUP_DIR" = "/" ]; then 
  log_error "Warning : Check local backup directory."
fi

logger `basename $0` " - start cleanup > $AGE days : $LOCAL_BACKUP_DIR"
$FIND "$LOCAL_BACKUP_DIR" \( -type f -o -type p \) -ctime $AGE -exec rm -rf '{}' ';'
if [ $? -eq 0 ]; then
  logger `basename $0` " - clean up successful"
else 
  log_error "Clean up error"
fi

