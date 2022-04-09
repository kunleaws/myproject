#!/bin/bash

#Explanation: s/%//g We only need the 4th value and remove the % from the result

EMAIL="kunleadexsr@gmail.com"
DISK_LOC="/home/oracle/scripts/practicedir_kunle_dec21/diskcheckoutput"

df -h | tail -n +2 | sed s/%//g | awk '{ if($4 > 70) print "Alert disk " $5 " is " $4 "%" " full" ;}' > ${DISK_LOC}

if df -h | tail -n +2 | sed s/%//g | awk '{ if($4 > 70) print "Alert disk " $5 " is " $4 "%" " full" ;}'
        then
        echo "Disk is reporting above the threshold limit, notifying on-call personnel"| mailx -s "The Server is reporting above the threshold limit set on the system" ${EMAIL} < ${DISK_LOC}
else
        echo "System is at the normal Threshold and no further action is needed"
fi
