#!/bin/bash 

source ./set_environment.sh

if [ -z "$1" ]; then
    echo "No project name supplied"
    exit 1
fi

SRCDIR="${WRFDIR}/WPS"
PRJDIR="${EXPDIR}/RUNS/${1}"
RUNDIR="${EXPDIR}/RUNS/${1}/WPS"
LOGDIR="${EXPDIR}/RUNS/${1}/LOGS"
NMFILE="${EXPDIR}/namelist/${1}.nml"
PRJNAME="${1}"

if [ -f ${NMFILE} ]; then
    echo "Namelist file found: ${NMFILE}"
    source ${NMFILE}
else
    echo "Namelist file not found: ${NMFILE}"
    echo "A namelist file was expected. Closing..."
    exit 1
fi

if [ -d $RUNDIR ]; then
    echo "WPS Folder found! Closing..."
    exit 1
else
    echo "****************************"
    echo "Creating new WPS Folder "
    echo "****************************"
    echo "Project folder is: $PRJDIR"
    mkdir -p $RUNDIR
    mkdir -p $LOGDIR
    mkdir -p $PRJDIR/SCRIPTS
    mkdir -p $PRJDIR/GFS

    mkdir $RUNDIR/geogrid
    mkdir $RUNDIR/metgrid

    ln -s $SRCDIR/geogrid/src/geogrid.exe   $RUNDIR
    ln -s $SRCDIR/ungrib/src/ungrib.exe     $RUNDIR
    ln -s $SRCDIR/metgrid/src/metgrid.exe   $RUNDIR
    cp $SRCDIR/link_grib.csh                $RUNDIR

    cp ${EXPDIR}/templates/METGRID.TBL.ARW $RUNDIR/metgrid/METGRID.TBL
    cp ${EXPDIR}/templates/GEOGRID.TBL.ARW $RUNDIR/geogrid/GEOGRID.TBL
    cp ${EXPDIR}/templates/Vtable.GFS      $RUNDIR/Vtable
fi

if [[ $gfs_cycle -eq 0 ]]; then
    hinit=0
else
    hinit=$((24-$gfs_cycle))
fi
hstop=$(($total_hours + $hinit))

sed -e "s/\${e_we}/${e_we}/"                       \
    -e "s/\${e_sn}/${e_sn}/"                       \
    -e "s/\${dx}/${dx}/"                           \
    -e "s/\${dy}/${dy}/"                           \
    -e "s/\${ref_lat}/${ref_lat}/"                 \
    -e "s/\${ref_lon}/${ref_lon}/"                 \
    -e "s/\${truelat1}/${truelat1}/"               \
    -e "s/\${truelat2}/${truelat2}/"               \
    -e "s/\${stand_lon}/${stand_lon}/"             \
    ${EXPDIR}/templates/namelist.wps > ${RUNDIR}/namelist.base.wps

sed -e "s|\${total_hours}|${total_hours}|"         \
    -e "1,/ENDDEF/s|\${RUNDIR}|${RUNDIR}|"         \
    -e "1,/ENDDEF/s|\${LOGDIR}|${LOGDIR}|"         \
    -e "1,/ENDDEF/s|\${EXPDIR}|${EXPDIR}|"         \
    -e "1,/ENDDEF/s|\${PRJDIR}|${PRJDIR}|"         \
    ${EXPDIR}/templates/WPS.cmd > ${PRJDIR}/SCRIPTS/WPS.cmd

sed -e "s|\${PRJDIR}|${PRJDIR}|"                   \
    -e "s|\${gfs_cycle}|${gfs_cycle}|"             \
    -e "s|\${lon_west}|${lon_west}|"               \
    -e "s|\${lon_east}|${lon_east}|"               \
    -e "s|\${lat_south}|${lat_south}|"             \
    -e "s|\${lat_north}|${lat_north}|"             \
    ${EXPDIR}/templates/single_gfs.sh > ${PRJDIR}/GFS/single_gfs.sh

sed -e "s|\${PRJDIR}|${PRJDIR}|"                   \
    -e "s|\${hinit}|${hinit}|"                     \
    -e "s|\${hstop}|${hstop}|"                     \
    ${EXPDIR}/templates/get_gfs.sh > ${PRJDIR}/get_gfs.sh

sed -e "s|\${PRJDIR}|${PRJDIR}|"                   \
    -e "s|\${PRJNAME}|${PRJNAME}|"                 \
    -e "s|\${gfs_cycle}|${gfs_cycle}|"             \
    -e "s|\${hinit}|${hinit}|"                     \
    -e "s|\${hstop}|${hstop}|"                     \
    ${EXPDIR}/templates/grib2nc.sh > ${PRJDIR}/GFS/grib2nc.sh

cp ${EXPDIR}/templates/table.levels ${PRJDIR}/GFS

sed -e "s|\${PRJDIR}|${PRJDIR}|"                   \
    -e "s|\${hinit}|${hinit}|"                     \
    -e "s|\${hstop}|${hstop}|"                     \
    ${EXPDIR}/templates/launch_wrf.sh > ${PRJDIR}/launch_wrf.sh

sed -e "s|\${PRJDIR}|${PRJDIR}|"                   \
    ${EXPDIR}/templates/launch_fall3d.sh > ${PRJDIR}/launch_fall3d.sh

sed -e "s|\${PRJDIR}|${PRJDIR}|"                   \
    ${EXPDIR}/templates/launch_fall3d-gfs.sh > ${PRJDIR}/launch_fall3d-gfs.sh

chmod +x ${PRJDIR}/GFS/grib2nc.sh
chmod +x ${PRJDIR}/GFS/single_gfs.sh
chmod +x ${PRJDIR}/get_gfs.sh
chmod +x ${PRJDIR}/launch_wrf.sh
chmod +x ${PRJDIR}/launch_fall3d.sh
chmod +x ${PRJDIR}/launch_fall3d-gfs.sh
