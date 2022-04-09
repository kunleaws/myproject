#!/bin/bash

#./control_kunle_bk.sh $pd_kunle $kunle_bk STACK_SEPT21_EZE kunle stack_sept21_eze D kunleadexsr@gmail.com

#Declare first command line argument variable as $1
SOURCE=$1

#Declare second command line argument variable as $2
DEST=$2

#Declare 3rd command line argument
SCHEMA_NAME=$3

#Declare 4th command line argument
RUNNER=$4

#Declare variable for log_name
LOG_NAME=$5

BACKUP_TYPE=$6

#Declare email variable command line argument
EMAIL=$7

#Create a date timestamp using "DayMonthYearH:M:S". The back tick will allow date    command to run at run time
TS2=`date '+%d%m%Y%k%M%S'`
TS=`date '+%d%m%Y'`

SPOOL=/home/oracle/scripts/practicedir_kunle_dec21/test_dblogin.log
DATA_PUMP_KUNLE=/backup/DATAPUMP/APEXDB/KUNLE/${TS}
DB_BACKUP_LOC=/backup/AWSDEC21/KUNLE/${TS2}
GZIP_LOC=/backup/DATAPUMP/APEXDB/KUNLE

#Declare variable for Backup destination with timestamp
BACKUPLOC=${DEST}/${TS2}



###Checking for command line argument correctness
#if [[ $# < 7 || $# > 7 ]]
if [[ $# != 7 ]]
then
  echo "Usage: You need to enter below command line argument
       -Source File
       -Backup Location
       -Schema Name
       -Runner
       -Log Name
       -Backup_type
       -Email"
exit
fi


if [[ ${BACKUP_TYPE} == 'F' ]]
  then
echo "Backup type is ${BACKUP_TYPE}"

#Declaring if statement when creating backup directory
if [ -d ${BACKUPLOC} ]
      then
      echo "Backup Directory ${BACKUPLOC} already exist"
      else
    mkdir -p ${BACKUPLOC}

    if [[ $? == 0 ]]
      then

     echo " "
     echo "---------------------------------------------------------------------------------"
     echo "The ${BACKUPLOC} directory was successfully created."
     echo "---------------------------------------------------------------------------------"

     else
     echo "${BACKLOC} directory failed to create."
   fi
 fi

#Copy file/directory recursively from source location to destination directory
cp -r ${SOURCE} ${BACKUPLOC}


#check exit status for directory copied to backup location
if [ $? == 0 ]
  then
echo "The directory ${SOURCE} copied successfully to ${BACKUPLOC}"
echo "File or directory ${SOURCE} backup was successfully copied to the ${BACKUPLOC}, no further action is needed."| mailx -s "The backup of file or directory ${SOURCE} was successful" ${EMAIL}
  else
echo "The fire or directory ${SOURCE} failed to copy to ${BACKUPLOC}"
echo "File or directory ${SOURCE} failed to copy to the directory ${BACKUPLOC}, notifying on-call personnel."| mailx -s "The backup of file or directory ${SOURCE} failed" ${EMAIL}
fi



echo " "

#Display message upon successful after file/directory was copied successfully
echo "------------------------------------------------------------------------------------------------"
echo "The File/Directory has been successfully copied to the ${BACKUPLOC}"
echo "------------------------------------------------------------------------------------------------"


elif [[ ${BACKUP_TYPE} == 'D' ]]
then
   echo "Backup type is ${BACKUP_TYPE}"

#List all DB process currently running
echo " "
echo "List all OracleDB process currently running on the system"
ps -ef |grep pmon

#Sleep for 5 Seconds
sleep 5

#Check if directory exist/create the directory/check exit status
if [ -d ${DATA_PUMP_KUNLE} ]
  then
echo "The Directory ${DATA_PUMP_KUNLE} already exist"
  else
mkdir -p ${DATA_PUMP_KUNLE}
fi

if [ $? == 0 ]
  then
echo "The Directory ${DATA_PUMP_KUNLE} created successfuly"
  else
echo "The Directory ${DATA_PUMP_KUNLE} failed to create"
fi

        if [ -d ${DB_BACKUP_LOC} ]
                then
                        echo "The Directory ${DB_BACKUP_LOC} already exist"
   else
                mkdir -p ${DB_BACKUP_LOC}
        fi

if [ $? == 0 ]
  then
echo "The Directory ${DATA_PUMP_KUNLE} created successfuly"
  else
echo "The Directory ${DATA_PUMP_KUNLE} failed to create"
fi

DB_BACKUP_LOC

#Create spool file
#touch /home/oracle/scripts/practicedir_kunle_dec21/test_dblogin.log
touch ${SPOOL}

#Set Environment Variable
. /home/oracle/scripts/oracle_env_APEXDB.sh

#Login to DB - Anywhere between EOF is where you put DB syntax
#Create logical backup location with timestamp
sqlplus stack_temp/stackinc<<EOF

spool '/home/oracle/scripts/practicedir_kunle_dec21/test_dblogin.log'

select status from v\$instance;

select * from global_name;

create or replace directory DATA_PUMP_KUNLE as '/backup/DATAPUMP/APEXDB/KUNLE/${TS}';

select directory_name,directory_path from dba_directories where  directory_name like '%KUNLE%';
spool off

EOF

#Search for the string "OPEN" in the spool file
#if { grep "OPEN" /home/oracle/scripts/practicedir_kunle_dec21/test_dblogin.log }

   if ( grep "OPEN" ${SPOOL} )
   then
       echo "The Database is opened"
         else
       echo "The Database is not opened"
   fi

        #List all DB process currently running
        echo " "
        echo "List all OracleDB process currently running on the system"
        ps -ef |grep pmon

        #Create a parameter file
        echo "userid=' / as sysdba'" > expdp_${RUNNER}.par
        echo "schemas=${SCHEMA_NAME}" >> expdp_${RUNNER}.par
        echo "dumpfile=${LOG_NAME}_${RUNNER}.dmp" >> expdp_${RUNNER}.par
        echo "logfile=${LOG_NAME}_${RUNNER}.log" >> expdp_${RUNNER}.par
        echo "directory=DATA_PUMP_KUNLE" >> expdp_${RUNNER}.par

        #Set Environment Variable
        . /home/oracle/scripts/oracle_env_APEXDB.sh



        #Run Database_Backup
        expdp parfile=expdp_${RUNNER}.par



##############################################################################################################
#if [ $? == 0 ]
#
#  then
#echo "The Database Dump was successful"
#echo "The Database schema ${SCHEMA_NAME} backup was successful. "| mailx -s "The Database schema ${SCHEMA_NAME} dump was successful, no further action is needed" ${EMAIL}
#  else
#echo "The Database Dump failed"
#echo "The Database schema ${SCHEMA_NAME} backup failed, notifying on-call personnel."| mailx -s "The Database schema ${SCHEMA_NAME} dump failed, your ATTENTION is needed" ${EMAIL}
#
#       fi
#else
#       echo "Bad option"
#fi

#############################################################################################################

      if ( grep "successfully completed" ${DATA_PUMP_KUNLE}/${LOG_NAME}_${RUNNER}.log )
      then
          echo "Database dump was successfully completed"| mailx -s "The database backup was successfull" ${EMAIL} < ${DATA_PUMP_KUNLE}/${LOG_NAME}_${RUNNER}.log
             else
          echo "Database dump failed"| mailx -s "The database backup failed, notifying on-call personnel" ${EMAIL} < ${DATA_PUMP_KUNLE}/${LOG_NAME}_${RUNNER}.log
      fi

fi

#COMPRESS DATAPUMP BACKUP DIRECTORY
#tar -czvf ${DATA_PUMP_KUNLE}/databasebackup_${TS2}.tar /backup/DATAPUMP/APEXDB/KUNLE/*
#tar -czvf ${DB_BACKUP_LOC}/databasebackup_${TS}.tar ${DATA_PUMP_KUNLE}/*

#tar -czvf ${DATA_PUMP_KUNLE}/databasebackup_${TS2}.tar --remove-files /backup/DATAPUMP/APEXDB/KUNLE/*

#REMOVE DIRECTORIES OLDER THAN 3 DAYS
#find ${GZIP_LOC}/* -type d -mtime +1 -exec ls -ltr {} \;

#find ${GZIP_LOC}/* -type d -mtime +1 -exec rm -rvf {} \;
