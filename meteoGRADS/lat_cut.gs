********************************************************************


'reinit'
'c'
'set background 1'
'open /home/creu/progs/opengrads/data/stol_d1_ARP.gradscntl'

timestep=1
height=3500
hgt=height/1000
lon0 = 13.47
lat0 = 46.27
lon1 = 13.0
lon2 = 14.0
lat1 = 45.8
lat2 = 46.6
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
*'set x 1'
*'set y 10'
'set lev  1 'height

******* lat cut
* Horizotal windspeed and potential temparature
* set print area in inch
'set parea 1 9.25 1 7.75'
'set lat 'lat1' 'lat2''
'set lon 'lon0''
'set xaxis 'lat1' 'lat2' 0.5'
'set vrange 1 'height
'set yaxis 0 'hgt' 0.5'
* color set gxout to shaded nd generates clev und ccol
'color -gxout shaded   0 50  -kind blue->white->red 1'
* genrates plotting area sn set labels etc.
'set clab on'
'set xlopts 0 7 0.18'
'set ylopts 0 7 0.18'
'set cint 1'
'set clskip 5'
'set cthick 1'
* display  horizontal wind as shaded plot
'd mag(u,v)'
* generate legend
'cbarn 0.8 1'
* display  potential temperature as colored dotted line
'set vrange 1 'height
'set yaxis 0 'hgt' 0.5'
'color -gxout contour 290 310 -kind bluered 1'
'set clab on'
'set cstyle 3'
'd pt'


len = 0.5
scale = 40
xrit = 10.5
ybot = 0.5
rc = arrow(xrit-0.25,ybot+0.2,len,scale)
'set gxout vector'
'set arrscl ' len' 'scale
'set arrlab on'
'set ccolor 0'
'set cthick 1'

'd mag(u,v)'


 'd trn'

 
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
