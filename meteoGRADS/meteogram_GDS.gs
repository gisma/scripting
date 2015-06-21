#!/home/creu/progs/opengrads/Contents/Resources/Scripts/grads2
* * * * * * * * * * * * *
* * * * * * * * * * * * 
* meteogram_GDS.gs
* 
* This script will draw a meteogram, a multi-panel plot showing time series of forecasts for selected 
* variables at a given location. The required data files must be created before running this script.
* Use the companion script meteogram_subset_GDS.gs to write out the data. 
* For best results, use GrADS version 2.1. 
* 
* The script requires one argument: e (for English units) or m (for metric units). 
* 
* Written by Jennifer M. Adams (jma@iges.org)
* 
* Both scripts are available to download at: 
*   ftp://cola.gmu.edu/grads/scripts/meteogram_subset_GDS.gs
*   ftp://cola.gmu.edu/grads/scripts/meteogram_GDS.gs
* * * * * * * * * * * *

function main(arg)
* Make sure GrADS page is square
'q gxinfo'
pagesize = sublin(result,2)
xsize = subwrd(pagesize,4)
ysize = subwrd(pagesize,6)
if (xsize != 11 | ysize != 11)
  say '* * * * * * * * * * * * * * * * * * * * * * * * *'
  say '* You MUST use "grads -a 1" to draw a meteogram *'
  say '* * * * * * * * * * * * * * * * * * * * * * * * *'
  'quit'
endif
  
* Parse the argument (if not given, default unit is metric)
if (arg='')
  say 'no arguments'
  return
else
  units=subwrd(arg,1)
  if (units!='m' & units!='e')
    say 'The unit arg was not e or m, using default metric units'
    units='m'
  endif
  fn=subwrd(arg,2)
  locname=subwrd(arg,3)
endif

* Set print=1 to generate an image output file
print=1

* Open the data files
'reinit'
'open 'fn'.ctl'
if (rc)
  say 'Failed to open 'fn'.ctl'
  return
endif
'open 'fn'p.ctl'
if (rc)
  say 'Failed to open 'fn'p.ctl'
  return
endif

* Get the lat/lon of the subset data
'set dfile 1'
'q dims'
xdims=sublin(result,2); hilon=subwrd(xdims,6)
ydims=sublin(result,3); hilat=subwrd(ydims,6)

* Get info from the descriptor file
'q ctlinfo'
_ctl = result
_tdef = getctl(tdef)
_zdef = getctl(zdef)

* Get the time axis info
* 6hrs are knocked off the time range so time axis labeling will be every 24 hours
tsize = subwrd(_tdef,2)
_t1 = 1
_t2 = tsize-2     
'set t '_t1' '_t2
'q dims'
times  = sublin(result,5)
_time1 = subwrd(times,6)  
_time2 = subwrd(times,8)
_tdim = _time1' '_time2

* Get the levels
levmax=450
zsize = subwrd(_zdef,2)
z = 1
zlevs = ''
while (z <= zsize)
  'set z 'z
  lev = subwrd(result,4)
  zlevs = zlevs%lev%' '
  z = z + 1
endwhile
say ps
* Determine pressure range for top panel
'set warn off'
'set gxout contour'
'set t 1'
'set z 1'
'd ave(ps,t='_t1',t='_t2')*0.01-15.0'
data = sublin(result,1)
mmm = subwrd(data,4)
meanps = math_nint(mmm)
cnt = 1
while (cnt<zsize)
  el1 = subwrd(zlevs,cnt)
  el2 = subwrd(zlevs,cnt+1)
  if (meanps > el2)
    elb = el1
    break
  endif
  cnt=cnt+1
endwhile
_zbot = elb
_ztop = levmax
_zgrd = _zbot' '_ztop

* Determine the plot areas for each panel
npanels = 8
x1 =  1.2
x2 = 10.9
y1 =  6.6
y2 = 10.3
_panel.npanels = x1' 'x2' 'y1' 'y2   ;* hovmoeller panel
hmid = y1 + 0.5*(y2-y1)
ytop = 6.6  ;* y boundaries for rest of panels except precip
ybot = 1.5
int = (ytop-ybot)/(npanels-2)     ;* get height of middle panels
int = 0.001 * (math_nint(1000*int))
n=npanels-1
y2 = ytop
while (n >= 2)
  y2 = ytop - (npanels-n-1)*int
  y1 = ytop - (npanels-n)*int
  _panel.n = x1' 'x2' 'y1' 'y2        ;* coords of middle panels
  n = n - 1
endwhile
xincr = (x2 - x1)/tsize           ;* size of one time step
xincr = 0.01 * math_nint(100*xincr)
_panel.1 = x1+xincr' 'x2' 0.4 'y1     ;* coords of precip panel

* Indent the cloud cover panel too
w2 = subwrd(_panel.2,2)
w3 = subwrd(_panel.2,3)
w4 = subwrd(_panel.2,4)
_panel.2 = x1+xincr' 'w2' 'w3' 'w4
precf.2 = x1+xincr' 'w3' 'w2' 'w4


* * * TIME TO START DRAWING STUFF * * *

* Set up a few global characteristics
setcols()
'set display color white'
'clear'
'set ylopts 1 2 0.09'
'set xlopts 1 1 0.115'
'set annot 1 4'
'set datawarn off'
'set hershey off'

* Set the Plot Area for the Upper Air Panel
p = npanels
'set parea '_panel.p
'set vpage off'
'set grads off'
'set grid on 3 15 2'

* Draw the Relative Humidity Shading
'set gxout shaded'
'set csmooth on'
'set clevs  30 50 70 90 100'
'set ccols 0 20 21 23 25 26'
'set xlpos 0 t'
'set ylab on'
'set xlab on'
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
'set lev '_zbot+50' '_ztop
'd rh'
* draw RH contours
'set gxout contour'
'set grid off'
'set ccolor 15'
'set clab masked'
'set clskip 2'
'set clopts -1 1 0.07'
'set xlab off'
'set ylab off'
'set clevs 10 30 50 70 90'
'd rh'

* Draw the Temperature Contours
if (units = 'e') 
  cint=10
  frlvl=32
else
  cint=5
  frlvl=0
endif
* figure out contour levels, but don't include zero
* because that will be drawn as the FR level
'set gxout stat'
'd 'temp
data = sublin(result,8)
ymx = subwrd(data,5)
ymn = subwrd(data,4)
r = math_fmod(ymn,cint)
cmin=ymn-r
clevs=''
while(cmin<=ymx)
  if (cmin='0' & units='m')
    clevs=clevs
  else
    clevs=clevs%' 'cmin
  endif
  cmin=cmin+cint
endwhile
* draw all contours
'set gxout contour'
'set cstyle 1'
'set ccolor rainbow'
'set rbcols 9 14 4 11 5 13 12 8 2 6'
'set ylab off'
'set xlab off'
'set clskip 1 3.5'
'set clopts -1 1 0.11'
'set font 4'
'set cint 'cint
'set clevs 'clevs
'set cthick 8'
'set clab masked'
'd 'temp
'clear mask'
'set font 0'
* draw the freezing level
'set clevs 'frlvl
'set cthick 12'
'set ccolor 1'
'set clab masked'
'set clskip 1 2.5'
'set clopts -1 1 0.09'
'set clab `4FR'
'd 'temp
'set ccolor 20'
'set clevs 'frlvl
'set cthick 4'
'set clab off'
'd 'temp
* Draw the Wind Barbs
'set gxout barb'
'set digsiz 0.04'
'set cthick 1'
'set ccolor 132'
'd 'uwnd';'vwnd

* Draw a rectangle over the year to clear the area for a title
'set line 0'
'draw recf 0.5 10.53 2.5 11.0'


* Next Panel: SLP and 1000-500 thickness
p = p - 1
'set parea '_panel.p
* sea level pressure
'set lev 1000'
getseries("slp*0.01",slpr,1000)
'set vpage off'
'set grid off'
'set ylab on'
'set gxout line'
dy=vrng(slpr,slpr)
'set ccolor 4'
'set cthick 6'
'set cmark 0'
'set t '_t1-0.5' '_t2+0.5
'd slpr'
* 1000-500mb Thickness
'set t '_t1' '_t2
'set vpage off'
'set grads off'
'set grid on 3 15 2'
'set xlab on'
'set ylab on'
dy=vrng("thk/10","thk/10")
'set ccolor 5'
'set cmark 8'
'set digsiz 0.05'
'set ylpos -0.51 l'
'set t '_t1-0.5' '_t2+0.5
'd thk/10'

coverup(p)

* Next Panel: Stability Indices
p = p - 1
'set parea '_panel.p
ylo = subwrd(_panel.p,3)
yhi = subwrd(_panel.p,4)
ymid = ylo + (yhi-ylo)/2
'set t '_t1' '_t2
'set lev 1000'
'set vpage off'
'set grads off'
'set grid off'
'set xlab on'
* CAPE
'set gxout bar'
'set bargap 50'
dy=vrng(capes,capes)
'set gxout bar'
'set t '_t1-0.5' '_t2+0.5
'set ccolor 19'
capes='maskout(capes,capes-0.0001)'
'd 'capes
* Lifted Index
'set gxout line'
'set ccolor 2'
'set cstyle 1'
'set cthick 4'
'set cmark 7'
'set digsiz 0.045'
'set datawarn off'
'set ylpos -0.7 l'
'set vrange 6 -6'
'set ylint 3'
'set grid on 3 15 2'
'd li'
* draw a zero line for LI
'set ccolor 2'
'set grid off'
'set cmark 0'
'set ylab off'
'set cstyle 3'
'd const(li,0)'

coverup(p)

* Next Panel: Surface Wind speed and barbs
p = p - 1
'set parea '_panel.p
'set vpage off'
'set grads off'
if (units = 'e')
  ubot = '2.2374*u10m'
  vbot = '2.2374*v10m'
else
  ubot = 'u10m'
  vbot = 'v10m'
endif
* draw line plot of wind speed
'wind = mag('ubot','vbot')'
dy=vrng(wind,wind)
'set ccolor 130'
'set digsiz 0.05'
'set grid on 3 15 2'
'set cmark 7'
'set ylab on'
'set t '_t1-0.5' '_t2+0.5
'set gxout contour'
'd wind'
* draw wind barbs
'set ccolor 131'
'set frame off'
'set grid off'
'set gxout barb'
'set vrange -5 5'
'set xlab off'
'set ylab off'
'set cthick 2'
'set digsiz 0.065'
'd const('ubot',0);'ubot';'vbot

coverup(p)

* Next Panel: 2m Temperatures and Indices
getseries(t2m,t2,1000)
getseries(td2m,dt2,1000)
getseries(t2min,tmin2,1000)
getseries(t2max,tmax2,1000)
getseries(rh2m,rh2m,1000)
p = p - 1
'set parea '_panel.p
'set vpage off'
'set frame on'
'set grads off'
'set ylab on'
'set gxout line'
'set grid off'
if (units = 'e')
  'define m2t   = (t2-273.16)*9/5+32'    ;* convert Kelvin to Farenheit
  'define dewpt = (dt2-273.16)*9/5+32'  
  'define tmin  = (tmin2-273.16)*9/5+32'
  'define tmax  = (tmax2-273.16)*9/5+32'
else
  'define m2t   = t2-273.16'           ;* convert Kelvin to Celsius
  'define dewpt = dt2-273.16'         
  'define tmin  = tmin2-273.16'         
  'define tmax  = tmax2-273.16'         
endif
dy=vrng(tmax,dewpt)
'set xlab off'
'set ylab off'
'set grid off'
'set t '_t1-0.5' '_t2+0.5
if (units = 'e')
  if (dy>50)
    'set ylint 16'
  else
    'set ylint 8'
  endif
  'set gxout linefill'
  expr = 'm2t;const(m2t'
  'set lfcols 200 0' ; 'd 'expr',-32,-a)'
  'set lfcols 201 0' ; 'd 'expr',-24,-a)'
  'set lfcols 202 0' ; 'd 'expr',-16,-a)'
  'set lfcols 203 0' ; 'd 'expr',-8,-a)'
  'set lfcols 204 0' ; 'd 'expr',0,-a)'
  'set lfcols 205 0' ; 'd 'expr',8,-a)'
  'set lfcols 206 0' ; 'd 'expr',16,-a)'
  'set lfcols 207 0' ; 'd 'expr',24,-a)'
  'set lfcols 208 0' ; 'd 'expr',32,-a)'
  'set lfcols 209 0' ; 'd 'expr',40,-a)'
  'set lfcols 210 0' ; 'd 'expr',48,-a)'
  'set lfcols 211 0' ; 'd 'expr',56,-a)'
  'set lfcols 212 0' ; 'd 'expr',64,-a)'
  'set lfcols 213 0' ; 'd 'expr',72,-a)'
  'set lfcols 214 0' ; 'd 'expr',80,-a)'
  'set lfcols 215 0' ; 'd 'expr',88,-a)'
  'set lfcols 216 0' ; 'd 'expr',96,-a)'
  'set lfcols 217 0' ; 'd 'expr',104,-a)'
  'set lfcols 218 0' ; 'd 'expr',112,-a)'
else
  if (dy>25)
    'set ylint 8'
  else
    'set ylint 4'
  endif
  'set gxout linefill'
  expr = 'm2t;const(m2t'
  'set lfcols 200 0' ; 'd 'expr',-32,-a)'
  'set lfcols 201 0' ; 'd 'expr',-28,-a)'
  'set lfcols 202 0' ; 'd 'expr',-24,-a)'
  'set lfcols 203 0' ; 'd 'expr',-20,-a)'
  'set lfcols 204 0' ; 'd 'expr',-16,-a)'
  'set lfcols 205 0' ; 'd 'expr',-12,-a)'
  'set lfcols 206 0' ; 'd 'expr',-8,-a)'
  'set lfcols 207 0' ; 'd 'expr',-4,-a)'
  'set lfcols 208 0' ; 'd 'expr',0,-a)'
  'set lfcols 209 0' ; 'd 'expr',4,-a)'
  'set lfcols 210 0' ; 'd 'expr',8,-a)'
  'set lfcols 211 0' ; 'd 'expr',12,-a)'
  'set lfcols 212 0' ; 'd 'expr',16,-a)'
  'set lfcols 213 0' ; 'd 'expr',20,-a)'
  'set lfcols 214 0' ; 'd 'expr',24,-a)'
  'set lfcols 215 0' ; 'd 'expr',28,-a)'
  'set lfcols 216 0' ; 'd 'expr',32,-a)'
  'set lfcols 217 0' ; 'd 'expr',36,-a)'
  'set lfcols 218 0' ; 'd 'expr',40,-a)'
endif
* dewpoint
'set gxout line'
'set cthick 4'
'set ccolor 201'
'set cmark 0'
'set cstyle 1'
'd dewpt'
'set cthick 6'
'set ccolor 220'
'set cmark 0'
'set cstyle 3'
'd dewpt'
* temperature
'set cmark 0'
'set ccolor 218'
'set cstyle 1'
'd m2t'
'set ylab on'
'set xlab on'
'set grid on 3 15 2'
* temperature extremes
'set gxout errbar'
'set bargap 65'
'set cthick 4'
'set ccolor 220'
'd tmin;tmax'
* draw a freezing line
if (units = 'e')
  'q gr2xy 0 32'
else
  'q gr2xy 0 0'
endif
ypos = subwrd(result,6)
xl = subwrd(_panel.p,1)
xr = subwrd(_panel.p,2)
yb = subwrd(_panel.p,3)
yt = subwrd(_panel.p,4)
if (ypos<yt & ypos>yb)
  'set line 1 6 3'
  'draw line 'xl' 'ypos' 'xr' 'ypos
endif

coverup(p)

* Next Panel: 2m Relative Humidity
p = p - 1
'set parea '_panel.p
'set vpage off'
'set frame on'
rh2vrng(rh2m)
'set grid off'
'set grads off'
'set ylab off'
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
'set grid on 3 15 2'
'set cmark 2'
'set digsiz 0.04'
'set ylab on'
'set xlab on'
'd rh2m'

coverup(p)

* Next Panel: Cloud Cover
p = p -1
'set parea '_panel.p
'set line 38'
'draw recf 'precf.p
cutoff=5
v1='maskout(lcc,lcc-'cutoff')'
v2='maskout(110+mcc,mcc-'cutoff')'
v3='maskout(220+hcc,hcc-'cutoff')'
getseries(v1,low,1000)
getseries(v2,mid,1000)
getseries(v3,high,1000)
'set t '_t1+0.5' '_t2+0.5
'set vpage off'
'set vrange -10 330'
'set gxout bar'
'set grid off'
'set ylab off'
* low clouds
'set barbase 0'
'set bargap 0'
'set barbase 0'
'set baropts filled'
'set ccolor 35'
'd low'
* middle clouds
'set barbase 110'
'set grid off'
'set ylab off'
'set baropts filled'
'set ccolor 34'
'd mid'
* high clouds
'set barbase 220'
'set grid on 3 37 2'
'set ylevs 0 110 220'
'set ylab on'
'set ylab %'
'set baropts filled'
'set ccolor 33'
'd high'

coverup(p)

* Final Panel: Precipitation
'set dfile 2'
p = p - 1
'set parea '_panel.p
'set vpage off'
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
* get a run total 
'set t ' _t2+0.5
'set gxout contour'
'd sum(ptot,t=0,t+0)'
runtotal=subwrd(result,4)
runtot = 0.01 * (math_nint(100*runtotal))
'set t '_t1+0.5' '_t2+0.5
* Rain (Total Precipitation)
'set gxout bar'
'set barbase 0'
'set bargap 20'
'set ccolor 42'
'set grid on 3 15 2'
'set xlab on'
'set ylab on'
'd ptot'
* Snow
'set grid off'
'set xlab off'
'set ylab off'
'set ccolor 44'
'd ptot*csnow'
* Sleet (Freezing Rain)
'set ccolor 45'
'd ptot*cfrzr'
* Ice Pellets
'set ccolor 46'
'd ptot*cicep'
* Convective Precipitation
'set gxout bar'
'set bargap 75'
'set ccolor 2'
'd pconv'
* cover the year on bottom x axis label
'set line 0'
'draw recf 1.27 0 4.0 0.18'


* Draw all the Y-axis labels

* First panel
'set strsiz 0.09 0.12'
'set line 21' ; 'draw recf 0.4 7.65 0.62  8.18'
'set line 22' ; 'draw recf 0.4 7.65 0.58  8.18'
'set line 23' ; 'draw recf 0.4 7.65 0.535 8.18'
'set line 25' ; 'draw recf 0.4 7.65 0.49  8.18'
'set line 26' ; 'draw recf 0.4 7.65 0.445 8.18'
'set string 1 c 4 90' ; 'draw string 0.5 7.93 RH (%)'

'set string  2 l 4 90' ; 'draw string 0.5 8.37 T'
'set string  8 l 4 90' ; 'draw string 0.5 8.43 e'
'set string 12 l 4 90' ; 'draw string 0.5 8.50 m'
'set string  7 l 4 90' ; 'draw string 0.5 8.62 p'
'set string 10 l 4 90' ; 'draw string 0.5 8.69 e'
'set string  3 l 4 90' ; 'draw string 0.5 8.77 r'
'set string 13 l 4 90' ; 'draw string 0.5 8.82 a'
'set string  5 l 4 90' ; 'draw string 0.5 8.89 t'
'set string 11 l 4 90' ; 'draw string 0.5 8.94 u'
'set string  4 l 4 90' ; 'draw string 0.5 9.03 r'
'set string 14 l 4 90' ; 'draw string 0.5 9.08 e'

if (units = 'e')
  'set string 2 l 1 90' ; 'draw string 0.5 9.23 (`3.`0F)'
  'set string 1 c 4 90' ; 'draw string 0.5 9.93 Wind (mph)'
else
  'set string 2 l 1 90' ; 'draw string 0.5 9.23 (`3.`0C)'
  'set string 1 c 4 90' ; 'draw string 0.5 9.93 Wind (m/s)'
endif
'set string 1 c 2 90'
'draw string 0.79 'hmid' (m i l l i b a r s)'

* SLP & Thickness Panel
p = npanels - 1 
ylo = subwrd(_panel.p,3)
yhi = subwrd(_panel.p,4)
ymid = ylo + (yhi-ylo)/2
'set string 5 c 5 90' ; 'draw string 0.15 'ymid' 1000-500mb'
'set string 5 c 5 90' ; 'draw string 0.32 'ymid' Thcknss (dm)'
'set string 4 c 5 90' ; 'draw string 0.79  'ymid' SLP (mb)'

* Stability Panel
p = p - 1 
ylo = subwrd(_panel.p,3)
yhi = subwrd(_panel.p,4)
ymid = ylo + (yhi-ylo)/2
'set string 19 c 4 90' ; 'draw string 0.79 'ymid' CAPE (J/kg)'
'set string  2 c 4 90' ; 'draw string 0.18 'ymid' Lifted Index'

* Surface Winds Panel
p = p - 1 
ylo = subwrd(_panel.p,3)
yhi = subwrd(_panel.p,4)
ymid = ylo + (yhi-ylo)/2
'set string 130 c 5 90' ; 'draw string 0.15 'ymid' 10m Wind'
'set string 130 c 5 90' ; 'draw string 0.35 'ymid' Speed'
'set string 131 c 2 90' ; 'draw string 0.55 'ymid' & Barbs'
if (units = 'e')
  'set string 1 c 2 90'; 'draw string 0.75 'ymid' (mph)'
else
  'set string 1 c 2 90'; 'draw string 0.75 'ymid' (m/s)'
endif

* Surface Temperatures Panel
p = p - 1 
ylo = subwrd(_panel.p,3)
yhi = subwrd(_panel.p,4)
ymid = ylo + (yhi-ylo)/2
'set string 218 c 5 90' ; 'draw string 0.15 'ymid' 2m Temp'
'set string 218 c 5 90' ; 'draw string 0.35 'ymid' 2m DewPt'
'set string 218 c 5 90' ; 'draw string 0.55 'ymid' (6hr Min/Max)'
if (units = 'e')
  'set string 1 c 1 90'; 'draw string 0.75 'ymid' (`3.`0F)'
else
  'set string 1 c 1 90'; 'draw string 0.75 'ymid' (`3.`0C)'
endif

* Surface Humidity Panel
p = p - 1 
ylo = subwrd(_panel.p,3)
yhi = subwrd(_panel.p,4)
ymid = ylo + (yhi-ylo)/2
'set string 26 c 5 90' ; 'draw string 0.35 'ymid' 2m RH'
'set string  1 c 2 90' ; 'draw string 0.75 'ymid' (%)'

* Cloud Cover Panel
p = p - 1
ylo = subwrd(_panel.p,3)
yhi = subwrd(_panel.p,4)
ymid = ylo + (yhi-ylo)/2
y3rd = (yhi-ylo)/3
'set string 36 c 5 90' ; 'draw string 0.25 'ymid' Cloud Cover'
'set string  1 c 2 90' ; 'draw string 0.45 'ymid' (%)'
'set string 1 r 2  0'; 
'draw string 1.22 'ymid-y3rd' low' 
'draw string 1.22 'ymid' middle'   
'draw string 1.22 'ymid+y3rd' high'

* Precipitation Panel
p = p - 1
dt = 3
'set string 42 r 4 0' ; 'draw string 0.7 1.3 Total / Rain'
'set string  2 r 4 0' ; 'draw string 0.7 1.1 Convective'
'set string 45 r 4 0' ; 'draw string 0.7 0.9 Frzg. Rain'
'set string 44 r 4 0' ; 'draw string 0.7 0.7 Snow'
'set string 46 r 4 0' ; 'draw string 0.7 0.5 Ice Pellets'
if (units = 'e')
  'set string 1 l 4 90' ; 'draw string .82 0.5 'dt'hr Precip (in)'
else
  'set string 1 l 4 90' ; 'draw string .82 0.5 'dt'hr Precip (mm)'
endif
yhi = subwrd(_panel.p,4)
'set strsiz 0.09 0.10'
'set string 1 tr 4 0'; 'draw string 10.86 'yhi-0.04' Run Total = 'runtot

* Draw Labels at the top of the page
'set string 1 r 5.7 0'
'set strsiz 0.13 0.158'
label = '`1GFS 0~5day 3-hourly Forecast Meteogram for 'locname' ('
if (hilon < 0)  ; label = label%hilon*(-1.0)'W, ' ; endif
if (hilon >= 0) ; label = label%hilon'E, ' ; endif
if (hilat < 0)  ; label = label%hilat*(-1.0)'S)'; endif
if (hilat >= 0) ; label = label%hilat'N)' ; endif
'draw string 10.8 10.75 'label


* Print out an image file
if (print)
  'printim  mymeteogram.png x1980 y1980'
endif
quit
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
* END OF MAIN SCRIPT
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 

function setcols()
alpha=120
'set rgb 19 200 120 250 '
'set rgb 20 234 245 234 '
'set rgb 21 200 215 200 'alpha
'set rgb 22 160 205 160 'alpha
'set rgb 23 120 215 120 'alpha
'set rgb 24  80 235  80 'alpha
'set rgb 25   0 255   0 'alpha
'set rgb 26   0 195   0 'alpha
'set rgb 27   0 160   0 'alpha
'set rgb 28   0 125   0 'alpha

'set rgb 30 255 160 120'
'set rgb 31 160 120 255'
'set rgb 32 160 180 205'

'set rgb 33 250 245 250'
'set rgb 34 235 235 235'
'set rgb 35 220 220 220'
'set rgb 36  66 146 198'
'set rgb 37 135 135 135'
'set rgb 38 107 174 214 220' ;* sky blue

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

alpha=255
'set rgb 100 220 210 220 'alpha
'set rgb 101 200 180 200 'alpha
'set rgb 102 176 160 192 'alpha
'set rgb 103 160 144 176 'alpha
'set rgb 104 144 128 160 'alpha
'set rgb 105 128 112 144 'alpha
'set rgb 106 144  96 160 'alpha
'set rgb 107 176  32 192 'alpha
'set rgb 108 144  62 224 'alpha
'set rgb 109 128  30 255 'alpha
'set rgb 110  64  94 255 'alpha
'set rgb 111  64 128 240 'alpha
'set rgb 112  64 160 240 'alpha
'set rgb 113  64 160 240 'alpha
'set rgb 114  32 196 240 'alpha
'set rgb 115   0 224 176 'alpha
'set rgb 116  40 200 104 'alpha
'set rgb 117   0 230   0 'alpha
'set rgb 118 160 240   0 'alpha
'set rgb 119 250 250  80 'alpha
'set rgb 120 250 196  85 'alpha
'set rgb 121 240 160  70 'alpha
'set rgb 122 240 128  50 'alpha
'set rgb 123 255  86  25 'alpha
'set rgb 124 255   0   0 'alpha
'set rgb 125 210  40  40 'alpha
'set rgb 126 180  40  40 'alpha
'set rgb 127 150  40  40 'alpha
'set rgb 128 120  40  40 'alpha

'set rgb 130 255 142  20'
'set rgb 131 139 115  85'
'set rgb 132  60  60  60'

* palette for t2m panel
*grey
'set rgb 200 230 230 230 '
'set rgb 201 220 220 220 '
'set rgb 202 210 200 210 '
'set rgb 203 176 160 185 170'
'set rgb 204 144 128 160 170'
*purple
'set rgb 205 127  85 210 200'
'set rgb 206 170 127 255 200'
'set rgb 207 213 170 255 250'
*blue
'set rgb 208 150 210 250 200'
'set rgb 209  80 165 245 200'
'set rgb 210  40 130 240 200'
*green
alpha=220
'set rgb 211  40 190  40 'alpha
'set rgb 212  80 240  80 'alpha
*yellow
'set rgb 213 244 255 120 '
*orange to red
'set rgb 214 255 182  60 'alpha
'set rgb 215 255 110   0 'alpha
'set rgb 216 250  50   0 'alpha
'set rgb 217 180   0   0 'alpha
'set rgb 218 120  70  60 240'

'set rgb 220 120  80  70'
'set rgb 221 140 100  90'

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
if (f1='capes' & ymx>1)
  ymn=1
endif
if ((ymx-ymn)/2.2 < 1)
  incr = (ymx-ymn)/4
  incr = 0.01 * (math_nint(100*incr))
else
  incr = math_nint((ymx-ymn)/4)
endif
'set vrange 'ymn' 'ymx
'set ylint 'incr
if (ymn=0 & ymx=0 & incr=0)
  'set vrange -.9 .9'
  'set ylint 1'
endif
'set gxout line'
return dy

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

'set lev 'level' 'level
'set time '_tdim
'define 'myvar' = 'dodsvar
return


* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
* Draws a rectangle over the x-axis labels
function coverup(p)
xlo = subwrd(_panel.p,1)
xhi = subwrd(_panel.p,2)
ylo = subwrd(_panel.p,3)
yhi = subwrd(_panel.p,4)
'set line 0'
'draw recf 'xlo-0.4' 'ylo-0.8' 'xhi+0.4' 'ylo-0.02
