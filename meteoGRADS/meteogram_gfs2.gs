* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
* meteogram_gfs2.gs
*
* This script draws a meteogram based on NCEP GRIB2 forecast data.
* Usage:   meteogram_gfs2 <name> <yyyymmddhh> <lon> <lat> <e>
*
* The 'e' argument is for British units. Default is metric.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
function main(args)

dohov=0
* Make sure GrADS is in portrait mode
'q gxinfo'
pagesize = sublin(result,2)
xsize = subwrd(pagesize,4)
ysize = subwrd(pagesize,6)
if (xsize != 8.5 & ysize != 11)
  say 'You must be in PORTRAIT MODE to draw a meteogram'
  return
endif
'set xsize 618 800'
* Parse the arguments: name, longitude, latitude, units, abbrv
name  = subwrd(args,1)
hilon = subwrd(args,2)
hilat = subwrd(args,3)
units = subwrd(args,4)
stid  = subwrd(args,5)
printim=1
say name

* Open the data file
'open subset.ctl'
'open subsetp.ctl'
'set dfile 1'

* Get info from the descriptor file
'q ctlinfo'
_ctl = result
_tdef = getctl(tdef)
_zdef = getctl(zdef)

* Get the Time axis info
tsize = 38
_t1 = 1
_t2 = tsize
'set t '_t1' '_t2
'q dims'
times  = sublin(result,5)
_time1 = subwrd(times,6)  
_time2 = subwrd(times,8)
_tdim = _time1' '_time2

* Get Vertical grid info 
zsize = subwrd(_zdef,2)
z = 1
zlevs = ''
rhzlevs = ''
while (z <= zsize)
  'set z 'z
  lev = subwrd(result,4)
  if lev = 500 ; z500 = z ; endif 
  zlevs = zlevs%lev%' '
  z = z + 1
endwhile
say 'hier bin ich '
* Find the grid point closest to requsted location
'set lon 'hilon
hilon = subwrd(result,4)
'set lat 'hilat
hilat = subwrd(result,4)
_xdim = hilon' 'hilon 
_ydim = hilat' 'hilat
say 'hier bin ich '
* Determine pressure range for hovmoellers; use Pa instead of mb
'set lon 'hilon
'set lat 'hilat
'set warn off'
'set gxout contour'
'set t 1'
'set z 1'
say _t1
say _t2
'd ave(u,t='_t1',t='_t2')*0.01-15.0'
data = sublin(result,1)
mmm = subwrd(data,4)
meanps = math_nint(mmm)
cnt = 1
while (cnt<zsize)
  el1 = subwrd(zlevs,cnt)
  el2 = subwrd(zlevs,cnt+1)
  if (meanps > el2)
    elb = el1
    elt = subwrd(zlevs,z500+cnt-1)
    break
  endif
  cnt=cnt+1
endwhile
if (elt < 500) ; elt = 500 ; endif   ;* use Pa instead of mb
_zbot = elb
_ztop = elt
_zgrd = _zbot' '_ztop

* Set up a few preliminary characteristics
setcols(1)
'set display color white'
'c'

* Determine the plot areas for each panel
npanels = 9
x1 =  1.20
x2 =  8.15
y1 =  7.50
y2 = 10.30
panel.npanels = x1' 'x2' 'y1' 'y2   ;* hovmoeller panel
ytop = 7.5  ;* y boundaries for rest of panels except precip
ybot = 1.5
int = (ytop-ybot)/(npanels-2)     ;* get height of middle panels
int = 0.001 * (math_nint(1000*int))
n=npanels-1
y2 = ytop
while (n >= 2)
  y2 = ytop - (npanels-n-1)*int
  y1 = ytop - (npanels-n)*int
  panel.n = x1' 'x2' 'y1' 'y2        ;* coords of middle panels
  n = n - 1
endwhile
xincr = (8.15 - 1.2)/tsize           ;* size of one time step
xincr = 0.01 * math_nint(100*xincr)
panel.1 = x1+xincr' 'x2' 0.4 'y1     ;* coords of precip panel

* Indent the soil panel too
w2 = subwrd(panel.2,2)
w3 = subwrd(panel.2,3)
w4 = subwrd(panel.2,4)
panel.2 = x1+xincr' 'w2' 'w3' 'w4

* Set the Plot Area for the Upper Air Panel
p = npanels
'set parea 'panel.p
'set vpage off'
'set grads off'
'set grid on'

* Draw the Relative Humidity Shading
'set gxout shaded'
'set csmooth on'
'set clevs  30 50 70 90 100'
'set ccols 0 20 21 23 25 26'
'set xlopts 1 4 0.16'
'set xlpos 0 t'
*'set ylab `1%g'
'set ylab %g'
'set ylint 100'
if (units = 'e')
  temp = '(t-273.16)*1.8+32'
  uwnd = 'u*2.2374'
  vwnd = 'v*2.2374'
else
  temp = '(t-273.16)'
  uwnd = 'u'
  vwnd = 'v'
endif
'set t '_t1-0.5' '_t2+0.5
'set lev '_zbot+50' '_ztop-50
'd rh'
'set gxout contour'
'set grid off'
'set ccolor 15'
'set clab off'
'set clevs 10 30 50 70 90'
'd rh'
'set ccolor 0'
'set clab on'
'set cstyle 5'
'set clopts 15'
'set clevs 10 30 50 70 90'
'd rh'

* Draw the Temperature Contours
'set clopts -1'
'set cstyle 1'
'set ccolor rainbow'
'set rbcols 9 14 4 11 5 13 12 8 2 6'
if (units = 'e')
  'set cint 10'
  'set cthick 6'
  'd 'temp
  'set clevs 32'
  'set cthick 12'
  'set ccolor 1'
  'set clab off'
  'd 'temp
  'set background 1'
  'set ccolor 20'
  'set clevs 32'
  'set cthick 4'
  'set clab on'
  'set clab `4FR'
else
  'set cint 5'
  'set cthick 6'
  'd 'temp
  'set clevs 0'
  'set cthick 12'
  'set ccolor 1'
  'set clab off'
  'd 'temp
  'set background 1'
  'set ccolor 20'
  'set clevs 0'
  'set cthick 4'
  'set clab on'
endif
'd 'temp

* Draw the Wind Barbs
'set background 0'
'set gxout barb'
'set digsiz 0.04'
'set ccolor 1'
'set xlab off'
'set ylab off'
'd 'uwnd';'vwnd

* Draw a rectangle over the year to clear the area for a title
'set line 0'
'draw recf 0.5 10.6 2.1 11.0'

* Define Thickness
'set lev 1000'
'set t '_t1' '_t2
'define thk1 = (z(lev=500)-z(lev=1000))/10'

* Next Panel: 1000-500 thickness
p = p - 1
'set parea 'panel.p
'set gxout line'
'set vpage off'
'set grads off'
'set grid on'
'set xlab on'
'set ylab on'
vrng(thk1, thk1)
'set ccolor 5'
'set cmark 4'
'set digsiz 0.04'
'set t '_t1-0.5' '_t2+0.5
say thickness
'd thk1'

'undefine thk1'


* Draw a rectangle over the x-axis labels
xlo = subwrd(panel.p,1)
xhi = subwrd(panel.p,2)
ylo = subwrd(panel.p,3)
yhi = subwrd(panel.p,4)
'set line 0'
'draw recf 'xlo-0.4' 'ylo-0.8' 'xhi+0.4' 'ylo-0.02

* Next Panel: Stability Indices
p = p - 1
'set parea 'panel.p
ylo = subwrd(panel.p,3)
yhi = subwrd(panel.p,4)
ymid = ylo + (yhi-ylo)/2

'set t '_t1' '_t2
'set lev 1000'
rh8 = 'rh(lev=850)'
t8 = 't(lev=850)'
t5 = 't(lev=500)'
'set vpage off'
'set grads off'
'set grid on'
'set xlab on'
'set gxout bar'
'set barbase 40'
'set bargap 50'
'define toto = 1/(1/'t8'-log(0.01*'rh8')*461/2.5e6)-2*'t5'+'t8
'set axlim 11 69'
'set yaxis 11 69 10'
'set ccolor 8'
'set t '_t1-0.5' '_t2+0.5
'set grid on'
say totals
'd (toto-40+abs(toto-40))*0.5+40'
'set grid off'
'set ccolor 7'
'd (toto-40-abs(toto-40))*0.5+40'

* draw a rectangle over 'toto' yaxis labels
'set line 0'
'draw recf 0.2 'ylo' 1.175 'yhi-0.07

* Lifted Index
'set gxout line'
'set grid off'
'set vrange 5.9 -5.9'
'set yaxis 5.9 -5.9 2'
'set ccolor 2'
'set cstyle 3'
'set cmark 7'
'set cmax 0'
'set datawarn off'
say lifted index
'd li'

* draw a zero line
'set ccolor 15'
'set cmark 0'
'set cstyle 3'
'd const(li,0)'

'undefine toto'


* Draw a rectangle over the x-axis labels
xlo = subwrd(panel.p,1)
xhi = subwrd(panel.p,2)
ylo = subwrd(panel.p,3)
yhi = subwrd(panel.p,4)
'set line 0'
'draw recf 'xlo-0.4' 'ylo-0.8' 'xhi+0.4' 'ylo-0.02

* Next Panel: SLP
getseries("slp*0.01",slpr,1000)
p = p - 1
'set parea 'panel.p
'set vpage off'
'set lon 'hilon
'set lat 'hilat
'set grid on'
'set gxout contour'
vrng(slpr,slpr)
'set ccolor 11'
'set cmark 0'
'set t '_t1-0.5' '_t2+0.5
say sea level pressure
'd slpr'

'undefine slpr'

* Draw a rectangle over the x-axis labels
xlo = subwrd(panel.p,1)
xhi = subwrd(panel.p,2)
ylo = subwrd(panel.p,3)
yhi = subwrd(panel.p,4)
'set line 0'
'draw recf 'xlo-0.4' 'ylo-0.8' 'xhi+0.4' 'ylo-0.02

* Next Panel: Surface Wind Speed
p = p - 1
'set parea 'panel.p
'set vpage off'
'set grads off'
if (units = 'e')
  ubot = '2.2374*u10m'
  vbot = '2.2374*u10m'
else
  ubot = 'u10m'
  vbot = 'u10m'
endif
'define wind = mag('ubot','vbot')'
vrng(wind,wind)
'set ccolor 26'
'set cmark 7'
'set grid on'
'set t '_t1-0.5' '_t2+0.5
'set gxout contour'
say wind
'd wind'

'undefine wind'


* Draw a rectangle over the x-axis labels
xlo = subwrd(panel.p,1)
xhi = subwrd(panel.p,2)
ylo = subwrd(panel.p,3)
yhi = subwrd(panel.p,4)
'set line 0'
'draw recf 'xlo-0.4' 'ylo-0.8' 'xhi+0.4' 'ylo-0.02

* Next Panel: 2m Temperatures and Indices
getseries(t2m,t2,1000)
getseries(rh2m,rh2m,1000)
p = p - 1
'set parea 'panel.p
'set vpage off'
'set frame on'
'set grads off'
'set ylab on'
'set gxout line'
'set grid off'
if (units = 'e')
  'define m2tc = const((t2-273.16),0,-u)'
  'define m2t  = const((t2-273.16)*9/5+32,0,-u)'
  'define dewpt = m2tc-((14.55+0.114*m2tc)*(1-0.01*rh2m)+pow((2.5+0.007*m2tc)*(1-0.01*rh2m),3)+(15.9+0.117*m2tc)*pow((1-0.01*rh2m),14))'
  'define dewpt = dewpt*9/5+32'
else
  'define m2tf = const((t2-273.16)*1.8+32,0,-u)'
  'define m2t  = const((t2-273.16),0,-u)'
  'define dewpt = m2t-((14.55+0.114*m2t)*(1-0.01*rh2m)+pow((2.5+0.007*m2t)*(1-0.01*rh2m),3)+(15.9+0.117*m2t)*pow((1-0.01*rh2m),14))'

endif
vrng(m2t,dewpt)
'set t '_t1-0.5' '_t2+0.5
if (units = 'e')
  'set ylint 10'
  'set gxout linefill'
  expr = 'm2t;const(m2t'
  'set lfcols  9 0' ; 'd 'expr',-60,-a)'
  'set lfcols  9 0' ; 'd 'expr',-60,-a)'
  'set lfcols 14 0' ; 'd 'expr',-10,-a)'
  'set lfcols  4 0' ; 'd 'expr',0,-a)'
  'set lfcols 11 0' ; 'd 'expr',10,-a)'
  'set lfcols  5 0' ; 'd 'expr',20,-a)'
  'set lfcols 13 0' ; 'd 'expr',30,-a)'
  'set lfcols  3 0' ; 'd 'expr',40,-a)'
  'set lfcols 10 0' ; 'd 'expr',50,-a)'
  'set lfcols  7 0' ; 'd 'expr',60,-a)'
  'set lfcols 12 0' ; 'd 'expr',70,-a)'
  'set lfcols  8 0' ; 'd 'expr',80,-a)'
  'set lfcols  2 0' ; 'd 'expr',90,-a)'
  'set lfcols  6 0' ; 'd 'expr',100,-a)'
  'set gxout line'
  'set ccolor 15'
  'set cstyle 3'
  'set cmark 0'
  'd m2t'
else
  'set ylint 5'
  'set gxout linefill'
  expr = 'm2t;const(m2t'
  'set lfcols  9 0' ; 'd 'expr',-60,-a)'
  'set lfcols 14 0' ; 'd 'expr',-25,-a)'
  'set lfcols  4 0' ; 'd 'expr',-20,-a)'
  'set lfcols 11 0' ; 'd 'expr',-15,-a)'
  'set lfcols  5 0' ; 'd 'expr',-10,-a)'
  'set lfcols 13 0' ; 'd 'expr',-5,-a)'
  'set lfcols  3 0' ; 'd 'expr',0,-a)'
  'set lfcols 10 0' ; 'd 'expr',5,-a)'
  'set lfcols  7 0' ; 'd 'expr',10,-a)'
  'set lfcols 12 0' ; 'd 'expr',15,-a)'
  'set lfcols  8 0' ; 'd 'expr',20,-a)'
  'set lfcols  2 0' ; 'd 'expr',25,-a)'
  'set lfcols  6 0' ; 'd 'expr',30,-a)'
  'set gxout line'
  'set ccolor 15'
  'set cstyle 3'
  'set cmark 0'
  'd m2t'
endif
'set grid on'
'set cmark 8'
'set digsiz 0.05'
'set ccolor 2'
say temperature
'd m2t'
'set ccolor 97'
'set cmark 9'
say dew point
'd dewpt'

'undefine dewpt'
'undefine t2'
'undefine rh2m'
'undefine m2t'
if (units = 'e')
  'undefine m2tc'
else
  'undefine m2tf'
endif



* Draw a rectangle over the x-axis labels
xlo = subwrd(panel.p,1)
xhi = subwrd(panel.p,2)
ylo = subwrd(panel.p,3)
yhi = subwrd(panel.p,4)
'set line 0'
'draw recf 'xlo-0.4' 'ylo-0.8' 'xhi+0.4' 'ylo-0.02

* Back up to Previous Panel: 10m Wind Barbs
p = p + 1
'set parea 'panel.p
'set ccolor 1'
lap1 = hilat + 0.1
lam1 = hilat - 0.1
'set lon 'hilon ;* ??
'set lat 'lam1' 'lap1
'set frame off'
'set grid off'
'set gxout barb'
'set xyrev on'
'set xlab off'
'set ylab off'
say wind barbs
if (units = 'e')
  'd 2.2374*u10m.1;2.2374*v10m.1'
else
  'd u10m.1;v10m.1'
endif

* Reset dimension and graphics parameters
'set lat 'hilat
'set lon 'hilon
'set vpage off'
'set frame on'
'set grads off'
'set ylab on'
'set xlab on'
'set gxout line'
'set grid off'

* Skip to Next Panel: 2m Relative Humidity
p = p - 2
'set parea 'panel.p
*'set vpage off'
*'set grads off'
rh2vrng(rh2m)
'set gxout linefill'
'set lfcols 20 0' ; 'd rh2m;const(rh2m,00.01,-a)'
'set lfcols 21 0' ; 'd rh2m;const(rh2m,20.01,-a)'
'set lfcols 22 0' ; 'd rh2m;const(rh2m,30.01,-a)'
'set lfcols 23 0' ; 'd rh2m;const(rh2m,40.01,-a)'
'set lfcols 24 0' ; 'd rh2m;const(rh2m,50.01,-a)'
'set lfcols 25 0' ; 'd rh2m;const(rh2m,60.01,-a)'
'set lfcols 26 0' ; 'd rh2m;const(rh2m,70.01,-a)'
'set lfcols 27 0' ; 'd rh2m;const(rh2m,80.01,-a)'
'set lfcols 28 0' ; 'd rh2m;const(rh2m,90.01,-a)'
'set ccolor 28'
'set gxout line'
'set grid on'
'set cmark 2'
say relative humidity
'd rh2m'

* Draw a rectangle over the x-axis labels
xlo = subwrd(panel.p,1)
xhi = subwrd(panel.p,2)
ylo = subwrd(panel.p,3)
yhi = subwrd(panel.p,4)
'set line 0'
'draw recf 'xlo-0.4' 'ylo-0.8' 'xhi+0.4' 'ylo-0.02

* Next Panel: Soil Moisture
p = p -1
'set parea 'panel.p
getseries(runoff,runoff,1000)
getseries(soilw1,sm,1000)
'define sm = const(sm,0,-u)'
'set t '_t1+1' '_t2-1
'define ss = tloop(sm(t-1)/4 + sm/2 + sm(t+1)/4)'
'set t '_t1+2' '_t2-1
if (units = 'e')
  'define runoff  = const(runoff,0,-u)/25.4'
  'define dsoilm = tloop((ss-ss(t-1))*39.37)'
else
  'define runoff  = const(runoff,0,-u)'
  'define dsoilm = tloop((ss-ss(t-1))*1000)'
endif
'set vpage off'
vrng(runoff,dsoilm)
'set t '_t1+0.5' '_t2+0.5
'set gxout bar'
'set barbase 0'
'set grid on'
'set bargap 20'
'set ccolor 5'
'set grid on'
'd runoff'
'set ccolor 96'
'set bargap 60'
say soil moisture
'd dsoilm'

* Draw a rectangle over the x-axis labels
xlo = subwrd(panel.p,1)
xhi = subwrd(panel.p,2)
ylo = subwrd(panel.p,3)
yhi = subwrd(panel.p,4)
'set line 0'
'draw recf 'xlo-0.4' 'ylo-0.8' 'xhi+0.4' 'ylo-0.02


* Final Panel: Precipitation
'set dfile 2'
p = p - 1
'set parea 'panel.p
'set vpage off'
'set grid on'
'set grads off'
ptot  = '0.5*(p.2+abs(p.2))'
pconv = '0.5*(pc.2+abs(pc.2))'
if (units = 'e')
  'define ptot  = const('ptot',0,-u)/25.4'
  'define pconv = const('pconv',0,-u)/25.4'
else
  'define ptot  = const('ptot',0,-u)'
  'define pconv = const('pconv',0,-u)'
endif

* Get Total Precipitation Range
'set gxout stat'
'd ptot'
data = sublin(result,8)
pmx = subwrd(data,5)
if (units = 'e')
  if (pmx < 0.05) 
    pmx = 0.0499
  else
    pmx = pmx + (0.05*pmx)
  endif
else
  if (pmx < 1.0) 
    pmx = 0.99
  else
    pmx = pmx + (0.05*pmx)
  endif
endif
'set vrange 0 'pmx
incr = 0.01 * (math_nint(100*pmx/5))
'set ylint 'incr
'set t '_t1+0.5' '_t2+0.5

* Rain (Total Precipitation)
'set gxout bar'
'set barbase 0'
'set bargap 50'
'set ccolor 42'
say total precip
'd ptot'

* Snow
'set ccolor 44'
say snow
'd ptot*csnow'

* Sleet (Freezing Rain)
'set ccolor 45'
say freezing rain
'd ptot*cfrzr'

* Ice Pellets
'set ccolor 46'
say ice pellets
'd ptot*cicep'

* Convective Precipitation
'set gxout bar'
'set bargap 80'
'set ccolor 2'
say convective precip
'd pconv'

* Draw all the Y-axis labels

* First panel
 'set strsiz 0.08 0.12'
'set line 21' ; 'draw recf 0.4 7.65 0.62  8.18'
'set line 22' ; 'draw recf 0.4 7.65 0.58  8.18'
'set line 23' ; 'draw recf 0.4 7.65 0.535 8.18'
'set line 25' ; 'draw recf 0.4 7.65 0.49  8.18'
'set line 26' ; 'draw recf 0.4 7.65 0.445 8.18'
'set string 0 c 4 90' ; 'draw string 0.5 7.93 RH (%)'
'set string 2 l 4 90' ; 'draw string 0.5 8.36 T'
'set string 8 l 4 90' ; 'draw string 0.5 8.43 e'
'set string 5 l 4 90' ; 'draw string 0.5 8.50 m'
'set string 4 l 4 90' ; 'draw string 0.5 8.62 p'
'set string 9 l 4 90' ; 'draw string 0.5 8.69 .'
if (units = 'e')
  'set string 2 l 4 90' ; 'draw string 0.5 8.79 (F)'
  'set string 1 c 4 90' ; 'draw string 0.5 9.53 Wind (mph)'
else
  'set string 2 l 4 90' ; 'draw string 0.5 8.79 (C)'
  'set string 1 c 4 90' ; 'draw string 0.5 9.53 Wind (m/s)'
endif
'draw string 0.75 8.63 `1m i l l i b a r s'

* Next Panel
p = npanels - 1 
ylo = subwrd(panel.p,3)
yhi = subwrd(panel.p,4)
ymid = ylo + (yhi-ylo)/2
'set string  5 c 4 90'  
'draw string 0.5 'ymid' Thickness'
'draw string 0.3 'ymid' 1000-500mb'
'set string  1 c 4 90'  
'draw string 0.74 'ymid' (dm)'

* Next Panel
p = p - 1 
ylo = subwrd(panel.p,3)
yhi = subwrd(panel.p,4)
ymid = ylo + (yhi-ylo)/2
'set string 8 c 4 90' ; 'draw string 0.15 'ymid' Total-totals'

* Total-Totals Y-axis Legend
'set strsiz 0.08 0.11'
'set string 15 r 4 0' ; 'draw string 0.45 'ymid' 40'
'set string  7 r 4 0' ; 'draw string 0.45 'ymid-0.133' 30'
'set string  7 r 4 0' ; 'draw string 0.45 'ymid-0.266' 20'
'set string  8 r 4 0' ; 'draw string 0.45 'ymid+0.133' 50'
'set string  8 r 4 0' ; 'draw string 0.45 'ymid+0.266' 60'
'set strsiz 0.08 0.12'
'set string 2 c 4 90' ; 'draw string 0.69 'ymid' Lifted Index'

* Next Panel
p = p - 1 
ylo = subwrd(panel.p,3)
yhi = subwrd(panel.p,4)
ymid = ylo + (yhi-ylo)/2
'set string 11 c 4 90' ; 'draw string 0.3 'ymid' SLP'
'set string  1 c 4 90' ; 'draw string 0.6 'ymid' (mb)'

* Next Panel
p = p - 1 
ylo = subwrd(panel.p,3)
yhi = subwrd(panel.p,4)
ymid = ylo + (yhi-ylo)/2
'set string 26 c 4 90' ; 'draw string 0.15 'ymid' 10m Wind'
'set string 26 c 4 90' ; 'draw string 0.35 'ymid' Speed'
'set string  1 c 4 90' ; 'draw string 0.55 'ymid' & Barbs'
if (units = 'e')
  'draw string 0.75 'ymid' (mph)'
else
  'draw string 0.75 'ymid' (m/s)'
endif

* Next Panel
p = p - 1 
ylo = subwrd(panel.p,3)
yhi = subwrd(panel.p,4)
ymid = ylo + (yhi-ylo)/2
'set string  2 c 4 90' ; 'draw string 0.15 'ymid' 2m Temp '
'set string 97 c 4 90' ; 'draw string 0.35 'ymid' 2m DewPt '
*'set string 31 c 4 90' ; 'draw string 0.35 'ymid' Wind Chill'
*'set string 30 c 4 90' ; 'draw string 0.55 'ymid' Heat Index'
if (units = 'e')
  'set string 1 c 4 90'
  'draw string 0.75 'ymid' (F)'
else
  'set string 1 c 4 90'
  'draw string 0.75 'ymid' (C)'
endif

* Next Panel
p = p - 1 
ylo = subwrd(panel.p,3)
yhi = subwrd(panel.p,4)
ymid = ylo + (yhi-ylo)/2
'set string 26 c 4 90' ; 'draw string 0.35 'ymid' 2m RH'
'set string  1 c 4 90' ; 'draw string 0.75 'ymid' (%)'

* Next Panel
p = p - 1
ylo = subwrd(panel.p,3)
yhi = subwrd(panel.p,4)
ymid = ylo + (yhi-ylo)/2
'set string  5 c 4 90' ; 'draw string 0.35 'ymid' Runoff'
'set string 96 c 4 90' ; 'draw string 0.55 'ymid' `3d`0[Soil Moist]'
if (units = 'e')
  'set string 1 c 4 90' ; 'draw string 0.75 'ymid' (in)'
else
  'set string 1 c 4 90' ; 'draw string 0.75 'ymid' (mm)'
endif

* Bottom Panel
'set strsiz 0.07 0.10'
dt = 3
if (units = 'e')
  'set string 1 l 4 90' ; 'draw string .82 0.45 'dt'hr Precip (in)'
else
  'set string 1 l 4 90' ; 'draw string .82 0.45 'dt'hr Precip (mm)'
endif

'set string 42 r 4 0' ; 'draw string 0.7 1.3 Total/Rain'
'set string  2 r 4 0' ; 'draw string 0.7 1.1 Convective'
'set string 45 r 4 0' ; 'draw string 0.7 0.9 Frzg. Rain'
'set string 44 r 4 0' ; 'draw string 0.7 0.7 Snow'
'set string 46 r 4 0' ; 'draw string 0.7 0.5 Ice Pellets'

* Draw Labels at the top of the page
'set string 1 r 1 0'
'set strsiz 0.14 .17'
label = 'GFS 0-180hr Forecast Meteogram for ('
if (hilon < 0)  ; label = label%hilon*(-1.0)'W, ' ; endif
if (hilon >= 0) ; label = label%hilon'E, ' ; endif
if (hilat < 0)  ; label = label%hilat*(-1.0)'S)'; endif
if (hilat >= 0) ; label = label%hilat'N)' ; endif

'draw string 8.15 10.75 'label

'set line 0'
'draw recf 0.5 0 3.95 0.0918'

* Draw the station label
'set strsiz 0.18 0.22'
'set string 21 l 12 0' ; 'draw string 0.12 10.79 `1'name
'set string  1 l  8 0' ; 'draw string 0.10 10.81 `1'name

* Print out an image file
if (printim)
  'printim 'stid'gfs.png x850 y1100'
endif


'undefine sm'
'undefine ss'
'undefine runoff'
'undefine dsoilm'
'undefine ptot'
'undefine pconv'


* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
* END OF MAIN SCRIPT
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 

function setcols(args)
'set rgb 20 234 245 234'
'set rgb 21 200 215 200'
'set rgb 22 160 205 160'
'set rgb 23 120 215 120'
'set rgb 24  80 235  80'
'set rgb 25   0 255   0'
'set rgb 26   0 195   0'
'set rgb 27   0 160   0'
'set rgb 28   0 125   0'

'set rgb 30 255 160 120'
'set rgb 31 160 120 255'
'set rgb 32 160 180 205'

'set rgb 42  32 208  32'
'set rgb 43 208  32 208'
'set rgb 44  64  64 255'
'set rgb 45 255 120  32'
'set rgb 46  32 208 208'
'set rgb 47 240 240   0'

'set rgb 96 139 115  85'
'set rgb 97 100 100 100'
'set rgb 98  64  64  96'
'set rgb 99 254 254 254'
return

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
function vrng(f1,f2)
'set gxout stat'
'd 'f1
data = sublin(result,8)
ymx = subwrd(data,5)
ymn = subwrd(data,4)
'd 'f2
data = sublin(result,8)
zmx = subwrd(data,5)
zmn = subwrd(data,4)
if (zmx > ymx) ; ymx = zmx ; endif
if (zmn < ymn) ; ymn = zmn ; endif
dy = ymx-ymn
ymx = ymx + 0.08 * dy
ymn = ymn - 0.08 * dy
if ((ymx-ymn)/2.2 < 1)
  incr = (ymx-ymn)/4
  incr = 0.01 * (math_nint(100*incr))
else
  incr = math_nint((ymx-ymn)/4)
endif
'set vrange 'ymn' 'ymx
'set ylint 'incr
*say 'vrng: 'ymn' 'ymx' 'incr
if (ymn=0 & ymx=0 & incr=0)
*  say 'vrng: resetting zeros to -.9 .9 1'
  'set vrange -.9 .9'
  'set ylint 1'
endif
'set gxout line'
return

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
function rh2vrng(f1)
'set gxout stat'
'd 'f1
data = sublin(result,8)
ymn = subwrd(data,4)
ymx = subwrd(data,5)
if (ymn < 20) 
  miny = 0 
  'set ylevs 20 40 60 80'
endif
if (ymn >= 20 & ymn < 30) 
  miny = 20 
  'set ylevs 30 50 70 90'
endif
if (ymn >= 30 & ymn < 40) 
  miny = 30 
  'set ylevs 40 50 60 70 80 90'
endif
if (ymn >= 40 & ymn < 50) 
  miny = 40 
  'set ylevs 50 60 70 80 90'
endif
if (ymn >= 50 & ymn < 60) 
  miny = 50
  'set ylevs 60 70 80 90'
endif
if (ymn >= 60) 
  miny = 60
  'set ylevs 70 80 90'
endif
'set vrange 'miny' 'ymx+3
return

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
function getctl(handle)
line = 1
found = 0
while (!found)
  info = sublin(_ctl,line)
  if (subwrd(info,1)=handle)
    _handle = info
    found = 1
  endif
  line = line + 1
endwhile
return _handle

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
function getseries(dodsvar,myvar,level)

'set lon '_xdim
'set lat '_ydim
'set lev 'level' 'level
'set time '_tdim
'define 'myvar' = 'dodsvar
return

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
function getgrid(dodsvar,myvar)

'set lon '_xdim
'set lat '_ydim
'set lev '_zgrd
'set time '_tdim
'define 'myvar' = 'dodsvar
return

