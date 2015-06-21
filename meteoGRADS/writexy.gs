'reinit'
'open /home/creu/progs/opengrads/data/stol_d1_ARP.gradscntl'
'set lev 3000'
'd u'

'printim ncep_tut.png png'

'set gxout print'
'set prnopts %6.2f 1 1'


write('NCEP.txt', 'X    Y    LON    LAT    TEMP')

'q dims'


xline=sublin(result,2)    ;* 2nd line
yline=sublin(result,3)    ;* 3rd line
xmax=subwrd(xline,13)    ;*13th word on xline
ymax=subwrd(yline,13)    ;*13th word on yline

say 'X grid-points: 'xmax
say 'Y grid-points: 'ymax
y=1

while(y<=ymax)

  x=1
  while(x<=xmax)

    'set x 'x
    'set y 'y
    'd u'

*    NOTE: It may be useful to test this to find out where the data is contained with in the result
*    It just so happens that in this case, the data is the 1st word of the 2nd line, this is not always true
*     say result
     tmp=sublin(result,3)
*     say 'tmp' tmp
*     tmp=subwrd(tmp,1)
*      tmp=result
*    Get Lat/Lon Data

     'q dims'
     lons=sublin(result,2)
     lats=sublin(result,3)
     lon=subwrd(lons,6)
     lat=subwrd(lats,6)

*    Save data to file
*    Note the "append", so to add to the file instead of overwriting it

     write('NCEP.txt', x'    'y'    'lon'    'lat'    'tmp,append)

     x=x+1
   endwhile
  y=y+1
endwhile 

***
