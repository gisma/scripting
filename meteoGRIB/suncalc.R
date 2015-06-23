#!/usr/bin/Rscript
## Source http://www.r-bloggers.com/approximate-sunrise-and-sunset-times/
## adapted Chris Reudenbach
##
## date is the date "%m/%d/%Y" 
## Lat  is latitude in decimal degrees
## Long is longitude in decimal degrees (negative = West)


## This method is copied from:
## Teets, D.A. 2003. Predicting sunrise and sunset times.
##  he College Mathematics Journal 34(4):317-321.

## At the given location the estimates of sunrise and sunset are within
## seven minutes of the correct times (http://aa.usno.navy.mil/data/docs/RS_OneYear.php)
## with a mean of 2.4 minutes error.
library(stringr)

# getting the args
  args<-commandArgs(TRUE)
  date=as.character(args[1])
  Lat=as.numeric(args[2]) 
  Long=as.numeric(args[3])

  date='23/06/2015'
  Lat=50.8
  Long=8.8
# convert day to julian day
  d=strptime(date, "%d/%m/%Y")$yday+1
  
## Function to convert degrees to radians
  rad<-function(x)pi*x/180
  
##Radius of the earth (km)
  R=6378
  
##Radians between the xy-plane and the ecliptic plane
  epsilon=rad(23.45)
  
##Convert observer's latitude to radians
  L=rad(Lat)
  
## Calculate offset of sunrise based on longitude (min)
## If Long is negative, then the mod represents degrees West of
## a standard time meridian, so timing of sunrise and sunset should
## be made later.
  timezone = -4*(abs(Long)%%15)*sign(Long)
  
  ## The earth's mean distance from the sun (km)
  r = 149598000
  
  theta = 2*pi/365.25*(d-80)
  
  z.s = r*sin(theta)*sin(epsilon)
  r.p = sqrt(r^2-z.s^2)
  
  t0 = 1440/(2*pi)*acos((R-z.s*sin(L))/(r.p*cos(L)))
  
  ##a kludge adjustment for the radius of the sun
  that = t0+5 
  
  ## Adjust "noon" for the fact that the earth's orbit is not circular:
  n = 720-10*sin(4*pi*(d-80)/365.25)+8*sin(2*pi*d/365.25)
  
  ## now sunrise and sunset are:

  sunrise.hour = floor((n-that+timezone)/60)
  sunrise.min = round(((n-that+timezone)/60-floor(n-that+timezone)/60)/100*60,digits = 0)
  sunset.hour = floor((n+that+timezone)/60)
  sunset.min = round(((n+that+timezone)/60-floor(n-that+timezone)/60)/100*60,digits = 0)
  
  sunset=paste0(str_pad(sunset.hour, 2, pad = "0"),":",str_pad(sunset.min, 2, pad = "0")," Uhr UTC")
  sunrise=paste0(str_pad(sunrise.hour, 2, pad = "0"),":",str_pad(sunrise.min, 2, pad = "0")," Uhr UTC")
  string<-paste0(sunrise,",",sunset)
  cat(string, "\n")
#}
  
  
