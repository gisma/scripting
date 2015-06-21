#!/bin/bash 
# author Chris Reudenbach (2013)
# version 2015/05/23
# script to setup an arbitrary ARPS run using GFS boundary data

# source the .bashrc file for the env variables
source $HOME/.bashrc 

if [[ "$1" == '-h' ]]; then
    echo "Usage: ./run_sim.sh -h brief help | <setup file> "
    echo""
    echo "<setup file>: i.e.  '/home/arpsuser/arpsinput/d1/src/KILI_D1_01.sh' "
    echo""
    echo "example:      nohup ~/arpsinput/d1/src/./run_sim.sh '/home/arpsuser/arpsinput/d1/src/KILI_D1_01.sh' & "
    echo "NOTE: Use 'nohup' for protecting the process and '&' to put it in the background "
    exit 0
elif [ "$#" -ne 1 ]; then
    echo "Usage: ./run_sim.sh -h brief help | <arg1> "
    echo " "
    exit 0
fi


# source the simulation specific setup file
source $1

# change directory to runtimedirectory   
cd /home/$USER/run_$ARPS/$INITIALSTRING/$NAMESTRING

echo 'You are using the following '$YPXP' CPUs'
cat $HOSTFILE
echo $DOMAIN
echo $ARPSINPUTDIR
echo $ARPSINDIR

# start simulation
/usr/lib64/mpi/gcc/openmpi/bin/mpirun  -default-hostfile none -hostfile $HOSTFILE  -n $YPXP  /home/"$USER"/"$ARPS"/bin/arps_mpi   /home/"$USER"/"$ARPSINDIR"/"$DOMAIN"/"$DOMAIN$ARP".input  | tee run.log &
FOO1_PID=$!
echo "$RUNNAME$DOMAIN setup finished: - simulation with process number $FOO1_PID started"

# start postprocessing
/home/"$USER"/"$ARPSINPUT"/"$DOMAIN"/"$SRC"/./post_run.sh /home/"$USER"/"$ARPSINPUT"/"$DOMAIN"/"$SRC"/KILI_D1_01.sh $FOO1_PID  | tee post.log &



