# /bin/bash
INFILE='allNew.nc'
TIME1='0'
TIME2='47'
CURRENTTIME=$(($TIME1*3600))
LAT='50.4'
LON='8.2'
LEV='0'
DATE=`date -u +%Y-%m-%dT`
YM=`date -u +%Y-%m-`
D1=`date -u +%d`
D2=$(($D1+1))
D3=$(($D1+2))

rm t
rm tt
rm beaufort
rm dir

ncks -H -C -s '%f\n' -v WS -d Time,$TIME1,$TIME2 -d level,$LEV -d lon,$LON  -d lat,$LAT $INFILE > ws2
ncks -H -C -s '%f\n' -v WS -d Time,$TIME1,$TIME2 -d level,$LEV -d lon,$LON  -d lat,$LAT $INFILE > ws
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




sed -i '$d' ws2
sed -i '$d' ws2
sed -i '$d' wd
sed -i '$d' wd


while read  ws
do 
tmp=$(bc <<< "$ws*10")
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
done < ws2

while read  wd
do 
tmp=$(bc <<< "$wd*100")
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
done < wd


paste -d',' t tt pres ws wd tmp dpt rh beaufort dir > metin2.csv

#sed -i '1iZeit,Luftdruck,Windgeschwindigkeit,Windrichtung,Temperatur,Taupunkttemperatur,Relative Reuchte'  metin2.csv
sed -i '$d' metin2.csv
sed -i '$d' metin2.csv


