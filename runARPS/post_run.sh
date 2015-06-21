#!/bin/bash 

# author Chris Reudenbach (2013)
# version 2015/04/18

if [[ "$1" == '-h' ]]; then
    echo "Usage: ./post_run.sh -h brief help | <setup file> <PID> "
    echo""
    echo "<setup file>:  i.e.  '/home/arpsuser/arpsinput/d1/src/KILI_D1_01.sh' "
    echo "<PID>          PID of the corresponding mpirun process (is automatically generated whil start of mpirun in [run_sim.sh])"
    echo ""
    echo "example:       ~/arpsinput/d1/src/./post_run.sh /home/arpsuser/arpsinput/d1/src/KILI_D1_01.sh $FOO1_PID & "
    exit 0
elif [ "$#" -ne 2 ]; then
    echo "Usage: ./pre_run.sh -h brief help | <setup file> <PID> "
    echo " "
    exit 0
fi
# greetz rudolph
echo 'Hallo Rudolph'
source $1
fn0=$(basename "$0")
cp  /home/"$USER"/"$ARPSINDIR"/"$DOMAIN"/"$SRC"/"$fn0" /home/"$USER"/run_"$ARPS"/"$INITIALSTRING"/"$NAMESTRING"/"$fn0"
echo " copy done"
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
    echo 'hohoho wake up santa claus' 
   # first set watch  flag to false
   watch=false

   # go to the current directory
   cd /home/"$USER"/run_"$ARPS"/"$INITIALSTRING"/"$NAMESTRING"

   # start the arpscvt bin
   #cvtsuccess=~/$ARPS/bin/arpscvt < $CVT | grep '==== Program ARPSCVT terminated normally. ===='
                                              #arpsstop called from dtaread during base read-2
   echo "~/"$ARPS"/bin/arpscvt < /home/"$USER"/run_"$ARPS"/"$INITIALSTRING"/"$NAMESTRING"/"$DOMAIN$ARP".input | tee cvt.log"

   # mkdir on remote host
    ssh gisma@137.248.191.52 <<-EOF 
	mkdir -p ~/run_"$ARPS"/"$INITIALSTRING"/"$NAMESTRING"
	exit
	EOF
   
   # copy the netcdf file to the corresponding folder on the remote host
   scp "$NAMESTRING$SECONDRUNEXT"'.nc'  gisma@137.248.191.52:~/run_"$ARPS"/"$INITIALSTRING"/"$NAMESTRING"
   

   # fix  the nc file 
   ssh gisma@137.248.191.52 <<-EOF 
	cat 
	#!/usr/bin/Rscript
	library(aRps)
	refARPSnc("~/run_$ARPS/$INITIALSTRING/$NAMESTRING/$NAMESTRING$SECONDRUNEXT'.nc'",'allNew') > ~/run_$ARPS/$INITIALSTRING/$NAMESTRING/a2a.R
	chmod +x a2a.R
	./a2a.R
	exit
	EOF
       
   # zip all files
   gzip ~/run_$ARPS/$INITIALSTRING/$NAMESTRING/$NAMESTRING.bin*
   
   # and bye
   cat cvt.log |  grep '==== Program ARPSCVT terminated normally. ===='
   
   exit
 fi
done
