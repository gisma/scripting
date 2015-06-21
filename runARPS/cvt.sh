#!/bin/bash 
 
# author Chris Reudenbach (2013)
# version 2015/04/11
# script start conversion of common ARPS output to netcdf

source $HOME/.bashrc

#.......................................................................
### define settings
#.......................................................................

# identify what "type" of user you are 
USER=`whoami`

# set used  ARPS directory
ARPS='arps5.3.3'

#.......................................................................
### call gribmaster with the GFS 0.25.x0.25  input file 
#.......................................................................
 /home/$USER/$ARPS/bin/arpscvt  < d1_cvt.input 





