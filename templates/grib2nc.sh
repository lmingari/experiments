#!/bin/bash

# Description:
# Convert a set of GFS grib files 
# into a single netcdf file
# which can be read by FALL3D.
#
# You should modify only the header
# section and probably the "GRIBFILE"
# variable.
# For example, if the input filenames are:
# gfs.t00z.pgrb2.0p25.f000
# gfs.t00z.pgrb2.0p25.f001 ...
# You have to define GRIBFILE in the loop as:
# GRIBFILE="gfs.t${CYCLE}z.pgrb2.0p25.f${HOUR}"
#
# Parameters:
# OUTPUTFILE: filename for the netCDF output file
# TABLEFILE: auxiliary file defining pressure levels.
#   You have to define "TABLEFILE" depending on 
#   the GFS resolution as GFS output uses different 
#   pressure levels depending on the resolution.
# TMIN/TMAX: refers to min/max forecast hours.
# CYCLE: is the cycle time (0,6,12,18)
# DATE: initial date in format YYYYMMDD

########## Edit header ########## 
WGRIBEXE="/gpfs/projects/bsc21/bsc21908/libraries-nd3/SRC/grib2/wgrib2"
GRIBDIR="${PRJDIR}/GFS"
OUTPUTFILE="${GRIBDIR}/${PRJNAME}.grib2nc.nc"
TABLEFILE="${GRIBDIR}/table.levels"
TMIN=${hinit}
TMAX=${hstop}
CYCLE=${gfs_cycle}
################################# 

variables="HGT|TMP|RH|UGRD|VGRD|VVEL|PRES|PRATE|LAND|HPBL"
plevels="1000|975|950|925|900|850|800|750|700|650|600|550|500|450|400|350|300|250|200|150|100|70|50|40|30|20|15|10|7|5|3|2|1|0.7|0.4|0.2|0.1|0.07|0.04|0.02|0.01"

[[ -r ${OUTPUTFILE} ]] && rm ${OUTPUTFILE}

CYCLE=$(printf %02d ${CYCLE})
for i in $(seq ${TMIN} ${TMAX})
do 
    HOUR=$(printf %03d $i)
    GRIBFILE="${GRIBDIR}/gfs.t${CYCLE}z.pgrb2.0p25.f${HOUR}"
    echo "Processing ${GRIBFILE}..."
    ${WGRIBEXE} ${GRIBFILE} \
        -match ":(${variables}):" \
        -match ":((${plevels}) mb|surface|2 m above ground|10 m above ground):" \
        -nc_table ${TABLEFILE} \
        -append \
        -nc3 \
        -netcdf \
        ${OUTPUTFILE} > ${GRIBDIR}/wgrib.log

    code=$?
    if [ $code -eq 0 ]
    then
      echo 'created/added to Netcdf'
    else
      echo 'wgrib2 failed...'
      exit $code
    fi
done
