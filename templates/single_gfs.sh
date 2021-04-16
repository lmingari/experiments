#!/bin/bash

DATE=$(date +"%Y%m%d")
CYCLE=$(printf %02d ${gfs_cycle})
HOUR=$(printf %03d $1)
BASEPATH="${PRJDIR}"

if [[ $CYCLE -eq 0 ]]; then
    DATE_URL=$(date +"%Y%m%d")
else
    DATE_URL=$(date --date="yesterday" +"%Y%m%d")
fi

#BASEURL="http://www.ftp.ncep.noaa.gov/data/nccf/com/gfs/prod/gfs.${DATE_URL}/${CYCLE}"
#BASEURL="ftp://ftpprd.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.${DATE_URL}/${CYCLE}"
BASEURL="https://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_0p25.pl"
URLPAR="&all_lev=on&all_var=on&subregion=&leftlon=${lon_west}&rightlon=${lon_east}&toplat=${lat_north}&bottomlat=${lat_south}&dir=%2Fgfs.${DATE_URL}%2F${CYCLE}%2Fatmos"

OUTFILE="gfs.t${CYCLE}z.pgrb2.0p25.f${HOUR}"
CHECKFILE=${BASEPATH}/GFS/${HOUR}.check

if [[ -f $CHECKFILE && $(<$CHECKFILE) == $DATE ]]; then
    echo "Downloading is not required for time $i"
else
    echo "Downloading GFS data for ${DATE} at ${HOUR}"
#    wget -q -O ${BASEPATH}/GFS/${OUTFILE} "${BASEURL}/${OUTFILE}" && echo ${DATE} > "$CHECKFILE" || echo "Failed at time ${HOUR}!"
    wget -q -O ${BASEPATH}/GFS/${OUTFILE} "${BASEURL}?file=${OUTFILE}${URLPAR}" && echo ${DATE} > "$CHECKFILE" || echo "Failed! at time ${HOUR}!"
fi
