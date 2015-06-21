#!/bin/bash  
# author Chris Reudenbach (2013)
# script to setup an arbitrary ARPS run using GFS boundary data

source $HOME/.bashrc
#.......................................................................
### define settings
#.......................................................................

# identify what "type" of user you are 
USER=`whoami`

# set used  ARPS directory
ARPS='arps5.3.3'

# set external datapath
EXTDATAPATH='\/home\/'$USER'\/'$ARPS'\/initial\/'

# be careful in adjusting size resolution and time depends on each other

# big timestep & small timestep !! have to be even due to RBcopt3
DTBIG='6.0'
DTSML='0.8'

# Domainsize
NX='163' #'203' #163  #203 #183
NY='163' #'203' #163  #203 #183
NZ='40'

# fix domain resolution
DX='2000' # x res in Meter
DY='2000' # y res in Meter
DZ='500'  # z res in Meter

# vertical streching options for dz
STRHOPT='0'
DZMIN='250'
ZREFSFC='0.0'
DLAYER1='2000'
DLAYER2='12000'
STRHTUNE='4'

# simulation length in seconds
TSTOP='172800.0' #172800.0 = 48h #1800 =0.5h

# number of cpus used
XP='5' # x Proc
YP='5' # y Proc
YPXP=$(($XP*$YP))

# number of cpus used best performance is around 40-50 gridpoints tiles
# assuming dtbig=8 and dtsml=1
# 163**2*40 using 25 cpus ~ 1:6.44 (realtime : modeltime) fastest version with acceptable time/domain result for i5  
# 163**2*40 using 16 cpus ~ 1:4.85 (realtime : modeltime)
# 203**2*40 using 25 cpus ~ 1:4.45 (realtime : modeltime)
# 183**2*40 using 16 cpus ~ 1:3.82 (realtime : modeltime)


# corresponding openmpi hostfile for this setting
HOSTFILE='/home/'$USER'/hosts_all'

# domain centre and projections
CTRLAT='47.52' #'50.8' Marburg #'47.52' Sonthofen  #'46.247538' Tolmin
CTRLON='10.27' #'8.8'  Marburg #'10.27' Sonthofen  #'13.580618' Tolmin
TRULAT1='55.0'
TRULAT2='45.0'
TRULON=$CTRLON

# define parts of runname
RUNNAME='marburg_'
DOMAIN='d1'

# comments
CMNT1="'ARPS 5.3.3'"
CMNT2="'Testrun Marburg'"
CMNT3="'GFS External Boundaries'"

# id of generated ARPS domain
SECONDRUNEXT='_ARP'

#.......................................................................
### conversion parameters
#.......................................................................

# time intervall
TINT_DMPIN='1800.0'

# start time
TBG_DMPIN='000000.0'

# end time
TEND_DMPIN='005400.0'

# conversion output directory
CVTOUTDIR="'.\/'"

# file format
CVTOUTFMT='8' #8 netCDF onefile 9 grads 11 vis5d 7 netCDF single files

#.......................................................................
### string generation
#.......................................................................

# runname
NAMESTRING=$RUNNAME$DOMAIN

# header vor conversion
HDMPFHEADER=$NAMESTRING$SECONDRUNEXT

# getting datestring
YEAR4=`date -u +%Y`
YEAR2=`date -u +%y`
MONTH=`date -u +%m`
DAY=`date -u +%d`

# generate  initialstring format 2013-11-30 for arpsinput
INITIALSTRING=$YEAR4-$MONTH-$DAY

# generate  datestring format 13-11-30 for arpsinput
DATESTRING2=$YEAR2-$MONTH-$DAY

# generate  datestring 131130 for arpsinput
DATESTRING3=$YEAR2$MONTH$DAY

# format 20131130
DATESTRING=`date -u +%Y%m%d`

# generate  inittimestring format 2013-11-30.00:00:00 for ext2arps
INITTIMESTRING=$INITIALSTRING'.00:00:00'

#.......................................................................
### start of parameter substitution
#.......................................................................
   
# copy from template to current working file
cp /home/$USER/arpsinput/d1/d1_arp.input_template /home/$USER/arpsinput/d1/d1_arp.input
cp /home/$USER/arpsinput/d1/d1_trn.input_template /home/$USER/arpsinput/d1/d1_trn.input
cp /home/$USER/arpsinput/d1/d1_trn.input_template /home/$USER/arpsinput/d1/d1_cvt.input

# output conversion options
    
#  &history_data
sed "s/hdmpfheader_/hdmpfheader  = '.\/${HDMPFHEADER}',/" -i    /home/$USER/arpsinput/d1/d1_cvt.input
sed "s/tintv_dmpin_/tintv_dmpin  = ${TINT_DMPIN},/" -i          /home/$USER/arpsinput/d1/d1_cvt.input
sed "s/tbgn_dmpin_/tbgn_dmpin  = ${TBG_DMPIN},/" -i             /home/$USER/arpsinput/d1/d1_cvt.input
sed "s/tend_dmpin_/tend_dmpin  = ${TEND_DMPIN},/" -i            /home/$USER/arpsinput/d1/d1_cvt.input
sed "s/grdbasfn_/grdbasfn  = '${HDMPFHEADER}.bingrdbas',/" -i   /home/$USER/arpsinput/d1/d1_cvt.input

# &other_data
sed "s/terndta_/terndta  = '${NAMESTRING}_E2A.trndata',/" -i /home/$USER/arpsinput/d1/d1_cvt.input

# &output
sed "s/dirname_/dirname  = ${CVTOUTDIR},/" -i    			/home/$USER/arpsinput/d1/d1_cvt.input
sed "s/hdmpfmt_/ hdmpfmt  = ${CVTOUTFMT},/" -i    			/home/$USER/arpsinput/d1/d1_cvt.input
# END output conversion options

# terrain grid dimensions
sed "s/nx_/nx   = ${NX},/" -i    /home/$USER/arpsinput/d1/d1_trn.input
sed "s/ny_/ny   = ${NY},/" -i    /home/$USER/arpsinput/d1/d1_trn.input
sed "s/dx_/dx   = ${DX},/" -i    /home/$USER/arpsinput/d1/d1_trn.input
sed "s/dy_/dy   = ${DY},/" -i    /home/$USER/arpsinput/d1/d1_trn.input

# trn lat lon
sed "s/ctrlat_/ctrlat  = ${CTRLAT},/" -i    /home/$USER/arpsinput/d1/d1_trn.input
sed "s/ctrlon_/ctrlon  = ${CTRLON},/" -i    /home/$USER/arpsinput/d1/d1_trn.input

# trn map prj
sed "s/trulat1_/trulat1  = ${TRULAT1},/" -i /home/$USER/arpsinput/d1/d1_trn.input
sed "s/trulat2_/trulat2  = ${TRULAT2},/" -i /home/$USER/arpsinput/d1/d1_trn.input
sed "s/trulon_/trulon  = ${TRULON},/" -i    /home/$USER/arpsinput/d1/d1_trn.input

# TRN input string substituion 
sed "s/runname_/runname = '${NAMESTRING}_E2A',/" -i  /home/$USER/arpsinput/d1/d1_trn.input
# END TRN

# arps grid dimensions pay attention the atmo-strech-options are NOT changed
sed "s/dtbig_/dtbig   = ${DTBIG},/" -i    /home/$USER/arpsinput/d1/d1_arp.input
sed "s/dtsml_/dtsml   = ${DTSML},/" -i    /home/$USER/arpsinput/d1/d1_arp.input
sed "s/nx_/nx   = ${NX},/" -i    /home/$USER/arpsinput/d1/d1_arp.input
sed "s/ny_/ny   = ${NY},/" -i    /home/$USER/arpsinput/d1/d1_arp.input
sed "s/nz_/nz   = ${NZ},/" -i    /home/$USER/arpsinput/d1/d1_arp.input
sed "s/dx_:/dx   = ${DX},/" -i    /home/$USER/arpsinput/d1/d1_arp.input
sed "s/dy_:/dy   = ${DY},/" -i    /home/$USER/arpsinput/d1/d1_arp.input
sed "s/dz_:/dz   = ${DZ},/" -i    /home/$USER/arpsinput/d1/d1_arp.input
sed "s/dzmin_/dzmin   = ${DZMIN},/" -i    /home/$USER/arpsinput/d1/d1_arp.input
sed "s/strhopt_/strhopt   = ${STRHOPT},/" -i    /home/$USER/arpsinput/d1/d1_arp.input
sed "s/zrefsfc_/zrefsfc  = ${ZREFSFC},/" -i    /home/$USER/arpsinput/d1/d1_arp.input
sed "s/dlayer1_/dlayer1  = ${DLAYER1},/" -i    /home/$USER/arpsinput/d1/d1_arp.input
sed "s/dlayer2_/dlayer2  = ${DLAYER2},/" -i    /home/$USER/arpsinput/d1/d1_arp.input
sed "s/strhtune_/strhtune  = ${STRHTUNE},/" -i    /home/$USER/arpsinput/d1/d1_arp.input

# arps mpi number of processors
sed "s/nproc_x_/nproc_x = ${XP},/" -i    /home/$USER/arpsinput/d1/d1_arp.input
sed "s/nproc_y_/nproc_y = ${YP},/" -i    /home/$USER/arpsinput/d1/d1_arp.input

# arps lat lon
sed "s/ctrlat_/ctrlat  = ${CTRLAT},/" -i    /home/$USER/arpsinput/d1/d1_arp.input
sed "s/ctrlon_/ctrlon  = ${CTRLON},/" -i    /home/$USER/arpsinput/d1/d1_arp.input
sed "s/trulat1_/trulat1  = ${TRULAT1},/" -i    /home/$USER/arpsinput/d1/d1_arp.input
sed "s/trulat2_/trulat2  = ${TRULAT2},/" -i    /home/$USER/arpsinput/d1/d1_arp.input
sed "s/trulon_/trulon  = ${TRULON},/" -i    /home/$USER/arpsinput/d1/d1_arp.input

# arps string substituion 
sed "s/runname_/runname = '${NAMESTRING}_E2A',/" -i  /home/$USER/arpsinput/d1/d1_arp.input
sed "s/cmnt(1)_/cmnt(1) = ${CMNT1},/" -i    /home/$USER/arpsinput/d1/d1_arp.input
sed "s/cmnt(2)_/cmnt(2) = ${CMNT2},/" -i    /home/$USER/arpsinput/d1/d1_arp.input
sed "s/cmnt(3)_/cmnt(3) = ${CMNT3},/" -i    /home/$USER/arpsinput/d1/d1_arp.input
sed "s/initime_/initime = '${INITTIMESTRING}',/" -i    /home/$USER/arpsinput/d1/d1_arp.input
sed "s/tinitebd_/tinitebd = '${INITTIMESTRING}',/" -i    /home/$USER/arpsinput/d1/d1_arp.input
sed "s/dir_extd_/dir_extd = '${EXTDATAPATH}${DATESTRING}\/gfs',/" -i    /home/$USER/arpsinput/d1/d1_arp.input
sed "s/rstinf_/rstinf = '${NAMESTRING}.rst003600',/" -i  /home/$USER/arpsinput/d1/d1_arp.input 
sed "s/inifile_/inifile = '${NAMESTRING}_E2A.bin000000',/" -i  /home/$USER/arpsinput/d1/d1_arp.input 
sed "s/inigbf_/inigbf = '${NAMESTRING}_E2A.bingrdbas',/" -i  /home/$USER/arpsinput/d1/d1_arp.input 
sed "s/terndta_/terndta = '${NAMESTRING}_E2A.trndata',/" -i  /home/$USER/arpsinput/d1/d1_arp.input 
sed "s/exbcname_/exbcname = '${NAMESTRING}_E2A',/" -i  /home/$USER/arpsinput/d1/d1_arp.input 
sed "s/sfcdtfl_/sfcdtfl = '${NAMESTRING}_E2A.sfcdata',/" -i  /home/$USER/arpsinput/d1/d1_arp.input 
sed "s/soilinfl_/soilinfl = '${NAMESTRING}_E2A.soilvar.000000',/" -i  /home/$USER/arpsinput/d1/d1_arp.input 
sed "s/sndfile_/sndfile = '${NAMESTRING}_E2A.snd',/" -i  /home/$USER/arpsinput/d1/d1_arp.input 
sed "s/tstop_/tstop = ${TSTOP},/" -i  /home/$USER/arpsinput/d1/d1_arp.input 


#.......................................................................
### start of simulation run
#.......................................................................

# generate runtimedirectory 
mkdir -p  /home/$USER/run_$ARPS/$INITIALSTRING/$NAMESTRING

# move to runtimedirectory
cd /home/$USER/run_$ARPS/$INITIALSTRING/$NAMESTRING

pwd

# delete all
rm *
# define filenames that like to disappear as tests
test1=${NAMESTRING}'_E2A.bin000000'
test2=${NAMESTRING}'_E2A.bingrdbas'
check=1


	
# call gribmaster to check/get the GFS files
/home/$USER/$ARPS/gribmaster/gribmaster --dset gfs004grb2 #--date %date 	

# call DEM import
/home/$USER/$ARPS/bin/arpstrn < /home/$USER/arpsinput/d1/d1_trn.input
	
#call surface generator -> soil and vegetation
/home/$USER/$ARPS/bin/arpssfc  < /home/$USER/arpsinput/d1/d1_arp.input


while [ $check != 0 ]
	
	do
	# first call of ext2arps 
	sed "s/extdname_/extdname = '${DATESTRING3}00.gfs',/" -i    /home/$USER/arpsinput/d1/d1_arp.input
	sed "s/extdtime(1)_/extdtime(1) = '${INITTIMESTRING}+000:00:00',/" -i    /home/$USER/arpsinput/d1/d1_arp.input
	/home/$USER/$ARPS/bin/ext2arps < /home/$USER/arpsinput/d1/d1_arp.input

	# check if the basegrid was correctly generated if not repeat this step
	if [ -f $test1 ]
	then
		if [ -f $test2 ]
		then
			check=0
		fi
	fi
done


# we have to loop this due to a ext2arps bug (problably gfortran driven)
# first we want to stop generating more of the basegrids  
sed "s/grdbasopt = 1,/grdbasopt = 0,/" -i  /home/$USER/arpsinput/d1/d1_arp.input
oldtstr='+000:00:00'
for timeext in "+006:00:00" "+012:00:00" "+018:00:00" "+024:00:00" "+030:00:00" "+036:00:00" "+042:00:00" "+048:00:00"
  do
    newtstr=$timeext
	sed "s/${oldtstr}/${newtstr}/" -i    /home/$USER/arpsinput/d1/d1_arp.input
	/home/$USER/$ARPS/bin/ext2arps < /home/$USER/arpsinput/d1/d1_arp.input
    oldtstr=$timeext
done


# before simulation run replace runname to distinguish the two runs of importing Boundary data by  ext2arps (E2A) and arps simulation run (ARP)
sed "s/runname = '${NAMESTRING}_E2A',/runname = '${HDMPFHEADER}',/" -i  /home/$USER/arpsinput/d1/d1_arp.input

# start simulation run
nohup mpirun  -default-hostfile none -hostfile $HOSTFILE  -n $YPXP  /home/$USER/$ARPS/bin/arps_mpi /home/$USER/arpsinput/d1/d1_arp.input &
#echo $YPXP
#echo $HOSTFILE
#/usr/lib64/mpi/gcc/openmpi/bin/mpirun  -default-hostfile none -hostfile $HOSTFILE  -n $YPXP  /home/$USER/$ARPS/bin/arps_mpi   /home/$USER/arpsinput/d1/d1_arp.input  > out
