# /bin/bash
INFILE='allNew.nc'
#CURRENTTIME=$(($TIME1*3600))
LEV='0'
DATE=`date -u +%Y-%m-%dT`
YM=`date -u +%Y-%m-`
D1=`date -u +%d`
D2=$(($D1+1))
D3=$(($D1+2))
LAT='50.4'
LON='8.2'
TIME1='0'
TIME2='47'

rm t
rm tt
rm beaufort

ncks -H -C -s '%f\n' -v WS -d Time,$TIME1,$TIME2 -d level,$LEV -d lon,$LON  -d lat,$LAT $INFILE > ws2
ncks -H -C -s '%f\n' -v WS -d Time,$TIME1,$TIME2 -d level,$LEV -d lon,$LON  -d lat,$LAT $INFILE > ws.o
ncks -H -C -s '%f\n' -v WD -d Time,$TIME1,$TIME2 -d level,$LEV -d lon,$LON  -d lat,$LAT $INFILE > wd
ncks -H -C -s '%f\n' -v TMP -d Time,$TIME1,$TIME2 -d level,$LEV -d lon,$LON  -d lat,$LAT $INFILE > tmp
ncks -H -C -s '%f\n' -v DPT -d Time,$TIME1,$TIME2  -d level,$LEV -d lon,$LON  -d lat,$LAT $INFILE > dpt
ncks -H -C -s '%f\n' -v PRES -d Time,$TIME1,$TIME2 -d level,$LEV -d lon,$LON  -d lat,$LAT $INFILE > pres
ncks -H -C -s '%f\n' -v RH -d Time,$TIME1,$TIME2 -d level,$LEV -d lon,$LON  -d lat,$LAT $INFILE > rh


        for i in $(seq -w  0 23)
          do
    	     echo $YM$D1'T'$i':00:00' >> t
	      done
        for i in $(seq -w  0 23)
          do
    	     echo $YM$D2'T'$i':00:00' >> t
	      done
        echo $YM$D3'T00:00:00' >> t

        
        for i in $(seq -w  1 23)
          do
    	     echo $YM$D1'T'$i':00:00' >> tt
	      done
        for i in $(seq -w  0 23)
          do
    	     echo $YM$D2'T'$i':00:00' >> tt
	      done
        echo $YM$D2'T00:00:00' >> tt
        echo $YM$D3'T01:00:00' >> tt


while IFS=, read  ws
do 
  if [ $(($ws < 3)) ]
  then
    echo 'Flaute' >> beaufort
  elif [ $ws >= 3 ] && [ $ws <  16 ]  
  then
    echo 'Leiser Zug' >> beaufort
  elif [ $ws >= 16 ] && [ $ws <  34 ] 
  then
    echo 'Leichte Brise' >> beaufort
  elif [ $ws >= 34 ] && [ $ws <  55 ] 
  then
    echo 'Schwache Brise' >> beaufort
  elif [ $ws >= 55 ] && [ $ws <  80 ] 
  then
    echo 'Mäßige Brise' >> beaufort
  elif [ $ws >= 80 ] && [ $ws <  108 ] 
  then
    echo 'Frische Brise' >> beaufort
  elif [ $ws >= 108 ] && [ $ws <  139 ] 
  then
    echo 'Starker Wind' >> beaufort
  elif [ $ws >= 139 ] && [ $ws <  172 ] 
  then
    echo 'Steifer Wind' >> beaufort
  elif [ $ws >= 172 ] && [ $ws <  208 ] 
  then
    echo 'Stürmischer Wind' >> beaufort
  elif [ $ws >= 208 ] && [ $ws <  245 ]     
  then
    echo 'Sturm' >> beaufort
  elif [ $ws >= 245 ] && [ $ws <  285 ] 
  then
    echo 'Schwerer Sturm' >> beaufort
  elif [ $ws >= 285 ] && [ $ws <  327 ] 
  then
    echo 'Orkanartiger Sturm' >> beaufort
  elif [ $ws >= 327 ]
  then
    echo 'Orkan' >> beaufort
  else
	echo 'FEHLER' >> beaufort
  fi
done < ws.o




paste -d',' t tt pres ws.0 wd tmp dpt rh > metin2.csv

#sed -i '1iZeit,Luftdruck,Windgeschwindigkeit,Windrichtung,Temperatur,Taupunkttemperatur,Relative Reuchte'  metin2.csv
sed -i '$d' metin2.csv
sed -i '50d' metin2.csv


