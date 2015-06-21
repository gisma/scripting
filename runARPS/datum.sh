#!/bin/bash 
# author Chris Reudenbach (2013)
# version 2015/05/23
# script to setup an arbitrary ARPS run using GFS boundary data
# fdatum (forecast datum) is  by default true (due to Forecast and operational use)

if [[ "$1" == '-h' ]]; then
    echo "Usage: ./datum.sh -h brief help | <setup file> <datetyp> <YYYY-MM-DD>"
    echo""
    echo "<setup file>: i.e.  '/home/arpsuser/arpsinput/d1/src/KILI_D1_01.sh' "
    echo""
    echo "<datetyp>:    true   taking actual date from the system (forecast mode) "
    echo"               false  providing individual date"
    echo""
    echo "<YYYY-MM-DD>: date  i.e. '2015-05-31'"
    echo""
    echo "example:      ~/arpsinput/d1/src/./datum.sh '/home/arpsuser/arpsinput/d1/src/KILI_D1_01.sh' false  '2015-05-31'"
    echo ""
    exit 0
elif [ "$#" -ne 3 ]; then
    echo "Usage: ./datum.sh -h brief help | <setup file> <datetyp> <YYYY-MM-DD> "
    echo " "
    exit 0
fi

source $1

if [[ $2 ==  true ]] ; then
# getting datestring
YEAR4=`date -u +%Y`
YEAR2=`date -u +%y`
MONTH=`date -u +%m`
DAY=`date -u +%d`

else
# getting datestring
YEAR4=`echo $3 | cut -d'-' -f 1`
YEAR2=`echo $3 | cut -c 3-4`
MONTH=`echo $3 | cut -d'-' -f 2`
DAY=`echo   $3 | cut -d'-' -f 3`
fi


echo "YEAR4=$YEAR4"  > /home/$USER/$ARPSINDIR/$DOMAIN/$SRC/date.input
echo "YEAR2=$YEAR2" >> /home/$USER/$ARPSINDIR/$DOMAIN/$SRC/date.input
echo "MONTH=$MONTH" >> /home/$USER/$ARPSINDIR/$DOMAIN/$SRC/date.input
echo "DAY=$DAY" >> /home/$USER/$ARPSINDIR/$DOMAIN/$SRC/date.input
