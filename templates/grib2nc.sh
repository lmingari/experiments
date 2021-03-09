#!/bin/bash

WGRIBDIR="/gpfs/projects/bsc21/bsc21908/libraries-nd3/SRC/grib2/wgrib2"
GRIBDIR="${PRJDIR}/GFS"
TABLEFILE="${GRIBDIR}/table.levels"
OUTPUTFILE="${GRIBDIR}/${PRJNAME}.grib2nc.nc"
CYCLE=$(printf %02d ${gfs_cycle})

variables="HGT|TMP|RH|UGRD|VGRD|VVEL|PRES|PRATE|LAND|HPBL"
plevels="1000|975|950|925|900|850|800|750|700|650|600|550|500|450|400|350|300|250|200|150|100|70|50|40|30|20|15|10|7|5|3|2|1|0.4"

[[ -r ${OUTPUTFILE} ]] && rm ${OUTPUTFILE}

for i in $(seq ${hinit} ${hstop})
do  
    HOUR=$(printf %03d $i)
    GRIBFILE="${GRIBDIR}/gfs.t${CYCLE}z.pgrb2.0p25.f${HOUR}"
    echo "Processing ${GRIBFILE}..."
    ${WGRIBDIR}/wgrib2 $GRIBFILE \
        -match ":(${variables}):" \
        -match ":((${plevels}) mb|surface|2 m above ground|10 m above ground):" \
        -nc_table $TABLEFILE \
        -append \
        -nc3 \
        -netcdf \
        $OUTPUTFILE > ${GRIBDIR}/wgrib.log

    code=$?
    if [ $code -eq 0 ]
    then
      echo 'created/added to Netcdf'
    else
      echo 'wgrib2 failed...'
      exit $code
    fi
done
