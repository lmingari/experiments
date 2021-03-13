#!/bin/bash 

#BSUB -n ${NTASKS}
#BSUB -cwd ${RUNDIR}
#BSUB -oo ${LOGDIR}/FALL3D-GFS_PRE_%J.out
#BSUB -eo ${LOGDIR}/FALL3D-GFS_PRE_%J.err
#BSUB -J FALL3D-GFS_PRE
#BSUB -W 01:00
#BSUB -q xlarge
#BSUB -x

RUNDIR=${RUNDIR}
EXPDIR=${EXPDIR}
PRJDIR=${PRJDIR}
F3DIR=${F3DIR}
PRJNAME=${PRJNAME}
NX=${NX}
NY=${NY}
NZ=${NZ}
NENS=1
TASK="setdbs"
###ENDDEF

echo "$(date '+%d/%m/%Y %H:%M:%S'): Starting FALL3D-GFS_PRE" >> ${PRJDIR}/status.log

source ${EXPDIR}/set_environment.sh
source ${PRJDIR}/set_parameters.sh

start_year=$(date +"%Y")
start_month=$(date +"%m")
start_day=$(date +"%d")

METFORM="GRIB2NC"
METFILE="${PRJDIR}/GFS/${PRJNAME}.grib2nc.nc"

sed -e "s|\${start_year}|${start_year}|"         \
    -e "s|\${start_month}|${start_month}|"       \
    -e "s|\${start_day}|${start_day}|"           \
    -e "s|\${METFORM}|${METFORM}|"               \
    -e "s|\${METFILE}|${METFILE}|"               \
    -e "s|\${col_height}|${col_height}|"         \
    -e "s|\${col_height0}|${col_height%% *}|"    \
    -e "s|\${run_start}|${run_start}|"           \
    -e "s|\${run_end}|${run_end}|"               \
    -e "s|\${source_start}|${source_start}|"     \
    -e "s|\${source_end}|${source_end}|"         \
    -e "s|\${lon_vent}|${lon_vent}|"             \
    -e "s|\${lat_vent}|${lat_vent}|"             \
    -e "s|\${z_vent}|${z_vent}|"                 \
    ${RUNDIR}/${PRJNAME}.base.inp > ${RUNDIR}/${PRJNAME}.inp

${PRJDIR}/GFS/grib2nc.sh
mpirun ${F3DIR}/Fall3d.r8.x ${TASK} ${PRJNAME}.inp ${NX} ${NY} ${NZ} -nens ${NENS}

echo "$(date '+%d/%m/%Y %H:%M:%S'): FALL3D-GFS_PRE Done" >> ${PRJDIR}/status.log
