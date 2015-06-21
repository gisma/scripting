*********************************************************************
* The following lines will display an arbitrary X section
* from one specified point to another.
*
* lon1 is the westernmost longitude point
* lon2 is the easternmost longitude point
* lat1 is the latitude that corresponds to lon1
* lat2 is the latitude that corresponds to lon2
*
********************************************************************


'reinit'
'c'
'set background 1'
'open /home/creu/progs/opengrads/data/stol_d1_ARP.gradscntl'

timestep=1
loninc=0.1
height=1500
hgt=height/1000
lon1 = 13.47
lon2 = 13.9
lat1 = 46.18096
lat2 = 46.18096
'set t 'timestep
'q time'
rec=subwrd(result,3)
rec1=substr(rec,1,2)
dat1=substr(rec,4,9)


'c'

'set line 0'
'draw rec 0 0 11 8.5'
'enable print tmp1.out'
'set grads off'
'set x 1'
'set y 10'
'set lev  1 'height
lon = lon1
lat = lat1
'collect 1 free'
'collect 2 free'
'collect 3 free'
'collect 4 free'
*'collect 5 free'
*'collect 6 free'
while (lon<=lon2)
     'collect 1 gr2stn(pt,'lon','lat')'
     'collect 2 gr2stn(u,'lon','lat')'
     'collect 3 gr2stn(v,'lon','lat')'
     'collect 4 gr2stn(w,'lon','lat')'
*     'collect 5 gr2stn(v,'lon','lat')'
*     'collect 6 gr2stn(v,'lon','lat')'               
     say ' Reading Data'
     lon=lon+loninc
     lat=lat1 + (lat2-lat1)*(lon-lon1) / (lon2-lon1)
endwhile

* Horizotal windspeed and potential temparature
* set print area in inch
'set parea 1 9.25 1 7.75'
'set lon 'lon1' 'lon2
'set xaxis 'lon1' 'lon2' 0.5'
'set vrange 1 'height
'set yaxis 0 'hgt' 0.5'
* color set gxout to shaded nd generates clev und ccol
'color -gxout shaded   0 30  -kind blue->white->red 1'
* genrates plotting area sn set labels etc.
'set clab on'
'set xlopts 0 7 0.18'
'set ylopts 0 7 0.18'
'set cint 1'
'set clskip 5'
'set cthick 1'
* display  horizontal wind as shaded plot
'd (mag(coll2gr(2), coll2gr(3)))'
* generate legend
'cbarn 0.8 1'
* display  potential temperature as colored dotted line
'set vrange 1 'height
'set yaxis 0 'hgt' 0.5'
'color -gxout contour 290 310 -kind bluered 1'
'set clab on'
'set cstyle 3'
'd coll2gr(1)'

'set gxout vector'
len = 0.5
scale = 40
xrit = 10.5
ybot = 0.5
rc = arrow(xrit-0.25,ybot+0.2,len,scale)
'set arrscl ' len' 'scale
'set arrlab on'
'set ccolor 0'
'set cthick 1'
'set vrange 10 'height
'set yaxis 0 'hgt' 0.5'
'd coll2gr(2);coll2gr(3)'

'set gxout stream'
'set arrlab on'
'set ccolor 0'
'set cthick 1'
'set vrange 1 'height
'set yaxis 0 'hgt' 0.5'
'd coll2gr(2);coll2gr(4)'
'close 1'

***** TERRAIN
'open /home/creu/progs/opengrads/data/stol_d1_E2A.trndata.ctl' 
'set lev 1 '
'set parea 1 9.25 1 7.75'
ln=lon1
lt1=lat1
ln1=lon1
'set lon 'lon1' 'lon2

* this terrain adjustment is specified for the parea used here
* when scaling the terrain height if parea is different
* use ymax-ymin in parea(eg. 7.75-1=6.75)

while (ln<lon2)
      ln=ln+loninc
      lt=lat1 + (lat2-lat1)*(ln-lon1) / (lon2-lon1)
* calculates the lat/lon for which 2D terrain is extracted
  'q w2xy 'ln1' 'lt1
  x1=subwrd(result,3)
  
  'set lon 'ln1
  'set lat 'lt1
  'd trn'
  res =sublin(result,2)
  say res
  mt=subwrd(res,4)
*check if the actual terrain height is higher than the domain height and 
*if it is set it to that height so that terrain doesn't go outside the cross-section
  if (mt>height); mt=height;endif
  t1=mt*6.75/height+1
  'q w2xy 'ln' 'lt
  x2=subwrd(result,3)
  'set lon 'ln
  'set lat 'lt
  'd trn'
  res =sublin(result,2)
  mt=subwrd(res,4)
  if (mt>height); mt=height;endif
  t2=mt*6.75/height+1
  'set rgb 99  0  60  30'
  'set line 99 1 1 200'
  'draw polyf 'x1' 1 'x1' 't1' 'x2' 't2' 'x2' 1'
     lt1=lt
     ln1=ln
endwhile
**** TERRAIN 



'close 1'
'set font 0'
'set strsiz 0.18'
'set string 0 tl 8'
'draw string 1.1 8.1 Pot.Temp.(K), H. Windspeed(m/s) at 'timestep' UTC 'dat1''
'set string 0 tl 5'
'set strsiz 0.1'
'draw string 1.1 0.35 cross section from Lat ,'lat1'  to Lat,' lat2''
'set string 0 c 8'
'set strsiz 0.18'
'draw string 5.5 0.35 lon(deg E)'
'set string 0 c 8 90'
'draw string 0.35 4.0 z(km MSL)'

'print'
'disable print'
'!gxgif  -x 2048 -y 1664 -i tmp1.out -o cross_HWind_'timestep'.gif'
'!gxps -b 0.10 -c -i tmp1.out -o cross_HWind_'timestep'.ps'
'!ps2png cross_HWind_'timestep'.ps cross_HWind_'timestep'.png'

* - r macht aus weiss schwarz gr!!!!
 


function arrow(x,y,len,scale)
'set line 0 1 4'
'draw line 'x-len/2.' 'y' 'x+len/2.' 'y
'draw line 'x+len/2.-0.05' 'y+0.025' 'x+len/2.' 'y
'draw line 'x+len/2.-0.05' 'y-0.025' 'x+len/2.' 'y
'set string 0 c'
'set strsiz 0.1'
'draw string 'x' 'y-0.1' 'scale'  m/s'

return
