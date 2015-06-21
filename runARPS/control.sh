#!/bin/bash 
 
# author Chris Reudenbach (2013)
# version 2015/04/18
echo ' Hallo Rudolf'
source $1
cp  /home/$USER/$ARPSINDIR/$DOMAIN/$SRC/$0 /home/$USER/run_$ARPS/$INITIALSTRING/$NAMESTRING/$0
mpi=$2

# check if mpirun is still working

# start infinite loop sleep 1 reduces the cpu load extremly 
while  sleep 60; do
mpirunning=`ps -e | grep mpirun | awk '{print $1; exit}'`


#if mpirun is not working any more we can start with the postprocessing
if [ "$mpirunning" ==  "$mpi" ]
 then
 echo ""
 else
    echo 'hohoho wake up ' 
   # first set watch  flag to false
   watch=false

   # go to the current directory
   cd "/home/$USER/run_$ARPS/$INITIALSTRING/$NAMESTRING"

   # start the arpscvt bin
   #cvtsuccess=~/$ARPS/bin/arpscvt < $CVT | grep '==== Program ARPSCVT terminated normally. ===='
                                              #arpsstop called from dtaread during base read-2
   ~/$ARPS/bin/arpscvt < /home/$USER/run_$ARPS/$INITIALSTRING/$NAMESTRING/$DOMAIN$ARP.input | tee cvt.log

   # mkdir on remote host
    ssh gisma@137.248.191.52 <<-EOF 
	mkdir -p ~/run_$ARPS/$INITIALSTRING/$NAMESTRING
	exit
	EOF
   
   # copy the netcdf file to the corresponding folder on the remote host
   scp $NAMESTRING$SECONDRUNEXT'.nc'  gisma@137.248.191.52:~/run_$ARPS/$INITIALSTRING/$NAMESTRING 
   

   # delete the _ready files ***FIXME***
#   ssh gisma@137.248.191.52 <<-EOF 
#	rm  ~/run_$ARPS/$INITIALSTRING/$NAMESTRING/'*_ready'
#	exit
#	EOF
       
   # zip all files
   gzip ~/run_$ARPS/$INITIALSTRING/$NAMESTRING/$NAMESTRING.bin*
   
   # and bye
   cat cvt.log |  grep '==== Program ARPSCVT terminated normally. ===='
   
   exit
 fi
done
