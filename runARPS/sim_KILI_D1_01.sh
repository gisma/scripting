#!/bin/bash 
# author Chris Reudenbach (2013)
# version 2015/05/23
# script to setup an arbitrary ARPS run using GFS boundary data

# this is an ugly call to bring all lined up in a seperate shell with nohup
# ***FIXME*** as soon as I know how
"source $HOME/.bashrc && \
               export USER=$USER export ARPS=$ARPS RUNNAME=$RUNNAME DOMAIN=$DOMAIN NAMESTRING=$NAMESTRING INITIALSTRING=$INITIALSTRING SECONDRUNEXT=$SECONDRUNEXT DOMAIN$CVT=$DOMAIN$CVT HOSTFILE=$HOSTFILE YPXP=$YPXP && \
               /usr/lib64/mpi/gcc/openmpi/bin/mpirun  -default-hostfile none -hostfile $HOSTFILE  -n $YPXP  /home/$USER/$ARPS/bin/arps_mpi   /home/$USER/arpsinput/d1/$DOMAIN$ARP.input > run.log && \
               /home/$USER/arpsinput/d1/src/./control.sh $USER $ARPS $RUNNAME $DOMAIN $NAMESTRING $INITIALSTRING $SECONDRUNEXT $DOMAIN$CVT" &
FOO_PID=$!
echo "$RUNNAME$DOMAIN setup finished: - simulation with process number $FOO_PID started"

