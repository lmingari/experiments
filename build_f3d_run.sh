#!/bin/bash 

source ./set_environment.sh

if [ -z "$1" ]; then
    echo "No project name supplied"
    exit 1
fi

PRJDIR="${EXPDIR}/RUNS/${1}"
RUNDIR="${EXPDIR}/RUNS/${1}/FALL3D"
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
    echo "FALL3D RUN Folder found! Closing..."
    exit 1
else
    echo "****************************"
    echo "Creating new FALL3D RUN Folder "
    echo "****************************"
    echo "Project folder is: $PRJDIR"
    mkdir -p $RUNDIR
    mkdir -p $LOGDIR
    mkdir -p $PRJDIR/SCRIPTS
fi

sed -e "s|\${total_hours}|${total_hours}|"            \
    -e "s|\${lat_min}|${lat_min}|"                    \
    -e "s|\${lat_max}|${lat_max}|"                    \
    -e "s|\${lon_min}|${lon_min}|"                    \
    -e "s|\${lon_max}|${lon_max}|"                    \
    -e "s|\${dlon}|${dlon}|"                          \
    -e "s|\${dlat}|${dlat}|"                          \
    -e "s|\${nlev}|${nlev}|"                          \
    -e "s|\${zmax}|${zmax}|"                          \
    ${EXPDIR}/templates/fall3d.inp > ${RUNDIR}/${PRJNAME}.base.inp

sed -e "1,/ENDDEF/s|\${RUNDIR}|${RUNDIR}|"            \
    -e "1,/ENDDEF/s|\${LOGDIR}|${LOGDIR}|"            \
    -e "1,/ENDDEF/s|\${EXPDIR}|${EXPDIR}|"            \
    -e "1,/ENDDEF/s|\${PRJDIR}|${PRJDIR}|"            \
    -e "1,/ENDDEF/s|\${F3DIR}|${F3DIR}|"              \
    -e "1,/ENDDEF/s|\${PRJNAME}|${PRJNAME}|"          \
    -e "1,/ENDDEF/s|\${NTASKS}|$((NX*NY*NZ))|"        \
    -e "1,/ENDDEF/s|\${NX}|${NX}|"                    \
    -e "1,/ENDDEF/s|\${NY}|${NY}|"                    \
    -e "1,/ENDDEF/s|\${NZ}|${NZ}|"                    \
    -e "1,/ENDDEF/s|\${total_hours}|${total_hours}|"  \
    ${EXPDIR}/templates/FALL3D_PRE.cmd > ${PRJDIR}/SCRIPTS/FALL3D_PRE.cmd

sed -e "1,/ENDDEF/s|\${RUNDIR}|${RUNDIR}|"            \
    -e "1,/ENDDEF/s|\${LOGDIR}|${LOGDIR}|"            \
    -e "1,/ENDDEF/s|\${EXPDIR}|${EXPDIR}|"            \
    -e "1,/ENDDEF/s|\${PRJDIR}|${PRJDIR}|"            \
    -e "1,/ENDDEF/s|\${F3DIR}|${F3DIR}|"              \
    -e "1,/ENDDEF/s|\${PRJNAME}|${PRJNAME}|"          \
    -e "1,/ENDDEF/s|\${NTASKS}|$((NX*NY*NZ*NENS))|"   \
    -e "1,/ENDDEF/s|\${NX}|${NX}|"                    \
    -e "1,/ENDDEF/s|\${NY}|${NY}|"                    \
    -e "1,/ENDDEF/s|\${NZ}|${NZ}|"                    \
    -e "1,/ENDDEF/s|\${NENS}|${NENS}|"                \
    ${EXPDIR}/templates/FALL3D.cmd > ${PRJDIR}/SCRIPTS/FALL3D.cmd

sed -e "1,/ENDDEF/s|\${RUNDIR}|${RUNDIR}|"            \
    -e "1,/ENDDEF/s|\${LOGDIR}|${LOGDIR}|"            \
    -e "1,/ENDDEF/s|\${EXPDIR}|${EXPDIR}|"            \
    -e "1,/ENDDEF/s|\${PRJDIR}|${PRJDIR}|"            \
    -e "1,/ENDDEF/s|\${F3DIR}|${F3DIR}|"              \
    -e "1,/ENDDEF/s|\${PRJNAME}|${PRJNAME}|"          \
    -e "1,/ENDDEF/s|\${NTASKS}|${NENS}|"              \
    -e "1,/ENDDEF/s|\${NENS}|${NENS}|"                \
    ${EXPDIR}/templates/FALL3D_POS.cmd > ${PRJDIR}/SCRIPTS/FALL3D_POS.cmd

sed -e "s|\${col_height}|${col_height}|"              \
    -e "s|\${run_start}|${run_start}|"                \
    -e "s|\${run_end}|${run_end}|"                    \
    -e "s|\${source_start}|${source_start}|"          \
    -e "s|\${source_end}|${source_end}|"              \
    -e "s|\${lon_vent}|${lon_vent}|"                  \
    -e "s|\${lat_vent}|${lat_vent}|"                  \
    -e "s|\${z_vent}|${z_vent}|"                      \
    ${EXPDIR}/templates/set_parameters.sh > ${PRJDIR}/set_parameters.sh

for subdir in col-mass deposit fl200 fl350 fl450 cloud-top
do
    OUTPATH=$RUNDIR/POST/deterministic/$subdir
    mkdir -p $OUTPATH
    sed -e "s|\${volcano}|${volcano}|"               \
        -e "s|\${lon_vent}|${lon_vent}|"             \
        -e "s|\${lat_vent}|${lat_vent}|"             \
        -e "s|\${RUNDIR}|${RUNDIR}|"                 \
        -e "s|\${INPATH}|${RUNDIR}|"                 \
        -e "s|\${OUTPATH}|${OUTPATH}|"               \
        -e "s|\${PRJNAME}|${PRJNAME}|"               \
        ${EXPDIR}/templates/${subdir}.ncl > ${RUNDIR}/POST/${subdir}.ncl

    OUTPATH=$RUNDIR/POST/probabilistic/$subdir
    mkdir -p $OUTPATH
    sed -e "s|\${volcano}|${volcano}|"               \
        -e "s|\${lon_vent}|${lon_vent}|"             \
        -e "s|\${lat_vent}|${lat_vent}|"             \
        -e "s|\${RUNDIR}|${RUNDIR}|"                 \
        -e "s|\${INPATH}|${RUNDIR}|"                 \
        -e "s|\${OUTPATH}|${OUTPATH}|"               \
        -e "s|\${PRJNAME}|${PRJNAME}|"               \
        ${EXPDIR}/templates/prob-${subdir}.ncl > ${RUNDIR}/POST/prob-${subdir}.ncl
done

cp ${EXPDIR}/templates/lib_fall3d.ncl ${RUNDIR}/POST

mkdir -p ${RUNDIR}/ARCHIVE
