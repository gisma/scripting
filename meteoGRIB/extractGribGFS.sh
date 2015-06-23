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
    echo " Usage:  ./extractGribGFS.sh -i=<GribGFSFile> -r= 00-lo=DD.DD -la=DD.DD -t=<extractype> -f3=<pathtoscript> -c -s"
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
    echo "  -s                        simple datum format"
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
    -s)
    simple="${i#}"
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
	       wgrib2 -s -match  ":TCDC:high cloud layer:"             $INFILE -vt -print DEL -lon $LON $LAT |  grep -o -P '(?<=d=).*(?=,)' | awk '{print substr($0, 0, 10)}'  > STIME
	       while read line
	       do
			STARTTIME=$line
			break
	       done < 'STIME'

	       Y=${STARTTIME:0:4}
	       M=${STARTTIME:4:2}
	       D1=${STARTTIME:6:2}

           if [[ $simple !=  "-s" ]] ; then
			Y=${STARTTIME:0:4}
			M=${STARTTIME:4:2}
			D1=${STARTTIME:6:2}
			D2=$(($D1+1))
			D3=$(($D1+2))
			for z in $(seq   0 3)
			do
				for i in $(seq -w  0 3 23)
				do
					echo $Y-$M-$(($D1+$z))'T'$i':00:00' >> CTIME1
				done
			done
			#echo $Y-$M-$D3'T00:00:00' >> CTIME1

			for z in $(seq   0 3)
			do
				for i in $(seq -w  3 3 23)
				do
					echo $Y-$M-$(($D1+$z))'T'$i':00:00' >> CTIME2
			done
			echo $Y-$M-$D2'T00:00:00' >> CTIME2
			done

			#wgrib2 -s -match  ":TCDC:high cloud layer:"             $INFILE -vt -print DEL -lon $LON $LAT |  grep -o -P '(?<=d=).*(?=,)' | awk '{print substr($0, 0, 4)"-"substr($0, 5, 2)"-"substr($0, 7, 2)"T"substr($0, 9, 2)":00:00";}' > STIME
			else

			#wgrib2 -s -match  ":TCDC:high cloud layer:"             $INFILE -vt -print DEL -lon $LON $LAT |  grep -o -P '(?<=vt=).*(?=:DEL)' | awk '{ printf("%010d\n", $0 - 3) }' | awk '{print substr($0, 0, 4)"-"substr($0, 5, 2)"-"substr($0, 7, 2)"T"substr($0, 9, 2)":00:00";}'> CTIME1
			wgrib2 -s -match  ":TCDC:high cloud layer:"             $INFILE -vt -print DEL -lon $LON $LAT |  grep -o -P '(?<=vt=).*(?=:DEL)' | awk '{ printf("%010d\n", $0 - 3) }'> CTIME1
			wgrib2 -s -match  ":TCDC:high cloud layer:"             $INFILE -vt -print DEL -lon $LON $LAT |  grep -o -P '(?<=vt=).*(?=:DEL)'  > CTIME2
            fi

	       while read line
	       do
	        geoHGT=$line
	        break
	       done < 'HGT'


         while read  WS10
	do
	tmp=$(bc <<< "$WS10*10")
	cmp=$(echo  $tmp | python -c "print int(round(float(raw_input())))")
	  if  (( $cmp  < 3 ))
	  then
	    echo 'Flaute' >> beaufort
	  elif (($cmp>=3 && $cmp <16))
	  then
	    echo 'Leiser Zug' >> beaufort
	  elif (($cmp>=  16 && $cmp <  34 ))
	  then
	    echo 'Leichte Brise' >> beaufort
	  elif (($cmp>=   34 && $cmp <  55 ))
	  then
	    echo 'Schwache Brise' >> beaufort
	  elif (($cmp>=   55 && $cmp <  80 ))
	  then
	    echo 'Mäßige Brise' >> beaufort
	  elif (($cmp>=   80 && $cmp <  108 ))
	  then
	    echo 'Frische Brise' >> beaufort
	  elif (($cmp>=   108 && $cmp <  139 ))
	  then
	    echo 'Starker Wind' >> beaufort
	  elif (($cmp>=   139 && $cmp <  172 ))
	  then
	    echo 'Steifer Wind' >> beaufort
	  elif (($cmp>=   172 && $cmp <  208 ))
	  then
	    echo 'Stürmischer Wind' >> beaufort
	  elif (($cmp>=   208 && $cmp <  245 ))
	  then
	    echo 'Sturm' >> beaufort
	  elif (($cmp>=   245 && $cmp <  285 ))
	  then
	    echo 'Schwerer Sturm' >> beaufort
	  elif (($cmp>=   285 && $cmp <  327 ))
	  then
	    echo 'Orkanartiger Sturm' >> beaufort
	  elif (($cmp>=   327 ))
	  then
	    echo 'Orkan' >> beaufort
     else
	  echo 'FEHLER' >> beaufort
     fi
    done < WS10

	while read  WD10
	do
	tmp=$(bc <<< "$WD10*100")
	cmp=$(echo  $tmp | python -c "print int(round(float(raw_input())))")
	  if  (($cmp>=34875 && $cmp <=36000))
	  then
	    echo 'N' >> dir
	  elif  (($cmp>=0 && $cmp <=1125))
	  then
	    echo 'N' >> dir
	  elif (($cmp>=1125 && $cmp <3375))
	  then
	    echo 'NNO' >> dir
	  elif (($cmp>=  3375 && $cmp <  5625))
	  then
	    echo 'NO' >> dir
	  elif (($cmp>=   5625 && $cmp < 7875))
	  then
	    echo 'ONO' >> dir
	  elif (($cmp>=   7875 && $cmp <  10125 ))
	  then
	    echo 'O' >> dir
	  elif (($cmp>=   10125 && $cmp <  12375 ))
	  then
	    echo 'OSO' >> dir
	  elif (($cmp>=   12375 && $cmp <  14625 ))
	  then
	    echo 'SO' >> dir
	  elif (($cmp>=   14625 && $cmp <  16875 ))
	  then
	    echo 'SSO' >> dir
	  elif (($cmp>=   16875 && $cmp <  19125 ))
	  then
	    echo 'S' >> beaufort
	  elif (($cmp>=   19125 && $cmp <  21375 ))
	  then
	    echo 'SSW' >> dir
	  elif (($cmp>=   21375 && $cmp <  23625 ))
	  then
	    echo 'SW' >> dir
	  elif (($cmp>=   23625 && $cmp <  25875 ))
	  then
	    echo 'WSW' >> dir
	  elif (($cmp>=   25875 && $cmp <  28125 ))
	  then
	    echo 'W' >> dir
	  elif (($cmp>=   28125 && $cmp <  30375 ))
	  then
	    echo 'WNW' >> dir
	  elif (($cmp>=   30375 && $cmp <  32625 ))
	  then
	    echo 'NW' >> dir
	  elif (($cmp>=   32625 && $cmp <  34875 ))
	  then
	    echo 'NNW' >> dir
	  else
		echo 'FEHLER' >> dir
	  fi
	done < WD10



	# calculate sunrise/set
	SUNTIME=$($SCRIPTPATH/./suncalc.R "$D1$M$Y" $LAT $LON)

 	tmp=${STARTTIME}_${LON}_${LAT}
	mod=${tmp//./-}
	OUTFILE=$mod.meteogram
	OUTFILEMETA=$mod.meteogram.meta

	# concat the META string
    METAHEAD='Datum,Vorhersage,Sonnenaufgang,Sonnenuntergang,Höhe,Geographische Länge,Geographische Breite'

	METADATA=${Y}-${M}-${D1},${run},${SUNTIME},${geoHGT},${LON},${LAT}

	echo "${METAHEAD}" > $OUTFILEMETA
    echo "${METADATA}" >> $OUTFILEMETA


	# past the single col-files together (del=,)
	paste -d',' CTIME1 CTIME2 PRES PRMSL TMAX TMIN DPT RH WS10 beaufort WD10 dir GUST WS100 WD100 WS1829 WD1829 WS2743 WD2743 WS3658 WD3658 APCP ACPCP lTCDC mTCDC hTCDC> $OUTFILE

	# put header
	sed -i '1iBeginn Vorhersage,Ende Vorhersage,Luftdruck 2m hPa,Luftdruck msl hPa,Maximum Temperatur C,Minimum Temperatur C,Taupunkt Temperatur C,Relative Feuchte Prozent,Windgeschwindigkeit 10m ms-1,Windgeschwindigkeit 10m Beaufort,Windrichtung 10m Grad,Windrichtung 10m Windrose,Windböe ms-1,Windgeschwindigkeit 100m ms-1,Windrichtung 100m Grad,Windgeschwindigkeit 1800m ms-1,Windrichtung 1800m Grad,Windgeschwindigkeit 2750m ms-1,Windrichtung 2750m Grad,Windgeschwindigkeit 3650m ms-1,Windrichtung 3650m Grad,Niederschlag konvektiv mm,Niederschlag stratiform mm,Wolken niedrig Prozent,Wolken mittel Prozent,Wolken hoch Prozent'  $OUTFILE
	# write some metatags
	# STARTTIME : the Starting Time of the Model i.e. the Analysis run
	# SUNTIME   : Sunrise and Sunset at the given coordinate in decimal Time
	# HGT the geopotential Height of the given coordinate


	set -- "dir" "beaufort" "T" "TT" "HGT" "STIME" "WIND.grb" "CTIME1" "CTIME2" "PRES" "PRMSL" "TMAX" "TMIN" "DPT" "RH" "WS10" "WD10" "GUST" "WS100" "WD100" "WS1829" "WD1829" "WS2743" "WD2743" "WS3658" "WD3658" "APCP" "ACPCP" "lTCDC" "mTCDC" "hTCDC"
	# cleanup
	rm -f $@

	if [ -f $OUTFILE ]; then
	   clear
	   echo "$($SCRIPTPATH/./tojson.R $mod.meteogram)"  > $OUTFILE
	   #cat "$OUTFILE"
	else

	   echo "No success -lease check directory"
	fi
else
	echo "Uups didn't check type but '$type' is not implemented "
fi # meteogram
