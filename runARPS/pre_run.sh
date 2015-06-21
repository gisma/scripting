#!/bin/bash 
# author Chris Reudenbach (2013)
# version 2015/05/23
# script to setup an arbitrary ARPS run using GFS boundary data

if [[ "$1" == '-h' ]]; then
    echo "Usage: ./pre_run.sh -h brief help | <setup file> <keep-switch> "
    echo""
    echo "<setup file>:  i.e.  '/home/arpsuser/arpsinput/d1/src/KILI_D1_01.sh' "
    echo "<keep-switch>  true  delete existing preprocessed files in target directory (recommended) "
    echo "               false keep existing preprocessed files in target directory"
    echo "example:       ~/arpsinput/d1/src/./pre_run.sh  '/home/arpsuser/arpsinput/d1/src/KILI_D1_01.sh' true "
    exit 0
elif [ "$#" -ne 2 ]; then
    echo "Usage: ./pre_run.sh -h brief help | <setup file> <keep-switch> "
    echo " "
    exit 0
fi


# source the .bashrc file for the env variables
source $HOME/.bashrc 

# source the simulation specific setup file
source $1

# source the list of the external data slots
source /home/$USER/$ARPSINDIR/$DOMAIN/$SRC/ExtDataSlots.array


#.......................................................................
### start of parameter substitution
#.......................................................................


   
# copy from template to current working file
cp /home/$USER/$ARPSINDIR/$DOMAIN/$SRC/$DOMAIN$ARP.input_template /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$ARP.input
cp /home/$USER/$ARPSINDIR/$DOMAIN/$SRC/$DOMAIN$TRN.input_template /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$TRN.input
cp /home/$USER/$ARPSINDIR/$DOMAIN/$SRC/$DOMAIN$CVT.input_template /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$CVT.input

# output conversion options
    
#  &history_data
sed "s/hdmpfheader_/hdmpfheader  = '.\/${HDMPFHEADER}',/" -i    /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$CVT.input
sed "s/tintv_dmpin_/tintv_dmpin  = ${TINT_DMPIN},/" -i          /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$CVT.input
sed "s/tbgn_dmpin_/tbgn_dmpin  = ${TBG_DMPIN},/" -i             /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$CVT.input
sed "s/tend_dmpin_/tend_dmpin  = ${TEND_DMPIN},/" -i            /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$CVT.input
sed "s/grdbasfn_/grdbasfn  = '${HDMPFHEADER}.bingrdbas',/" -i   /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$CVT.input

#sed "s/outrunname_/outrunname = '${NAMESTRING}_ARP',/" -i  /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$CVT.input

# &other_data
sed "s/terndta_/terndta  = '${NAMESTRING}_E2A.trndata',/" -i /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$CVT.input
sed "s/sfcdtfl_/sfcdtfl  = '${NAMESTRING}_E2A.sfcdata',/" -i /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$CVT.input
sed "s/soilinfl_/soilinfl = '${NAMESTRING}_E2A.soilvar',/" -i  /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$CVT.input 

# &output
sed "s/dirname_/dirname  = ${CVTOUTDIR},/" -i /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$CVT.input
sed "s/hdmpfmt_/ hdmpfmt  = ${CVTOUTFMT},/" -i /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$CVT.input

# END output conversion options

# terrain grid dimensions
sed "s/nx_/nx   = ${NX},/" -i    /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$TRN.input
sed "s/ny_/ny   = ${NY},/" -i    /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$TRN.input
sed "s/dx_/dx   = ${DX},/" -i    /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$TRN.input
sed "s/dy_/dy   = ${DY},/" -i    /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$TRN.input

# trn lat lon
sed "s/ctrlat_/ctrlat  = ${CTRLAT},/" -i    /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$TRN.input
sed "s/ctrlon_/ctrlon  = ${CTRLON},/" -i    /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$TRN.input

# trn map prj 
sed "s/mapproj_/mapproj  = ${MAPPROJ},/" -i /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$TRN.input
sed "s/trulat1_/trulat1  = ${TRULAT1},/" -i /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$TRN.input
sed "s/trulat2_/trulat2  = ${TRULAT2},/" -i /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$TRN.input
sed "s/trulon_/trulon  = ${TRULON},/" -i    /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$TRN.input

# TRN input string substituion 
sed "s/runname_/runname = '${NAMESTRING}_E2A',/" -i  /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$TRN.input


# END TRN

# arps grid dimensions pay attention the atmo-strech-options are NOT changed
sed "s/dtbig_/dtbig   = ${DTBIG},/" -i    /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$ARP.input
sed "s/dtsml_/dtsml   = ${DTSML},/" -i    /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$ARP.input
sed "s/nx_/nx   = ${NX},/" -i    /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$ARP.input
sed "s/ny_/ny   = ${NY},/" -i    /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$ARP.input
sed "s/nz_/nz   = ${NZ},/" -i    /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$ARP.input
sed "s/dx_:/dx   = ${DX},/" -i    /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$ARP.input
sed "s/dy_:/dy   = ${DY},/" -i    /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$ARP.input
sed "s/dz_:/dz   = ${DZ},/" -i    /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$ARP.input
sed "s/dzmin_/dzmin   = ${DZMIN},/" -i    /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$ARP.input
sed "s/strhopt_/strhopt   = ${STRHOPT},/" -i    /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$ARP.input
sed "s/zrefsfc_/zrefsfc  = ${ZREFSFC},/" -i    /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$ARP.input
sed "s/dlayer1_/dlayer1  = ${DLAYER1},/" -i    /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$ARP.input
sed "s/dlayer2_/dlayer2  = ${DLAYER2},/" -i    /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$ARP.input
sed "s/strhtune_/strhtune  = ${STRHTUNE},/" -i    /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$ARP.input
sed "s/zflat_/zflat  = ${ZFLAT},/" -i    /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$ARP.input
 
# arps mpi number of processors
sed "s/nproc_x_/nproc_x = ${XP},/" -i    /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$ARP.input
sed "s/nproc_y_/nproc_y = ${YP},/" -i    /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$ARP.input
 
# arps lat lon
sed "s/mapproj_/mapproj  = ${MAPPROJ},/" -i /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$ARP.input
sed "s/ctrlat_/ctrlat  = ${CTRLAT},/" -i    /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$ARP.input
sed "s/ctrlon_/ctrlon  = ${CTRLON},/" -i    /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$ARP.input
sed "s/trulat1_/trulat1  = ${TRULAT1},/" -i    /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$ARP.input
sed "s/trulat2_/trulat2  = ${TRULAT2},/" -i    /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$ARP.input
sed "s/trulon_/trulon  = ${TRULON},/" -i    /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$ARP.input
 
# arps string substituion 
sed "s/runname_/runname = '${NAMESTRING}_E2A',/" -i  /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$ARP.input
sed "s/cmnt(1)_/cmnt(1) = ${CMNT1},/" -i    /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$ARP.input
sed "s/cmnt(2)_/cmnt(2) = ${CMNT2},/" -i    /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$ARP.input
sed "s/cmnt(3)_/cmnt(3) = ${CMNT3},/" -i    /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$ARP.input
sed "s/initime_/initime = '${INITTIMESTRING}',/" -i    /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$ARP.input
sed "s/tinitebd_/tinitebd = '${INITTIMESTRING}',/" -i    /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$ARP.input
sed "s/extdopt_/extdopt = ${EXTDOPT},/" -i    /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$ARP.input

sed "s/dir_extd_/dir_extd = '${EXTDATAPATH}${DATESTRING}${INITMOD}',/" -i    /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$ARP.input
sed "s/rstinf_/rstinf = '${NAMESTRING}.rst003600',/" -i  /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$ARP.input 
sed "s/inifile_/inifile = '${NAMESTRING}_E2A.bin000000',/" -i  /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$ARP.input 
sed "s/inigbf_/inigbf = '${NAMESTRING}_E2A.bingrdbas',/" -i  /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$ARP.input 
sed "s/terndta_/terndta = '${NAMESTRING}_E2A.trndata',/" -i  /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$ARP.input 
sed "s/exbcname_/exbcname = '${NAMESTRING}_E2A',/" -i  /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$ARP.input 
sed "s/sfcdtfl_/sfcdtfl = '${NAMESTRING}_E2A.sfcdata',/" -i  /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$ARP.input 
sed "s/soilinfl_/soilinfl = '${NAMESTRING}_E2A.soilvar',/" -i  /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$ARP.input 
sed "s/sndfile_/sndfile = '${NAMESTRING}_E2A.snd',/" -i  /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$ARP.input 
sed "s/tstop_/tstop = ${TSTOP},/" -i  /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$ARP.input 

#.......................................................................
### start of exececutable part 
#.......................................................................

# if the seperate script "get_gfs.sh"  that runs with an cron job 
# has failed this call is the second chance to get the boundary input data 
# gribmaster will check/get the GFS files if available
# gribmaster will stop at once if the files exist 
#/home/$USER/$ARPS/gribmaster/gribmaster --dset ggfs025grb2 #--date %date 	
/home/$USER/$ARPSINDIR/$DOMAIN/$SRC/./get_gfs.sh $YEAR2$MONTH$DAY


# create runtime directory for the today simulation
mkdir -p  /home/$USER/run_$ARPS/$INITIALSTRING/$NAMESTRING

# change directory to runtimedirectory   
cd /home/$USER/run_$ARPS/$INITIALSTRING/$NAMESTRING



if [[ $clean ==  $2 ]] ; then

# NOTE DELETE ALL FILES in current date folder
	shopt -s nullglob
	shopt -s dotglob # To include hidden files
	echo "/home/$USER/run_$ARPS/$INITIALSTRING/$NAMESTRING/*"
	files=(/home/$USER/run_$ARPS/$INITIALSTRING/$NAMESTRING/*)
	if [ ${#files[@]} -gt 0 ]; then rm -r *; fi
fi

# copy input files to corresponding data directory 

cp  /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$CVT.input /home/$USER/run_$ARPS/$INITIALSTRING/$NAMESTRING/$DOMAIN$CVT.input
cp  /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$TRN.input /home/$USER/run_$ARPS/$INITIALSTRING/$NAMESTRING/$DOMAIN$TRN.input
cp  /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$ARP.input /home/$USER/run_$ARPS/$INITIALSTRING/$NAMESTRING/$DOMAIN$ARP.input 
cp  /home/$USER/$ARPSINDIR/$DOMAIN/$SRC/run_d1.sh /home/$USER/run_$ARPS/$INITIALSTRING/$NAMESTRING/run_d1.sh
fn0=$(basename "$0")
fn1=$(basename "$1")
cp  /home/$USER/$ARPSINDIR/$DOMAIN/$SRC/$fn0 /home/$USER/run_$ARPS/$INITIALSTRING/$NAMESTRING/$fn0
cp  /home/$USER/$ARPSINDIR/$DOMAIN/$SRC/$fn1 /home/$USER/run_$ARPS/$INITIALSTRING/$NAMESTRING/$fn1




#.......................................................................
### start of simulation run
#.......................................................................

# call DEM import
/home/$USER/$ARPS/bin/arpstrn < /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$TRN.input

# call surface generator -> soil and vegetation
/home/$USER/$ARPS/bin/arpssfc  < /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$ARP.input

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
	sed "s/extdname_/extdname = '${DATESTRING3}00.gfs',/" -i    /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$ARP.input
	sed "s/extdtime(1)_/extdtime(1) = '${INITTIMESTRING}+000:00:00',/" -i    /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$ARP.input
	/home/$USER/$ARPS/bin/ext2arps  /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$ARP.input
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
sed "s/grdbasopt = 1,/grdbasopt = 0,/" -i  /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$ARP.input
# set the first/oldstring
oldtstr='+000:00:00'


echo `seq 0 $((${#timeext[@]}-1))`;
# for all 
echo "${#timeext[@]} more GFS files in line...."
for i in `seq 0 $((${#timeext[@]}-1))`;
	do
		echo "processing file $i of ${#timeext[@]}"
		sed "s/${oldtstr}/${timeext[$i]}/" -i    /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$ARP.input
		/home/$USER/$ARPS/bin/ext2arps < /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$ARP.input | grep 'Normal successful completion of EXT2ARPS'
		oldtstr=${timeext[$i]}
		i=$((i+1))
		echo "substitute $oldtstr with ${timeext[$i]}"
	done
### up to this point all boundary conditions for the simulation run are interpolated
echo "=== processed successfully all external boundary files ==="
echo "### '''''''''''''''''''''''''''''''''''''''''''''''''''###"
echo "=== preparing $DOMAIN$ARP.input for simulation run ... ==="

### before simulation run we replace the 'runname' from (E2A) boundary run to (ARP)  ARPS simulation run 
sed "s/runname = '${NAMESTRING}_E2A',/runname = '${HDMPFHEADER}',/" -i  /home/$USER/$ARPSINDIR/$DOMAIN/$DOMAIN$ARP.input




