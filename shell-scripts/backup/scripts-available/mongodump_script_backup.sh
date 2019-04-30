#!/bin/bash

# Mongodb backup

# Version : 0.1
# CHANGELOG :

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
#  - STDOUT -- to be appended to mail notice
#  - STDERR -- to be appended to error log for mail notice
################################################
# TODO:
#  - backup databases individually
#

SCRIPT_PREFIX="mongodump"

# Define default extra files to include in the archive
SOURCE_FOLDER=""

################################################
# BINARY Details
################################################
MONGODUMP_BIN=/app/local/mongo27017/bin/mongodump

#
## Check binaries
# MONGODUMP_BIN
if [ ! -x "$MONGODUMP_BIN" ]; then
  echo "$MONGODUMP_BIN -- binary not executable" >&2
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

#
## File name definition
DUMP_FOLDER="$DESTINATION_FOLDER"/"$SCRIPT_PREFIX"/"$SCRIPT_PREFIX"
BACKUP_FILE="$DESTINATION_FOLDER"/"$SCRIPT_PREFIX"/"$PREFIX"_"$SCRIPT_PREFIX".tar.gz

#
## check for custom backup folder
if [ ! -d "$DUMP_FOLDER" ]; then
  mkdir -p "$DUMP_FOLDER"
  if [ $? -ne 0 ]; then echo "$DESTINATION_FOLDER folder is not writable, check permissions" ; exit 2 ; fi
fi

#
## Check for writable destination
if [ ! -w "$DUMP_FOLDER" ]; then
  echo "$DUMP_FOLDER folder is not writable, check permissions" >&2
   echo "current owner UID: $UID" >&2
   echo "current PWD: $PWD" >&2
   echo " user@host:~$ ls -la $DUMP_FOLDER" >&2
   ls -la "$DUMP_FOLDER" >&2
  exit 2
fi
  
#
## check if the finale archive exists already
if [ -f "$BACKUP_FILE" ]; then
  echo "$BACKUP_FILE already exists - Backup job Cancelled" >&2
  exit 2
fi


#########################################
# DB backup
#########################################
# dump all the collections
$MONGODUMP_BIN --gzip -u $MONGO_USER -h $MONGO_HOST -d $MONGO_DB -o $DUMP_FOLDER -p "$MONGO_PWD" > /dev/null 2>&1
if [ $? -ne 0 ]; then
   echo "mongodump failed" >&2
   exit 2
fi
echo "Dump done."; echo

#
## compress Database and return required format tar.gz
echo "Compress file"
tar czf "$BACKUP_FILE" -C "$DESTINATION_FOLDER" "$SCRIPT_PREFIX"/"$SCRIPT_PREFIX" --remove-files
echo "Compress Done."; echo

## clean backup folder
echo "Clean backup folder"
rm -rf $DUMP_FOLDER
echo "Clean Done."; echo

#
## display final archive details
echo "List archive"
ls -la "$DESTINATION_FOLDER"/"$SCRIPT_PREFIX"/"$PREFIX"_"$SCRIPT_PREFIX"*
echo "List Done."; echo
