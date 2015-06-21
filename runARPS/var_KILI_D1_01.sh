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
RUNNAME='kili_'
DOMAIN='d1'
ARP='_arp'
CVT='_cvt'
TRN='_trn'

# generate arps specific comments
CMNT1="'Modified $ARPS Info: http:\/\/giswerk.org\/wac:modeling:arps:intro'"
# generate the runspecific comment line
CMNT2="'$RUNNAME$DOMAIN, $DX m, $DZ m, proj\=$MAPPROJ (0\=no; 1\/-1\=North\/South pol 2\/-2\=N\/Slcc; 3\=Merc)'"


# id of generated ARPS domain
SECONDRUNEXT='_F01'

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



export USER=$USER 
export ARPS=$ARPS 
export RUNNAME=$RUNNAME 
export DOMAIN=$DOMAIN 
export NAMESTRING=$NAMESTRING 
export INITIALSTRING=$INITIALSTRING 
export SECONDRUNEXT=$SECONDRUNEXT 
export DOMAIN$CVT=$DOMAIN$CVT 
export HOSTFILE=$HOSTFILE 
export YPXP=$YPXP 
export INITTIMESTRING=$INITTIMESTRING
export DATESTRING=$DATESTRING
export DATESTRING3=$DATESTRING3
export DATESTRING2=$DATESTRING2
export HDMPFHEADER=$HDMPFHEADER
export CVTOUTFMT=$CVTOUTFMT
export CVTOUTDIR=$CVTOUTDIR
export TEND_DMPIN=$TEND_DMPIN
export TBG_DMPIN=$TEND_DMPIN
export TINT_DMPIN=$TEND_DMPIN
export CMNT1=$CMNT1
export CMNT2=$CMNT2
export CMNT3=$CMNT3
export ARP=$ARP
export CVT=$CVT
export TRN=$TRN
export MAPPROJ=$MAPPROJ
export TRULAT1=$TRULAT1
export TRULAT2=$TRULAT2
export TRULON=$TRULON
export CTRLAT=$CTRLAT
export CTRLON=$CTRLON
export EXTDATAPATH=$EXTDATAPATH
export TSTOP=$TSTOP
export timeext=$timeext
export INITMOD=$INITMOD
export EXTDOPT=$EXTDOPT
export DTBIG=$DTBIG
export DTSML=$DTSML
export YPXP=$YPXP
export HOSTFILE=$HOSTFILE
export NX=$NX
export NY=$NY
export NZ=$NZ 
export DX=$DX
export DY=$DY
export DZ=$DZ
export STRHOPT=$STRHOPT
export DZMIN=$DZMIN
export ZREFSFC=$ZREFSFC
export DLAYER1=$DLAYER1
export DLAYER2=$DLAYER2
export STRHTUNE=$STRHTUNE
export ZFLAT=$ZFLAT
