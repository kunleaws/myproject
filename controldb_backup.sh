#!/bin/bash

#HOW TO RUN THE SCRIPT
#./controldb_backup.sh C D $pd_kunle $kunle_bk kunleadexsr@gmail.com APEXDB kunle Y 'select username from all users where username like '%DEC21%';'
#./controldb_backup.sh H D (Database Backup- Human Interactive)
#./controldb_backup.sh C F $pd_kunle $kunle_bk kunleadexsr@gmail.com (File or Directory Backup USING CRON)
#./controldb_backup.sh H F  $pd_kunle $kunle_bk kunleadexsr@gmail.com


COMFLAG=$1
BACKUP_TYPE=$2
SOURCE=$3
DEST=$4
EMAIL=$5

TS=`date '+%d%m%Y%S'`
TS2=`date '+%d%m%Y%k%M%S'`

SPOOL=/home/oracle/scripts/practicedir_kunle_dec21/db_schema_list.log
DATA_PUMP_KUNLE=/backup/DATAPUMP/APEXDB/KUNLE/${TS}
DB=APEXDB
DB_BACKUP_LOC=/backup/AWSDEC21/KUNLE/${TS2}
GZIP_LOC=/backup/DATAPUMP/APEXDB/KUNLE

BACKUPLOC=${DEST}/${TS2}

PRACTICEDIR=/home/oracle/scripts/practicedir_kunle_dec21/
BACKUP_DIRECTORY=/backup/DATAPUMP/APEXDB/KUNLE/

           if [[ ${COMFLAG} == 'C' ]]
              then
                 echo "This is a Cron Job!! Checking the type of backup being performed"
                 if [[ $BACKUP_TYPE == 'F' ]]
                 then
                    echo "Performing File or Directory Backup"
                    echo "Counting command line arguements to ensure you have the right arguements for your backup"

                      if [[ $# != 5 ]]
                      then
                        echo "You don't have five command line arguements. The command line arguements needed are below:
                           -COMFLAG
                           -BACKUP_TYPE
                           -SOURCE
                           -DESTINATION
                           -EMAIL"
                           exit
                      else
                         echo " "
                                                        fi

                         if [ -d ${BACKUPLOC} ]
                            then
                              echo "The directory ${BACKUPLOC} already exist"
                              else
                            mkdir -p ${BACKUPLOC}

                         fi

                   if [ $? == 0 ]
                      then
                        echo "The directory was successfuly created"
                      else
                        echo "The directory ${BACKUPLOC} failed to create"
                   fi

                          cp -r ${SOURCE} ${BACKUPLOC}

                  if [ $? == 0 ]
                     then
                     echo "The directory ${SOURCE} copied successfully to the backup location"
                     echo "File or directory ${SOURCE} backup was successfully copied to the ${BACKUPLOC}, no further action is needed."| mailx -s "The backup of file or directory ${SOURCE} was successful" ${EMAIL}
                           else
                     echo "The fire or directory ${SOURCE} failed to copy to ${BACKUPLOC}"
                     echo "File or directory ${SOURCE} failed to copy to the directory ${BACKUPLOC}, notifying on-call personnel."| mailx -s "The backup of file or directory ${SOURCE} failed" ${EMAIL}
                  fi

              exit

#############################################################################
            elif [[ $BACKUP_TYPE == 'D' ]]
               then
            echo "Performing Database Backup"
            echo "Counting the required command line argument"

              if [[ $# != 9 ]]
              then
               echo "Counting the command line argument needed:
                    -COMFLAG: Schedule in Crontab or run manually
                    -BACKUP_TYPE: F for File or Directory Backup, D for Database Backup
                    -SCHEMA_NAME: Name of the Schema to be backup
                    -RUNNER
                    -LOG_NAME
                    -EMAIL"
               exit
              fi

#####################
EMAIL=$5
SCHEMA_NAME=$6
RUNNER=$7
SQLPASS=$8
SCHEMALIST=$9
####################
#List all DB process currently running
echo " "
echo "List all OracleDB process currently running on the system"
ps -ef |grep pmon

#Sleep for 5 Seconds
sleep 5

##################################################################
#Check if directory exist/create the directory/check exit status
           if [ -d ${DATA_PUMP_KUNLE} ]
                then
        echo "The Directory ${DATA_PUMP_KUNLE} already exist"
        else
                mkdir -p ${DATA_PUMP_KUNLE}
        fi
##################################################################
                if [ -d ${DB_BACKUP_LOC} ]
                then
                echo "The Directory ${DB_BACKUP_LOC} already exist"
                else
                           mkdir -p ${DB_BACKUP_LOC}
                fi
#################################################################

   if [ $? == 0 ]
     then
   echo "The Directory ${DATA_PUMP_KUNLE} created successfuly"
     else
   echo "The Directory ${DATA_PUMP_KUNLE} failed to create"
   fi

#Create spool file
#touch /home/oracle/scripts/practicedir_kunle_dec21/test_dblogin.log
touch ${SPOOL}

#Set Environment Variable
. /home/oracle/scripts/oracle_env_APEXDB.sh

   if [[ ${SQLPASS} == 'Y' ]]
   then
       echo "We are backing up the database by passing in sqlstatement"
       SQLSTATEMENT=${SCHEMALIST}
       echo "You are running ${SQLSTATEMENT} SQL statement in the ${DB} database"

       sqlplus -s stack_temp/stackinc << EOF
       set heading off pagesize 0 term off echo off feedback off
       spool '/home/oracle/scripts/practicedir_kunle_dec21/db_schema_list.log'
       --${SQLSTATEMENT}
       select username from all_users where username like '%DEC21%';
       create or replace directory DATA_PUMP_KUNLE as '${BACKUP_DIRECTORY}/${TS}';
       spool off
EOF

   while read SCHEMANAME
   do
         echo "Looping through from the file"

#Create a parameter file
         echo "userid=' / as sysdba'" > expdp_${RUNNER}.par
         echo "schemas=${SCHEMANAME}" >> expdp_${RUNNER}.par
         echo "dumpfile=${SCHEMANAME}_${RUNNER}.dmp" >> expdp_${RUNNER}.par
         echo "logfile=${SCHEMANAME}_${RUNNER}.log" >> expdp_${RUNNER}.par
         echo "directory=DATA_PUMP_KUNLE" >> expdp_${RUNNER}.par

   expdp parfile=expdp_${RUNNER}.par
   done < /home/oracle/scripts/practicedir_kunle_dec21/db_schema_list.log

#Adding a compressed gzip command
tar -czvf ${DB_BACKUP_LOC}/databasebackup_${TS}.tar ${DATA_PUMP_KUNLE}/*
#tar -czvf ${DB_BACKUP_LOC}/databasebackup_${TS}.tar --remove-files ${DATA_PUMP_KUNLE}/*

find ${GZIP_LOC}/* -type d -mtime +3 -exec rm -rvf {} \;

               if [ $? == 0 ]
                  then
                    echo "The database schemas backup was successfull"
                    echo "The database schemas backup was successful, no further action is needed."| mailx -s "The Database schemas backup was successful" ${EMAIL}
                  else
                    echo "The database schemas backup failed"
                    echo "The database schemas backup failed, notifying on-call personnel."| mailx -s "The database schemas backup failed" ${EMAIL}
               fi

exit

    elif [[ ${SQLPASS} == 'N' ]]
    then
       echo "We are backing up the database by passing in sqlstatement"
       SQLSTATEMENT=${SCHEMALIST}
       echo "You are running ${SQLSTATEMENT} SQL statement in the ${DB} database"

       sqlplus -s stack_temp/stackinc << EOF
       set heading off pagesize 0 term off echo off feedback off
       spool '/home/oracle/scripts/practicedir_kunle_dec21/db_schema_list.log'
       --${SQLSTATEMENT}
       select username from all_users where username like '%DEC21%';
       create or replace directory DATA_PUMP_KUNLE as '${BACKUP_DIRECTORY}/${TS}';
       spool off
EOF

   while read SCHEMANAME
   do
         echo "Looping through from the file"

#Create a parameter file
         echo "userid=' / as sysdba'" > expdp_${RUNNER}.par
         echo "schemas=${SCHEMANAME}" >> expdp_${RUNNER}.par
         echo "dumpfile=${SCHEMANAME}_${RUNNER}.dmp" >> expdp_${RUNNER}.par
         echo "logfile=${SCHEMANAME}_${RUNNER}.log" >> expdp_${RUNNER}.par
         echo "directory=DATA_PUMP_KUNLE" >> expdp_${RUNNER}.par

   expdp parfile=expdp_${RUNNER}.par
   done < /home/oracle/scripts/practicedir_kunle_dec21/db_schema_list.log

       else

           if [ $? == 0 ]
           then
               echo "The database schemas backup was successfull"
               echo "The database schemas backup successfully, no further action is needed."| mailx -s "The Database schemas backup was successful" ${EMAIL} < ${DATA_PUMP_KUNLE}/${SCHEMANAME}_${RUNNER}.log
           else
               echo "The database schemas backup failed"
               echo "The database schemas backup failed, notifying on-call personnel."| mailx -s "The database schemas backup failed" ${EMAIL} < ${DATA_PUMP_KUNLE}/${SCHEMANAME}_${RUNNER}.log


            fi
    fi
  fi


else
     if [[ ${BACKUP_TYPE} == 'F' ]]
     then
        echo "Grabbing extra arguements for your file or directory backup....."
        read -p "Please Enter Source File or Directory: " SOURCE
        read -p "Please Enter Destination Directory: " DEST

     cp -r ${SOURCE} ${DEST}
           if [ $? == 0 ]
              then
                 echo "The directory ${SOURCE} copied successfully to the backup location"
                 echo "File or directory ${SOURCE} backup was successfully copied to the ${BACKUPLOC}, no further action is needed."| mailx -s "The backup of file or directory ${SOURCE} was successful" ${EMAIL}
              else
                 echo "The fire or directory ${SOURCE} failed to copy to the backup location"
                 echo "File or directory ${SOURCE} failed to copy to the directory ${BACKUPLOC}, notifying on-call personnel."| mailx -s "The backup of file or directory ${SOURCE} failed" ${EMAIL}
           fi
exit


     elif [[ $BACKUP_TYPE == 'D' ]]
        then

            . /home/oracle/scripts/oracle_env_${DB}.sh

          echo "You are Backing Up a Database Schema"
          read -p "Enter the runner: " Runner
          #read -p "Please specify the database backup Destination: " DATA_PUMP_KUNLE
          read -p "Are you backing up less than ten database  schemas? Please enter Y for yes, and N for No : " ans

        if [[ $ans == 'Y' ]]
          then
             echo "Collecting list of Schemas"
          read -p "Please enter your list of schemas in an array: " SCHEMAS
          for name in ${SCHEMAS}
          do
             echo "We are backing up list of Schemas"
             echo "userid=' / as sysdba '" > expdp_${RUNNER}.par
             echo "schemas= ${name} " >> expdp_${RUNNER}.par
             echo "dumpfile=${name}_${RUNNER}.dmp" >> expdp_${RUNNER}.par
             echo "logfile=${name}_${RUNNER}.log" >> expdp_${RUNNER}.par
             echo "directory=DATA_PUMP_KUNLE" >> expdp_${RUNNER}.par
                                 expdp parfile=expdp_${RUNNER}.par
          done

             if ( grep "successfully completed" ${DATA_PUMP_KUNLE}/${name}_${RUNNER}.log )
             then
                echo "The Database backup was successfully completed"|mailx -s "Database back was successfully completed, no further action is needed" <  ${DATA_PUMP_KUNLE}/${name}_${RUNNER}.log
             else
                echo "The Database backup failed, notifying on-call personnel"| mailx -s "Database Backup failed"

             fi


     else
         echo "There are two options to backing up more than ten schemas"
         echo "1) You can pass an SQL statement into a database to generate the list of users"
         echo "2) You can pass in a file of schemas and loop through the schemas in the file to backup"

         options=' 1 2 '

         PS3='Select an option: '

         select option  in $options
         do
         if [[ $option == 1 ]]
         then
            echo "You are passing an SQL statement that generates the database users to backup"
            read -p "Enter SQL statement: " SQLSTATEMENT
            echo "You entered ${SQLSTATEMENT}"
            read -p "Enter database you will be backing up: " DB
            echo "You entered $DB"

  ##create physical directory
  mkdir -p ${BACKUP_DIRECTORY}/${RUNNER}/${TS}

          sqlplus -s stack_temp/stackinc << EOF
          set heading off pagesize 0 term off echo off feedback off
          spool '/home/oracle/scripts/practicedir_${RUNNER}/db_schema_list.log'
          ${SQLSTATEMENT}
          create or replace directory DATA_PUMP_$KUNLE as '${BACKUP_DIRECTORY}/${RUNNER}/${TS}';
          spool off
EOF

         echo "Backing up the attached list of schemas from the ${DB} database" |  mailx -s "Schema backup list from database ${DB}" ${EMAIL} < /home/oracle/scripts/practicedir_${Runner}/db_schema_list.log
         while read SCHEMA
         do

         echo "Creating the datapump parameter file for backup......"
         echo "We are backing up list of Schemas"
         echo "userid= ' / as sysdba '" > expdp_${RUNNER}.par
         echo "schemas= ${SCHEMANAME} " >> expdp_${RUNNER}.par
         echo "dumpfile=${SCHEMANAME}_${RUNNER}.dmp" >> expdp_${RUNNER}.par
         echo "logfile=${SCHEMANAME}_${RUNNER}.log" >> expdp_${RUNNER}.par
         echo "directory=DATA_PUMP_KUNLE" >> expdp_${RUNNER}.par
         echo "Backing up the schema ${SCHEMA} from database ${DB}"

         expdp parfile=expdp_${RUNNER}.par

         done< /home/oracle/scripts/practicedir_${Runner}/db_schema_list.log


         exit


        elif [[ $option == 2 ]]
        then
          echo "You are passing in an absolute path of a file that has a schema list"
          read -p "Please Enter Full Path Of Your File Of Schemas: " SCHEMA_FILE_PATH
          read -p "Please Enter Database Name: " DB

#NEW ENTRY
            . /home/oracle/scripts/oracle_env_${DB}.sh

            ##create physical directory
            mkdir -p ${BACKUP_DIRECTORY}/${RUNNER}/${TS}

            sqlplus -s stack_temp/stackinc << EOF
            set heading off pagesize 0 term off echo off feedback off
            spool '/home/oracle/scripts/practicedir_${RUNNER}/${SCHEMA}_${RUNNER}.log'
            create or replace directory DATA_PUMP_${RUNNER} as '${BACKUP_DIRECTORY}/${RUNNER}/${TS}';
            spool off
EOF
##END NEW ENTRY

          while read SCHEMANAME
           do
          echo "Looping through from the file"

 #Create a parameter file
          echo "userid=' / as sysdba'" > expdp_${RUNNER}.par
          echo "schemas=${SCHEMANAME}" >> expdp_${RUNNER}.par
          echo "dumpfile=${SCHEMANAME}_${RUNNER}.dmp" >> expdp_${RUNNER}.par
          echo "logfile=${SCHEMANAME}_${RUNNER}.log" >> expdp_${RUNNER}.par
          echo "directory=DATA_PUMP_KUNLE" >> expdp_${RUNNER}.par

          expdp parfile=expdp_${RUNNER}.par
          done < /home/oracle/scripts/practicedir_kunle_dec21/db_schema_list.log



          exit
#####I just comment this out    else
          echo "Do Nothing"
          exit
       fi
          done
  fi
 fi
fi


######################################################################################################################
        #COMPRESS DATAPUMP BACKUP DIRECTORY

tar -czvf ${DB_BACKUP_LOC}/databasebackup_${TS}.tar ${DATA_PUMP_KUNLE}/*
#tar -czvf ${DB_BACKUP_LOC}/databasebackup_${TS}.tar --remove-files ${DATA_PUMP_KUNLE}/*

#REMOVE DIRECTORIES OLDER THAN 3 DAYS
find ${GZIP_LOC}/* -type d -mtime +3 -exec rm -rvf {} \;
