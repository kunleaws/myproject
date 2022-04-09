import os
import sys
import time
import shutil
import re
import smtplib
from datetime import datetime
import cx_Oracle



#---Declare Global Variables-----
time_string=time.localtime()
TS=time.strftime("_%m_%d_%Y_%M_%S",time_string)
print("The formatted time is {}".format(TS))


def SENDMAIL(SUBJECT, BODY, EMAIL):
    smtpServer = 'localhost'
    server = smtplib.SMTP(smtpServer)

    MAILER = 'ORACLE@MKIT-DEV-OEM.localdomain'
    to= EMAIL

    sent_from=MAILER
    subject = SUBJECT
    body = BODY
    email_text = """\
    From: %s
    To: %s
    Subject: %s

    %s
    """ % (sent_from,to, subject, body)
    server.sendmail(sent_from, to, email_text)
    server.quit()

def COPY_FILE():
  type_prompt=raw_input("""Do you want to backup a file or directory?\nPlease enter F for File backup\nPlease enter D for directory backup\nPlease enter DF for dynamic file backup\nPlease enter DD for dynamic directory backup: """).upper()

  if type_prompt == 'F':

    print("Hi, I am here to help you make a file backup")
    src="/home/oracle/scripts/practicedir_kunle_dec21/testexport.sh"
    dst="/backup/AWSDEC21/KUNLE/testexport.sh"

    try:
      shutil.copy(src, dst + TS)
      print("Successfully copied to the backup location ")
    except:
      print("Operation failed")

  if type_prompt == 'D':

    print("Hi, I am here to help you make a directory backup")
    src="/home/oracle/scripts/practicedir_kunle_dec21/"
    dst="/backup/AWSDEC21/KUNLE/practicedir"

    try:
      shutil.copytree(src, dst + TS)
      print("Successfully copied to the backup location ")
    except:
      print("Operation failed")


  if type_prompt == 'DF':

    print("Hi, I am here to help you make a file backup")
    src=raw_input("Please enter source file path: ")
    dst=raw_input("Please enter the destination path: ")

    try:
      shutil.copy(src, dst + TS)
      print("Successfully copied to the backup location ")
    except:
      print("Operation failed")

  if type_prompt == 'DD':

    print("Hi, I am here to help you make a directory backup")
    src=raw_input("Please enter the source directory path: ")
    dst=raw_input("Please enter the destination path: ")

    try:
      shutil.copytree(src, dst + TS)
      print("Successfully copied to the backup location ")
    except:
      print("Operation failed")
 #####FUNCTION DEFINITION#####

def BACKUP_DATABASE():
##---Database Operation Connection Details----

  RUNNER="Kunle"
  start_time = datetime.now()
  connection = cx_Oracle.connect(user="STACK_DEC21_CE_KUN", password="stackinc", dsn="localhost/APEXDB")
  cursor=connection.cursor()
  cursor.execute("""insert into operations(OP_ID, OP_NAME, OP_STARTTIME, RUNNER, STATUS, OP_TYPE, UP_DATE) values(:OP_ID, :OP_NAME, :OP_STARTTIME, :RUN_NER, :STATUS, :OP_TYPE, :UP_DATE)""",
  OP_ID = 1,
  OP_NAME = "BACKUP",
  OP_STARTTIME = start_time,
  RUN_NER = RUNNER,
  STATUS = "ACTIVE",
  OP_TYPE = "SCHEMA",
  UP_DATE = "COMPLETE")
  connection.commit()


  type_prompt=raw_input("""Do you want to backup a Database?\nPlease enter DDB for dynamic Database Backup\nPlease enter CDB for cron job Database Backup: """).upper()

  if type_prompt == 'DDB':


    #os.system("/home/oracle/scripts/practicedir_kunle_dec21/envfile.sh")

    os.getcwd()
    os.chdir("/home/oracle/scripts/practicedir_kunle_dec21")
    SCHEMA_LIST=raw_input("List of schemas: ")
    RUNNER=raw_input("Enter the name of runner: ")
    fo=open("apex_db_export.par","w+")
    fo.write("userid=' / as sysdba'")
    fo.write("\n")
    fo.write("schemas=" + SCHEMA_LIST)
    fo.write("\n")
    fo.write("dumpfile=schema_export_" + RUNNER +".dmp" + TS)
    fo.write("\n")
    fo.write("logfile=schema_export_" + RUNNER +".log" + TS)
    fo.write("\n")
    fo.write("directory=DATA_PUMP_KUNLE")
    fo.close()
    os.system("ps -ef |grep pmon")
    os.system(". /home/oracle/scripts/oracle_env_APEXDB.sh")
    os.system("expdp parfile=apex_db_export.par")

##Opening a file to search for a string

    file1 = open("/backup/DATAPUMP/APEXDB/KUNLE/0404202208/schema_export_kunle.log" + TS, "r")
    readfile = file1.read()
    if "successfully completed" in readfile:
      print("Database Backup was successfully completed")
    else:
      print("Failed to perform Database Backup")

##Closing the file
    file1.close()

    SENDMAIL('Running Database Backup','The Database dump for ' + SCHEMA_LIST + ' was successfully completed','stackcloud8@mkitconsulting.net')

  if type_prompt == 'CDB':

    os.getcwd()
    os.chdir("/home/oracle/scripts/practicedir_kunle_dec21")
    SCHEMA_LIST='STACK_DEC21_CE_KUN'
    RUNNER='kunle'
    fo=open("apex_db_export.par","w+")
    fo.write("userid=' / as sysdba'")
    fo.write("\n")
    fo.write("schemas=" + SCHEMA_LIST)
    fo.write("\n")
    fo.write("dumpfile=schema_export_" + RUNNER +".dmp" + TS)
    fo.write("\n")
    fo.write("logfile=schema_export_" + RUNNER +".log" + TS)
    fo.write("\n")
    fo.write("directory=DATA_PUMP_KUNLE")
    fo.close()
    os.system("ps -ef |grep pmon")
    os.system(". /home/oracle/scripts/oracle_env_APEXDB.sh")
    os.system("expdp parfile=apex_db_export.par")


    file1 = open("/backup/DATAPUMP/APEXDB/KUNLE/0404202208/schema_export_kunle.log" + TS, "r")
    readfile = file1.read()
    if "successfully completed" in readfile:
      print("Database Backup was successfully completed")
    else:
      print("Database Backup FAILED")

    file1.close()
    SENDMAIL('Running Database Backup','The Database dump for ' + SCHEMA_LIST + ' was successfully completed','stackcloud8@mkitconsulting.net')

  end_time = datetime.now()
  cursor.execute("""update operations set OP_ENDTIME=:endtime where OP_STARTTIME=:starttime""",
  endtime = end_time,
  starttime = start_time)
  connection.commit()

 #####FUNCTION DEFINITION#######

def SENDMAIL(SUBJECT, BODY, EMAIL):

  smtpServer = 'localhost'
  server = smtplib.SMTP(smtpServer)

  MAILER = 'ORACLE@MKIT-DEV-OEM.localdomain'
  to= EMAIL

  sent_from=MAILER
  subject = SUBJECT
  body = BODY
  email_text = """\
  From: %s
  To: %s
  Subject: %s

  %s
  """ % (sent_from,to, subject, body)
  server.sendmail(sent_from, to, email_text)
  server.quit()
def CLOUD_MIGRATION():

  print("Hi, I am here to help you migrate data into the AWS cloud")


if __name__=="__main__":

 #####PROGRAM BODY AND FUNCTION CALLS######

  user_in=(raw_input("""What do you want to do?\nEnter C to copy a file or directory\nEnter D to backup a database\nEnter M to migrate data into the AWS cloud\nEnter Input: """)).upper()

if user_in=='C':
        COPY_FILE()

elif user_in=='C':
   SENDMAIL()

elif user_in=='D':
        BACKUP_DATABASE()

elif user_in=='D':
   SENDMAIL()

elif user_in=='M':
        CLOUD_MIGRATION()

else:
        print("You entered the wrong input")
