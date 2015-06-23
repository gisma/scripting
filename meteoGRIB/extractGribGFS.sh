#!/bin/bash
# Chris Reudenbach
# Version: 0.1 Date: 2015-06-17
#          0.2 Date: 2015-06-21
#                    add commandline and nettiquette
#                    add default settings
#                    add folder structure
# Simple script to select and extract NCEP NOAA GFS 0.25 data
# Data has to be downloaded before i.e. with getGribGFS.sh
# If not you need a single GRIB2 datafile containing the needed vars.
#
# V 0.2 creates meteogram textfiles only

if [[ "$1" == '-h' ]]; then
    echo "---------------------------------------------------------------------- "
    echo "<extractGribGFS.sh> extracts specified dataset from GFS 0.25 GRIB Data"
    echo "                    at the nearest model grid to a request."
    echo "                    Currently only meteogram datasets are supported"
    echo " "
    echo " Usage:  ./extractGribGFS.sh -i=<GribGFSFile> -r= 00-lo=DD.DD -la=DD.DD -t=<extractype> -f3=<pathtoscript> -c"
    echo "         ./extractGribGFS.sh -h shows this brief help "
    echo " "
    echo " <extractGrib.sh> extracts from the 0.25° GFS GRIB2 data"
    echo " at defined lat lon position the requested variables "
    echo " NOTE currently just a fix meteogram data set is derived"
    echo " "
    echo "Usage: ./extractGribGFS.sh -h gives this brief help "
    echo "       ./extractGribGFS.sh -i=INFILE -la=DDD.DD -lo=0  "
    echo""
    echo " -if=INFILE:  <Name>      of a valid grib2 file"
    echo " -r=HH:       <[00 06 12 18]>  hour of run"
    echo " -lo=DD.DD:   <Longitude> of location that will be "
    echo "                           extracted in decimal degrees"
    echo " -la=DD.DD:   <Latitude>  of location that will be "
    echo "                           extracted in decimal degrees"
    echo " -t=type:     <keyword>   Type of data processing "
    echo "                           'meteogram'"
    echo "                           'wmaps'"
    echo "                           'maps'"
    echo " -f1=DATADIR:  <[wxdata]> root data directory under $HOME"
    echo " -f2=MTypDir:  <[GFS25]>  type of model tag under $DATADIR"
    echo " -f3=ScriptDir:<[[scripting]> script folder under $HOME/dev "
    echo "  -c                        delete all files in output directory default is false"
    echo " You may also use the long formats:"
    echo " --GRIB --latitude= --longitude= --type= "

    echo " "
    echo " example: ./extractGribGFS.sh -i=gfs.t00z.pgrb2.0p25.20150618_00_96.grb -lo=10.5 -la=47.25 m=meteogram"
    exit 0
fi


for i in "$@"
do
case $i in
    -i=*|--GRIB=*)
    INFILE="${i#*=}"
    ;;
    -r=*|--run=*)
    run="${i#*=}"
    ;;
    -la=*|--latitude=*)
    LAT="${i#*=}"
    ;;
    -lo=*|--longitude=*)
    LON="${i#*=}"
    ;;
    -t=*|--type=*)
    type="${i#*=}"
    ;;
    -f1=*)
    DATADIR="${i#*=}"
    ;;
    -f2=*)
    MODELDIR="${i#*=}"
    ;;
    -f3=*|--type=*)
    SCRIPTDIR="${i#*=}"
    ;;
    -c)
    clean="${i#}"
    ;;
    --default)
    DEFAULT=YES
    ;;
    *)
            # unknown option
    ;;
esac
done
######
# identify users home
USER=`whoami`

if [[ "${INFILE}" == "" ]]     ; then echo "--GRIB data file missing... ./extractGribGFS.sh -h for help";  exit; fi
if [[ "${run}" == "" ]]             ; then  param=FALSE; "run slot missing ./extractGribGFS.sh -h for help";  exit; fi
if [[ "${LAT}" == "" ]]        ; then echo "--latitude missing - set DEFAULT Marburg/Germany"   ; param=FALSE; LAT=50.8;LON=8.7;  fi
if [[ "${LON}" == "" ]]        ; then echo "--longitude missing - set DEFAULT Marburg/Germany " ; param=FALSE; LAT=50.8;LON=8.7;  fi
if [[ "${type}" == "" ]]       ; then echo "--type missing - set DEFAULT type 'meteogram'"     ; param=FALSE; type='meteogram';  fi
if [[ "${DATADIR}" == "" ]]    ; then param=FALSE; DATADIR="wxdata" ; fi
if [[ "${MODELDIR}" == "" ]]   ; then param=FALSE; MODELDIR="GFS25" ; fi
if [[ "${SCRIPTDIR}" == "" ]] ; then param=FALSE;  SCRIPTDIR="scripts/meteoGRIB";  fi

if [[ "${param}" == "FALSE" ]]; then echo "Get help with ./extractGribGFS.sh -h"; echo "However proceeding with above DEFAULT values..." ;fi

echo "extracting the data with the following parameters:"
echo GRIB = ${INFILE}
echo run = ${run}
echo LAT = ${LAT}
echo LON = ${LON}
echo type = ${type}
echo DATADIR = ${DATADIR}
echo MODELDIR = ${MODELDIR}
SCRIPTPATH=/home/$USER/dev/${SCRIPTDIR}
echo SCRIPTPATH = ${SCRIPTPATH}
# set datapath (currently GFS25)
filename=$(basename "$INFILE")
filename="${filename%.*}"
fndate=${filename:20:8}
INDATAPATH=$(dirname "$INFILE")
EXDATAPATH=/home/$USER/$DATADIR/$MODELDIR/$fndate/$type
echo "~~~~~~~~~~~~~~~~~"
echo "output folder:"
echo EXDATAPATH = ${EXDATAPATH}
echo "~~~~~~~~~~~~~~~~~"
echo "Start extracting...."

# create directories
if [ ! -d $EXDATAPATH ]; then mkdir -p ${EXDATAPATH} ; fi

# change directory to runtimedirectory
cd $EXDATAPATH

if [[ $clean ==  "-c" ]] ; then

# NOTE DELETE ALL FILES in current date folder
	shopt -s nullglob
	shopt -s dotglob # To include hidden files
	files=(DATAPATH/*)
	if [ ${#files[@]} -gt 0 ]; then rm -r *; fi
fi
#############


# Starting executable part
# --------------------------------------------------
if [[ "${type}" == "meteogram" ]] ;then
	# list of all vars to be extracted
	declare -a VARS=("HGT" "UGRD" "GUST" "PRES" "TMIN" "TMAX" "DPT" "RH" "PRMSL" "APCP" "ACPCP" "TCDC")

	for i in `seq 0 $((${#VARS[@]}-1))`;
		do
	      if [ ${VARS[$i]} == 'UGRD' ] ; then
	       # first calculate WIND DIR and SPEED
	       wgrib2 $INFILE  -match "(UGRD|VGRD)" -wind_speed WIND.grb  -wind_dir WIND.grb > /dev/null 2>&1
	              # extract the dmenaded levels

	       wgrib2 -match  ":WIND:10 m above ground:"               WIND.grb     -lon $LON $LAT -print " " |  grep -o -P '(?<=val=).*(?=:)' > WS10
	       wgrib2 -match  ":WDIR:10 m above ground:"               WIND.grb     -lon $LON $LAT -print " " |  grep -o -P '(?<=val=).*(?=:)' > WD10
	       wgrib2 -match  ":WIND:100 m above ground:"              WIND.grb     -lon $LON $LAT -print " " |  grep -o -P '(?<=val=).*(?=:)' > WS100
	       wgrib2 -match  ":WDIR:100 m above ground:"              WIND.grb     -lon $LON $LAT -print " " |  grep -o -P '(?<=val=).*(?=:)' > WD100
	       wgrib2 -match  ":WIND:1829 m above mean sea level:"     WIND.grb     -lon $LON $LAT -print " " |  grep -o -P '(?<=val=).*(?=:)' > WS1829
	       wgrib2 -match  ":WDIR:1829 m above mean sea level:"     WIND.grb     -lon $LON $LAT -print " " |  grep -o -P '(?<=val=).*(?=:)' > WD1829
	       wgrib2 -match  ":WIND:2743 m above mean sea level:"     WIND.grb     -lon $LON $LAT -print " " |  grep -o -P '(?<=val=).*(?=:)' > WS2743
	       wgrib2 -match  ":WDIR:2743 m above mean sea level:"     WIND.grb     -lon $LON $LAT -print " " |  grep -o -P '(?<=val=).*(?=:)' > WD2743
	       wgrib2 -match  ":WIND:3658 m above mean sea level:"     WIND.grb     -lon $LON $LAT -print " " |  grep -o -P '(?<=val=).*(?=:)' > WS3658
	       wgrib2 -match  ":WDIR:3658 m above mean sea level:"     WIND.grb     -lon $LON $LAT -print " " |  grep -o -P '(?<=val=).*(?=:)' > WD3658
	      elif [ ${VARS[$i]} == 'GUST' ] ;  then
	       wgrib2 -match  ":${VARS[$i]}:surface:"                  $INFILE  -lon $LON $LAT -print " " |  grep -o -P '(?<=val=).*(?=:)' > GUST
	      elif [ ${VARS[$i]} == 'PRES' ] ;  then
	       wgrib2 -match  ":${VARS[$i]}:surface:"                  $INFILE  -rpn "0.01:*"    -lon $LON $LAT -print " " |  grep -o -P '(?<=val=).*(?=:)' > PRES
	      elif [ ${VARS[$i]} == 'PRMSL' ] ;  then
	       wgrib2 -match  ":${VARS[$i]}:mean sea level:"                  $INFILE  -rpn "0.01:*"    -lon $LON $LAT -print " " |  grep -o -P '(?<=val=).*(?=:)' > PRMSL
	      elif [ ${VARS[$i]} == 'TMAX' ] ;	then
	       wgrib2 -match  ":${VARS[$i]}:2 m above ground:"         $INFILE  -rpn "273.15:-" -lon $LON $LAT -print " " |  grep -o -P '(?<=val=).*(?=:)' > TMAX
	      elif [ ${VARS[$i]} == 'TMIN' ] ;	then
	       wgrib2 -match  ":${VARS[$i]}:2 m above ground:"         $INFILE  -rpn "273.15:-" -lon $LON $LAT -print " " |  grep -o -P '(?<=val=).*(?=:)' > TMIN

	      elif [ ${VARS[$i]} == 'DPT' ] ;	then
	       wgrib2 -match  ":${VARS[$i]}:2 m above ground:"         $INFILE  -rpn "273.15:-" -lon $LON $LAT -print " " |  grep -o -P '(?<=val=).*(?=:)' > DPT
	      elif [ ${VARS[$i]} == 'RH' ] ;	then
	       wgrib2 -match  ":${VARS[$i]}:2 m above ground:"         $INFILE  -lon $LON $LAT -print " " |  grep -o -P '(?<=val=).*(?=:)' > RH
	      elif [ ${VARS[$i]} == 'HGT' ] ;	then
	       wgrib2 -match  ":${VARS[$i]}:surface:"                  $INFILE  -lon $LON $LAT -print " " |  grep -o -P '(?<=val=).*(?=:)' > HGT
	      elif [ ${VARS[$i]} == 'ACPCP' ] ;	then
	       wgrib2 -match  ":${VARS[$i]}:surface:"                  $INFILE  -lon $LON $LAT -print " " |  grep -o -P '(?<=val=).*(?=:)' > ACPCP
	      elif [ ${VARS[$i]} == 'APCP' ] ;	then
	       wgrib2 -match  ":${VARS[$i]}:surface:"                  $INFILE  -lon $LON $LAT -print " " |  grep -o -P '(?<=val=).*(?=:)' > APCP
	      elif [ ${VARS[$i]} == 'TCDC' ] ;	then
	       wgrib2 -match  ":TCDC:low cloud layer:"                 $INFILE  -lon $LON $LAT -print " " |  grep -o -P '(?<=val=).*(?=:)' > lTCDC
	       wgrib2 -match  ":TCDC:middle cloud layer:"              $INFILE  -lon $LON $LAT -print " " |  grep -o -P '(?<=val=).*(?=:)' > mTCDC
	       wgrib2 -match  ":TCDC:high cloud layer:"                $INFILE  -lon $LON $LAT -print " " |  grep -o -P '(?<=val=).*(?=:)' > hTCDC

		  fi
			i=$((i+1))

	# get the STARTTIME
		done
	      # just for getting startime and valid data periods the use of the TCDC is arbitrary
	       wgrib2 -s -match  ":TCDC:high cloud layer:"             $INFILE -vt -print DEL -lon $LON $LAT |  grep -o -P '(?<=d=).*(?=,)' | awk '{print substr($0, 0, 10);}' > STIME
	       wgrib2 -s -match  ":TCDC:high cloud layer:"             $INFILE -vt -print DEL -lon $LON $LAT |  grep -o -P '(?<=vt=).*(?=:DEL)' | awk '{ printf("%010d\n", $0 - 3) }' > CTIME1
	       wgrib2 -s -match  ":TCDC:high cloud layer:"             $INFILE -vt -print DEL -lon $LON $LAT |  grep -o -P '(?<=vt=).*(?=:DEL)'  > CTIME2

	       while read line
	       do
	        STARTTIME=$line
	        echo $STARTTIME
	        break
	       done < 'STIME'
	       while read line
	       do
	        geoHGT=$line
	        break
	       done < 'HGT'

	# calculate sunrise/set

	Y=${STARTTIME:0:4}
	M=${STARTTIME:4:2}
	D=${STARTTIME:6:2}

	SUNTIME=$($SCRIPTPATH/./suncalc.R "$D$M$Y" $LAT $LON)
   echo "suntime $SUNTIME"
	tmp=${STARTTIME}_${LON}_${LAT}
	mod=${tmp//./-}
	OUTFILE=$mod.meteogram

	# past the single col-files together (del=,)
	paste -d',' CTIME1 CTIME2 PRES PRMSL TMAX TMIN DPT RH WS10 WD10 GUST WS100 WD100 WS1829 WD1829 WS2743 WD2743 WS3658 WD3658 APCP ACPCP lTCDC mTCDC hTCDC> $OUTFILE

	# put header
	sed -i '1iBeginn Vorhersage,Ende Vorhersage,Luftdruck 2m hPa,Luftdruck msl hPa,Maximum Temperatur °C,Minimum Temperatur °C,Taupunkt Temperatur °C,Relative Feuchte %,Windgeschwindigkeit 10m m/s,Windrichtung 10m Grad,Windböe m/s,Windgeschwindigkeit 100m m/s,Windrichtung 100m Grad,Windgeschwindigkeit ~1800m m/s,Windrichtung ~1800m Grad,Windgeschwindigkeit ~2750m m/s,Windrichtung 2750m Grad,Windgeschwindigkeit ~3650m m/s,Windrichtung ~3650m Grad,Niederschlag konvektiv mm,Niederschlag stratiform mm,Wolken niedrig %,Wolken mittel %,Wolken hoch %'  $OUTFILE
	# write some metatags
	# STARTTIME : the Starting Time of the Model i.e. the Analysis run
	# SUNTIME   : Sunrise and Sunset at the given coordinate in decimal Time
	# HGT the geopotential Height of the given coordinate

	# concat the META string
    METAHEAD='Datum Vorhersagezeit,Sonnenaufgang,Sonnenuntergang,Höhe,Geographische Länge,Geographische Breite'
    echo " ssssssssss $Y-$M-$D $run $SUNTIME $geoHGT $LON,$LAT"
	METADATA=${Y}-${M}-${D},${run},${SUNTIME},${geoHGT},${LON},${LAT}
	echo "metadata $METADATA"
	echo "metadata $METAHEAD"

	sed -i "1i${METADATA}"  $OUTFILE
	sed -i "1i${METAHEAD}"  $OUTFILE
	set -- "HGT" "STIME" "WIND.grb" "CTIME1" "CTIME2" "PRES" "PRMSL" "TMAX" "TMIN" "DPT" "RH" "WS10" "WD10" "GUST" "WS100" "WD100" "WS1829" "WD1829" "WS2743" "WD2743" "WS3658" "WD3658" "APCP" "ACPCP" "lTCDC" "mTCDC" "hTCDC"
	# cleanup
	rm -f $@

	if [ -f $OUTFILE ]; then
	   echo "$OUTFILE created"
	   cat "$OUTFILE"
	else

	   echo "No success -lease check directory"
	fi
else
	echo "Uups didn't check type but '$type' is not implemented "
fi # meteogram
