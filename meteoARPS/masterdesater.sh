#!/bin/bash 
 
# author Chris Reudenbach (2013)
# version 2015/04/18
# script to setup an arbitrary ARPS run using GFS boundary data
USER=$1
ARPS=$2
INITIALSTRING=$3
NAMESTRING=$4
SECONDRUNEXT=$5
PID=$6
CVT=$7
USER=`whoami`
ARPS='arps5.3.3'
RUNNAME='kili_'
DOMAIN='d1'
NAMESTRING=$RUNNAME$DOMAIN
# getting datestring
YEAR4=`date -u +%Y`
YEAR2=`date -u +%y`
MONTH=`date -u +%m`
DAY=`date -u +%d`

# generate  initialstring format 2013-11-30 for arpsinput
INITIALSTRING=$YEAR4-$MONTH-$DAY

SECONDRUNEXT='_ARP'
CVT='d1_cvt.input'
!mpirunning=''

while true

if !mpirunning
cd /home/$USER/run_$ARPS/$INITIALSTRING/$NAMESTRING

cvtsuccess=~/$ARPS/bin/arpscvt < $CVT | '==== Program ARPSCVT terminated normally. ===='

ssh gisma@137.248.191.52 'mkdir -p /home/gisma/arps/$INITIALSTRING/$NAMESTRING'

if !cvtsuccess 
 ssh gisma@137.248.191.52 'touch /home/gisma/arps/$INITIALSTRING/$NAMESTRING/POOR'
else
 ssh gisma@137.248.191.52 'touch /home/gisma/arps/$INITIALSTRING/$NAMESTRING/SUCCESS'
fi

scp $NAMESTRING$SECONDRUNEXT'.nc'  gisma@137.248.191.52:~/arps/$INITIALSTRING/$NAMESTRING

gzip *
fi
done
#arpsstop called from dtaread during base read-2
