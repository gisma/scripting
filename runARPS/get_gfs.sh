#!/bin/bash 
 
# author Chris Reudenbach (2013)
# version 2015/04/11
# script starting gribmaster to get GFS boundary data

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


# call gribmaster to check/get the files
/home/$USER/$ARPS/gribmaster/gribmaster --date $1 --dset gfs025grb2 


# call gribmaster to check/get the files
/home/$USER/$ARPS/gribmaster/gribmaster --date $1 --dset gfs050grb2 
