#!/bin/bash 
# author Chris Reudenbach (2013)
# version 2015/05/23
# script to setup an arbitrary ARPS run using GFS boundary data

source $HOME/.bashrc
#.......................................................................
### define settings
#.......................................................................

# identify what "type" of user you are 
USER=`whoami`

# set used  ARPS directory
ARPS="arps5.3.3"

# set external datapath (currently GFS)
EXTDATAPATH='\/home\/'$USER'\/initialgfs\/'

# simulation length in seconds
TSTOP='172800.0' #'21600.0' #'172800.0' #'172800.0' #'172800.0' #172800.0 = 48h #1800 =0.5h
# external data slots
declare -a timeext=("+003:00:00" "+006:00:00" "+009:00:00" "+012:00:00" "+015:00:00" "+018:00:00"  "+021:00:00" "+024:00:00" "+027:00:00" "+030:00:00" "+033:00:00" "+036:00:00" "+039:00:00" "+042:00:00" "+045:00:00" "+048:00:00")


# define if 25 or 50 GFS is used
GFS='25'

if [ $GFS -eq 50 ]
	then 
	INITMOD='\/gfs50'
	EXTDOPT='20'
	CMNT3="'GFS 0.5 external boundary'"
else
	INITMOD='\/gfs25'
	EXTDOPT='33'
	CMNT3="'GFS 0.25 external boundary'"
fi

### be careful in adjusting size resolution and time depends on each other
### http://www.ce.berkeley.edu/~chow/pubs/Chow_etal_RivieraPartI_JAMC2006.pdf
###  x   y   z   xres   zmin        zave     height       dtbig dtsml
### 103x103x53  9 km     50 m     500 m      25 km       10 s/10 s
### 103x103x53  3 km     50 m     500 m      25 km         2 s/4 s
###  99x99x63   1 km     50 m     400 m      24 km         1 s/1 s
###  83x83x63 350 m      30 m     350 m      21 km         1 s/0.2 s
###  67x99x83 150 m      20 m     200 m      16 km      0.5 s/0.05 s

# big timestep 
# small timestep has to be even due to RBcopt3 =DTBIG/2 /4 /6...
DTBIG='8.0'
DTSML='1.0'

# number of CPUs best performance seems to be about 30-50 gridpoints/tile
# strongly depending on how much files are written!
# assuming dtbig=8 and dtsml=1 (not possible with a soilmodel option!)
# 163**2*40 using 25 cpus ~ 1:6.44 (realtime : modeltime) fastest version with acceptable time/domain result for i5  
# 163**2*40 using 16 cpus ~ 1:4.85 (realtime : modeltime)
# 203**2*40 using 25 cpus ~ 1:4.45 (realtime : modeltime)
# 183**2*40 using 16 cpus ~ 1:3.82 (realtime : modeltime)

# number of CPUs to use
XP='6' # x Proc
YP='6' # y Proc
YPXP=$(($XP*$YP))
# corresponding openmpi hostfile for this setting
HOSTFILE='/home/'$USER'/h36'

# Domainsize in gridpoints (realsize+3)
NX='243' #'213' #'203' #163  #203 #183 #219 *6
NY='243' #'213' #'203' #163  #203 #183 #219 *6
NZ='60' 

# fix domain resolution
DX='3000.0' # x res in Meter
DY='3000.0' # y res in Meter
DZ='500.0'  # z res in Meter


# vertical streching options for dz
STRHOPT='2'
DZMIN='50.0'
ZREFSFC='0.0'
DLAYER1='0.0'
DLAYER2='0.0'
STRHTUNE='4.1'
ZFLAT='1.0e5'

# domain centre 
#'-3.064675' Kilimanjaro #'50.918317' Entenberg,  #'50.4983' Wasserkuppe,  #'50.8' Marburg,  #'47.52' Sonthofen,  #'46.247538' Tolmin
#'37.358213' Kilimanjaro #'8.4335070' Entenberg,  # '9.9370' Wasserkuppe,   #'8.8' Marburg,  #'10.27' Sonthofen,  #'13.580618' Tolmin
CTRLAT='-3.064675' #Kilimanjaro #'50.918317' Entenberg,  #'50.4983' Wasserkuppe,  #'50.8' Marburg,  #'47.52' Sonthofen,  #'46.247538' Tolmin
CTRLON='37.358213' #Kilimanjaro #'8.4335070' Entenberg,  # '9.9370' Wasserkuppe,   #'8.8' Marburg,  #'10.27' Sonthofen,  #'13.580618' Tolmin

# map projections
# is an ugly topic and actually I cant belief it
# obviously there are compiler or memory heap problems with this 
# (and some more) issue http://www.caps.ou.edu/pipermail/arpssupport/2013-June/011477.html
# this error occures in about 10-20%  EVEN with MAPPROJ='0' 
# Which doese not make sense if you look into the source code so we bypass 
# "arpsstop" calls by commenting them in the arps/mapproj3d.f90 
# NOTE In this case YOU **HAVE** TO USE MAPPROJ='0'  
# 
MAPPROJ='0' # 0, no map projection; 1, North polar projection (-1 South Pole); 2, Northern Lambert projection (-2 Southern); 3, Mercator projection
TRULAT1='20.0'
TRULAT2='30.0'
TRULON=$CTRLON

# define parts of runname
RUNNAME='kilimanjaro_'
DOMAIN='d1'
ARP='_arp'
CVT='_cvt'
TRN='_trn'

# generate arps specific comments
CMNT1="'Modified $ARPS Info: http:\/\/giswerk.org\/wac:modeling:arps:intro'"
# generate the runspecific comment line
CMNT2="'$RUNNAME$DOMAIN, $DX m, $DZ m, proj\=$MAPPROJ (0\=no; 1\/-1\=North\/South pol 2\/-2\=N\/Slcc; 3\=Merc)'"


# id of generated ARPS domain
SECONDRUNEXT='_ARP'

#.......................................................................
### conversion parameters
#.......................................................................

# time intervall
TINT_DMPIN='3600.0'

# start time
TBG_DMPIN='000000.0'

# end time
TEND_DMPIN=$TSTOP #'162000' #'172800.0' #'005400.0'

# conversion output directory
CVTOUTDIR="'.\/'"

# output file format
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
cp /home/$USER/arpsinput/d1/src/$DOMAIN$ARP.input_template /home/$USER/arpsinput/d1/$DOMAIN$ARP.input
cp /home/$USER/arpsinput/d1/src/$DOMAIN$TRN.input_template /home/$USER/arpsinput/d1/$DOMAIN$TRN.input
cp /home/$USER/arpsinput/d1/src/$DOMAIN$CVT.input_template /home/$USER/arpsinput/d1/$DOMAIN$CVT.input

# output conversion options
    
#  &history_data
sed "s/hdmpfheader_/hdmpfheader  = '.\/${HDMPFHEADER}',/" -i    /home/$USER/arpsinput/d1/$DOMAIN$CVT.input
sed "s/tintv_dmpin_/tintv_dmpin  = ${TINT_DMPIN},/" -i          /home/$USER/arpsinput/d1/$DOMAIN$CVT.input
sed "s/tbgn_dmpin_/tbgn_dmpin  = ${TBG_DMPIN},/" -i             /home/$USER/arpsinput/d1/$DOMAIN$CVT.input
sed "s/tend_dmpin_/tend_dmpin  = ${TEND_DMPIN},/" -i            /home/$USER/arpsinput/d1/$DOMAIN$CVT.input
sed "s/grdbasfn_/grdbasfn  = '${HDMPFHEADER}.bingrdbas',/" -i   /home/$USER/arpsinput/d1/$DOMAIN$CVT.input

sed "s/outrunname_/outrunname = '${NAMESTRING}_ARP',/" -i  /home/$USER/arpsinput/d1/$DOMAIN$CVT.input

# &other_data
sed "s/terndta_/terndta  = '${NAMESTRING}_E2A.trndata',/" -i /home/$USER/arpsinput/d1/$DOMAIN$CVT.input
sed "s/sfcdtfl_/sfcdtfl  = '${NAMESTRING}_E2A.sfcdata',/" -i /home/$USER/arpsinput/d1/$DOMAIN$CVT.input


# &output
sed "s/dirname_/dirname  = ${CVTOUTDIR},/" -i /home/$USER/arpsinput/d1/$DOMAIN$CVT.input
sed "s/hdmpfmt_/ hdmpfmt  = ${CVTOUTFMT},/" -i /home/$USER/arpsinput/d1/$DOMAIN$CVT.input
# END output conversion options

# terrain grid dimensions
sed "s/nx_/nx   = ${NX},/" -i    /home/$USER/arpsinput/d1/$DOMAIN$TRN.input
sed "s/ny_/ny   = ${NY},/" -i    /home/$USER/arpsinput/d1/$DOMAIN$TRN.input
sed "s/dx_/dx   = ${DX},/" -i    /home/$USER/arpsinput/d1/$DOMAIN$TRN.input
sed "s/dy_/dy   = ${DY},/" -i    /home/$USER/arpsinput/d1/$DOMAIN$TRN.input

# trn lat lon
sed "s/ctrlat_/ctrlat  = ${CTRLAT},/" -i    /home/$USER/arpsinput/d1/$DOMAIN$TRN.input
sed "s/ctrlon_/ctrlon  = ${CTRLON},/" -i    /home/$USER/arpsinput/d1/$DOMAIN$TRN.input

# trn map prj 
sed "s/mapproj_/mapproj  = ${MAPPROJ},/" -i /home/$USER/arpsinput/d1/$DOMAIN$TRN.input
sed "s/trulat1_/trulat1  = ${TRULAT1},/" -i /home/$USER/arpsinput/d1/$DOMAIN$TRN.input
sed "s/trulat2_/trulat2  = ${TRULAT2},/" -i /home/$USER/arpsinput/d1/$DOMAIN$TRN.input
sed "s/trulon_/trulon  = ${TRULON},/" -i    /home/$USER/arpsinput/d1/$DOMAIN$TRN.input

# TRN input string substituion 
sed "s/runname_/runname = '${NAMESTRING}_E2A',/" -i  /home/$USER/arpsinput/d1/$DOMAIN$TRN.input


# END TRN

# arps grid dimensions pay attention the atmo-strech-options are NOT changed
sed "s/dtbig_/dtbig   = ${DTBIG},/" -i    /home/$USER/arpsinput/d1/$DOMAIN$ARP.input
sed "s/dtsml_/dtsml   = ${DTSML},/" -i    /home/$USER/arpsinput/d1/$DOMAIN$ARP.input
sed "s/nx_/nx   = ${NX},/" -i    /home/$USER/arpsinput/d1/$DOMAIN$ARP.input
sed "s/ny_/ny   = ${NY},/" -i    /home/$USER/arpsinput/d1/$DOMAIN$ARP.input
sed "s/nz_/nz   = ${NZ},/" -i    /home/$USER/arpsinput/d1/$DOMAIN$ARP.input
sed "s/dx_:/dx   = ${DX},/" -i    /home/$USER/arpsinput/d1/$DOMAIN$ARP.input
sed "s/dy_:/dy   = ${DY},/" -i    /home/$USER/arpsinput/d1/$DOMAIN$ARP.input
sed "s/dz_:/dz   = ${DZ},/" -i    /home/$USER/arpsinput/d1/$DOMAIN$ARP.input
sed "s/dzmin_/dzmin   = ${DZMIN},/" -i    /home/$USER/arpsinput/d1/$DOMAIN$ARP.input
sed "s/strhopt_/strhopt   = ${STRHOPT},/" -i    /home/$USER/arpsinput/d1/$DOMAIN$ARP.input
sed "s/zrefsfc_/zrefsfc  = ${ZREFSFC},/" -i    /home/$USER/arpsinput/d1/$DOMAIN$ARP.input
sed "s/dlayer1_/dlayer1  = ${DLAYER1},/" -i    /home/$USER/arpsinput/d1/$DOMAIN$ARP.input
sed "s/dlayer2_/dlayer2  = ${DLAYER2},/" -i    /home/$USER/arpsinput/d1/$DOMAIN$ARP.input
sed "s/strhtune_/strhtune  = ${STRHTUNE},/" -i    /home/$USER/arpsinput/d1/$DOMAIN$ARP.input
sed "s/zflat_/zflat  = ${ZFLAT},/" -i    /home/$USER/arpsinput/d1/$DOMAIN$ARP.input
 
# arps mpi number of processors
sed "s/nproc_x_/nproc_x = ${XP},/" -i    /home/$USER/arpsinput/d1/$DOMAIN$ARP.input
sed "s/nproc_y_/nproc_y = ${YP},/" -i    /home/$USER/arpsinput/d1/$DOMAIN$ARP.input
 
# arps lat lon
sed "s/mapproj_/mapproj  = ${MAPPROJ},/" -i /home/$USER/arpsinput/d1/$DOMAIN$ARP.input
sed "s/ctrlat_/ctrlat  = ${CTRLAT},/" -i    /home/$USER/arpsinput/d1/$DOMAIN$ARP.input
sed "s/ctrlon_/ctrlon  = ${CTRLON},/" -i    /home/$USER/arpsinput/d1/$DOMAIN$ARP.input
sed "s/trulat1_/trulat1  = ${TRULAT1},/" -i    /home/$USER/arpsinput/d1/$DOMAIN$ARP.input
sed "s/trulat2_/trulat2  = ${TRULAT2},/" -i    /home/$USER/arpsinput/d1/$DOMAIN$ARP.input
sed "s/trulon_/trulon  = ${TRULON},/" -i    /home/$USER/arpsinput/d1/$DOMAIN$ARP.input
 
# arps string substituion 
sed "s/runname_/runname = '${NAMESTRING}_E2A',/" -i  /home/$USER/arpsinput/d1/$DOMAIN$ARP.input
sed "s/cmnt(1)_/cmnt(1) = ${CMNT1},/" -i    /home/$USER/arpsinput/d1/$DOMAIN$ARP.input
sed "s/cmnt(2)_/cmnt(2) = ${CMNT2},/" -i    /home/$USER/arpsinput/d1/$DOMAIN$ARP.input
sed "s/cmnt(3)_/cmnt(3) = ${CMNT3},/" -i    /home/$USER/arpsinput/d1/$DOMAIN$ARP.input
sed "s/initime_/initime = '${INITTIMESTRING}',/" -i    /home/$USER/arpsinput/d1/$DOMAIN$ARP.input
sed "s/tinitebd_/tinitebd = '${INITTIMESTRING}',/" -i    /home/$USER/arpsinput/d1/$DOMAIN$ARP.input
sed "s/extdopt_/extdopt = ${EXTDOPT},/" -i    /home/$USER/arpsinput/d1/$DOMAIN$ARP.input

sed "s/dir_extd_/dir_extd = '${EXTDATAPATH}${DATESTRING}${INITMOD}',/" -i    /home/$USER/arpsinput/d1/$DOMAIN$ARP.input
sed "s/rstinf_/rstinf = '${NAMESTRING}.rst003600',/" -i  /home/$USER/arpsinput/d1/$DOMAIN$ARP.input 
sed "s/inifile_/inifile = '${NAMESTRING}_E2A.bin000000',/" -i  /home/$USER/arpsinput/d1/$DOMAIN$ARP.input 
sed "s/inigbf_/inigbf = '${NAMESTRING}_E2A.bingrdbas',/" -i  /home/$USER/arpsinput/d1/$DOMAIN$ARP.input 
sed "s/terndta_/terndta = '${NAMESTRING}_E2A.trndata',/" -i  /home/$USER/arpsinput/d1/$DOMAIN$ARP.input 
sed "s/exbcname_/exbcname = '${NAMESTRING}_E2A',/" -i  /home/$USER/arpsinput/d1/$DOMAIN$ARP.input 
sed "s/sfcdtfl_/sfcdtfl = '${NAMESTRING}_E2A.sfcdata',/" -i  /home/$USER/arpsinput/d1/$DOMAIN$ARP.input 
sed "s/soilinfl_/soilinfl = '${NAMESTRING}_E2A.soilvar.000000',/" -i  /home/$USER/arpsinput/d1/$DOMAIN$ARP.input 
sed "s/sndfile_/sndfile = '${NAMESTRING}_E2A.snd',/" -i  /home/$USER/arpsinput/d1/$DOMAIN$ARP.input 
sed "s/tstop_/tstop = ${TSTOP},/" -i  /home/$USER/arpsinput/d1/$DOMAIN$ARP.input 

#.......................................................................
### start of exececutable part 
#.......................................................................

# create runtime directory for the today simulation
mkdir -p  /home/$USER/run_$ARPS/$INITIALSTRING/$NAMESTRING

# change directory to runtimedirectory   
cd /home/$USER/run_$ARPS/$INITIALSTRING/$NAMESTRING

# NOTE DELETE ALL FILES in current date folder
shopt -s nullglob
shopt -s dotglob # To include hidden files
files=(/home/$USER/run_$ARPS/$INITIALSTRING/$NAMESTRING/*)
if [ ${#files[@]} -gt 0 ]; then rm -r *; fi

# copy input files to corresponding data directory 
cp  /home/$USER/arpsinput/d1/$DOMAIN$CVT.input /home/$USER/run_$ARPS/$INITIALSTRING/$NAMESTRING/$DOMAIN$CVT.input
cp  /home/$USER/arpsinput/d1/$DOMAIN$TRN.input /home/$USER/run_$ARPS/$INITIALSTRING/$NAMESTRING/$DOMAIN$TRN.input
cp  /home/$USER/arpsinput/d1/$DOMAIN$ARP.input /home/$USER/run_$ARPS/$INITIALSTRING/$NAMESTRING/$DOMAIN$ARP.input 
cp  /home/$USER/arpsinput/d1/src/run_d1.sh /home/$USER/run_$ARPS/$INITIALSTRING/$NAMESTRING/run_d1.sh



# if the seperate script "get_gfs.sh"  that runs with an cron job 
# has failed this call is the second chance to get the boundary input data 
# gribmaster will check/get the GFS files if available
# gribmaster will stop at once if the files exist 
#/home/$USER/$ARPS/gribmaster/gribmaster --dset ggfs025grb2 #--date %date 	
/home/$USER/arpsinput/d1/src/./get_gfs.sh

#.......................................................................
### start of simulation run
#.......................................................................

# call DEM import
/home/$USER/$ARPS/bin/arpstrn < /home/$USER/arpsinput/d1/$DOMAIN$TRN.input

# call surface generator -> soil and vegetation
/home/$USER/$ARPS/bin/arpssfc  < /home/$USER/arpsinput/d1/$DOMAIN$ARP.input

# the while construct make sense due to fact that the first run is obligatory  
# for the two base grids next check if these files '.bin000000', 'bingrdbas' 
# are correctly derived and if not repeat until they exist 
# Even if all files are correct sometimes the basefiles are gone (no idea why)
# so we define the runtime names of this candidates  that like to "disappear" 
# during the ext2arps conversion  
# ***FIXME*** BECAUSE IOF SETMAP error
test1=${NAMESTRING}'_E2A.bin000000'
test2=${NAMESTRING}'_E2A.bingrdbas'
# the boolean varname for checking
check=1

# first call of ext2arps 
while [ $check != 0 ]
	do
	sed "s/extdname_/extdname = '${DATESTRING3}00.gfs',/" -i    /home/$USER/arpsinput/d1/$DOMAIN$ARP.input
	sed "s/extdtime(1)_/extdtime(1) = '${INITTIMESTRING}+000:00:00',/" -i    /home/$USER/arpsinput/d1/$DOMAIN$ARP.input
	/home/$USER/$ARPS/bin/ext2arps  /home/$USER/arpsinput/d1/$DOMAIN$ARP.input
	# check now if the basegrids were correctly generated if not repeat this step
	if [ -f $test1 ]
	then
		if [ -f $test2 ]
		then
			check=0
		fi
	fi
done

# Import all necessary boundary input data this loop is usually provided
# by ARPS itself but in the gfortran version it doesn't work 
# we have to loop this due to a ext2arps bug (problably gfortran driven)


# first we want to stop generating more than one couple of basegrids  
sed "s/grdbasopt = 1,/grdbasopt = 0,/" -i  /home/$USER/arpsinput/d1/$DOMAIN$ARP.input
# set the first/oldstring
oldtstr='+000:00:00'

# for all 
echo "${#timeext[@]} more GFS files in line...."
for i in `seq 1 $((${#timeext[@]}-1))`;
# for timeext in  "+003:00:00" "+006:00:0" "+009:00:00" "+012:00:00" "+015:00:00" "+018:00:00"  "+021:00:00" "+024:00:00" "+027:00:00" "+030:00:00" "+033:00:00" "+036:00:00" "+039:00:00" "+042:00:00" "+045:00:00" "+048:00:00"
	do
		echo "processing file $i of ${#timeext[@]}"
		newtstr=${timeext[$i]}
		sed "s/${oldtstr}/${newtstr[i]}/" -i    /home/$USER/arpsinput/d1/$DOMAIN$ARP.input
		/home/$USER/$ARPS/bin/ext2arps < /home/$USER/arpsinput/d1/$DOMAIN$ARP.input | grep 'Normal successful completion of EXT2ARPS'
		i=$((i+1))
		oldtstr=$newtstr
	done

### up to this point all boundary conditions for the simulation run are interpolated

### before simulation run we replace the 'runname' from (E2A) boundary run to (ARP)  ARPS simulation run 
sed "s/runname = '${NAMESTRING}_E2A',/runname = '${HDMPFHEADER}',/" -i  /home/$USER/arpsinput/d1/$DOMAIN$ARP.input

# now we start the forecast simulation run i.e. we are using the parallel version arps_mpi
echo 'You are using '$YPXP' CPUs'


# start arps simulation run
#### nohup /usr/lib64/mpi/gcc/openmpi/bin/mpirun  -default-hostfile none -hostfile $HOSTFILE  -n $YPXP  /home/$USER/$ARPS/bin/arps_mpi   /home/$USER/arpsinput/d1/$DOMAIN$ARP.input > run.log &
#### start controlscript for postprocessing
#### nohup /home/$USER/arpsinput/d1/src/control.sh $USER $ARPS $RUNNAME $DOMAIN $NAMESTRING $INITIALSTRING $SECONDRUNEXT $DOMAIN$CVT &

# this is an ugly call to bring all lined up in a seperate shell with nohup
# ***FIXME*** as soon as I know how
nohup bash -c "source $HOME/.bashrc && \
               export USER=$USER export ARPS=$ARPS RUNNAME=$RUNNAME DOMAIN=$DOMAIN NAMESTRING=$NAMESTRING INITIALSTRING=$INITIALSTRING SECONDRUNEXT=$SECONDRUNEXT DOMAIN$CVT=$DOMAIN$CVT HOSTFILE=$HOSTFILE YPXP=$YPXP && \
               /usr/lib64/mpi/gcc/openmpi/bin/mpirun  -default-hostfile none -hostfile $HOSTFILE  -n $YPXP  /home/$USER/$ARPS/bin/arps_mpi   /home/$USER/arpsinput/d1/$DOMAIN$ARP.input > run.log && \
               /home/$USER/arpsinput/d1/src/./control.sh $USER $ARPS $RUNNAME $DOMAIN $NAMESTRING $INITIALSTRING $SECONDRUNEXT $DOMAIN$CVT" &
FOO_PID=$!
echo "$RUNNAME$DOMAIN setup finished: - simulation with process number $FOO_PID started"

