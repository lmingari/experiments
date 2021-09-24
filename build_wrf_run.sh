#!/bin/bash 

source ./set_environment.sh

if [ -z "$1" ]; then
    echo "No project name supplied"
    exit 1
fi

SRCDIR="${WRFDIR}/WRF"
PRJDIR="${EXPDIR}/RUNS/${1}"
RUNDIR="${EXPDIR}/RUNS/${1}/WRF"
LOGDIR="${EXPDIR}/RUNS/${1}/LOGS"
NMFILE="${EXPDIR}/namelist/${1}.nml"

if [ -f ${NMFILE} ]; then
    echo "Namelist file found: ${NMFILE}"
    source ${NMFILE}
else
    echo "Namelist file not found: ${NMFILE}"
    echo "A namelist file was expected. Closing..."
    exit 1
fi

if [ -d $RUNDIR ]; then
    echo "Folder found! Closing..."
    exit 1
else
    echo "****************************"
    echo "Creating new WRF Folder:"
    echo "****************************"
    echo "Project folder is: $PRJDIR"
    mkdir -p $RUNDIR
    mkdir -p $LOGDIR
    mkdir -p $PRJDIR/SCRIPTS

    ln -s $SRCDIR/main/wrf.exe  $RUNDIR
    ln -s $SRCDIR/main/real.exe $RUNDIR

    ln -s $SRCDIR/run/CAM* $RUNDIR
    ln -s $SRCDIR/run/CLM* $RUNDIR
    ln -s $SRCDIR/run/CCN* $RUNDIR
    ln -s $SRCDIR/run/ETA* $RUNDIR
    ln -s $SRCDIR/run/RRT* $RUNDIR
    ln -s $SRCDIR/run/*TBL $RUNDIR
    ln -s $SRCDIR/run/*tbl $RUNDIR
    ln -s $SRCDIR/run/*asc $RUNDIR
    ln -s $SRCDIR/run/*txt $RUNDIR
    ln -s $SRCDIR/run/*bin $RUNDIR
    ln -s $SRCDIR/run/*f90 $RUNDIR
    ln -s $SRCDIR/run/*formatted $RUNDIR

    ln -s $SRCDIR/run/CAMtr_volume_mixing_ratio.RCP8.5 $RUNDIR/CAMtr_volume_mixing_ratio

    ln -s $SRCDIR/run/tr49t67                      $RUNDIR
    ln -s $SRCDIR/run/tr49t85                      $RUNDIR
    ln -s $SRCDIR/run/tr67t85                      $RUNDIR
    ln -s $SRCDIR/run/bulkdens.asc_s_0_03_0_9      $RUNDIR
    ln -s $SRCDIR/run/bulkradii.asc_s_0_03_0_9     $RUNDIR
    ln -s $SRCDIR/run/p3_lookup_table_1.dat-v2.8.2 $RUNDIR
    ln -s $SRCDIR/run/p3_lookup_table_2.dat-v2.8.2 $RUNDIR
    ln -s $SRCDIR/run/kernels.asc_s_0_03_0_9       $RUNDIR
    ln -s $SRCDIR/run/co2_trans                    $RUNDIR

    cp ${EXPDIR}/templates/my_fields_d01.txt $RUNDIR/my_fields_d01.txt
fi

sed -e "s/\${total_hours}/${total_hours}/" \
    -e "s/\${time_step}/${time_step}/"     \
    -e "s/\${e_we}/${e_we}/"               \
    -e "s/\${e_sn}/${e_sn}/"               \
    -e "s/\${e_vert}/${e_vert}/g"          \
    -e "s/\${dx}/${dx}/"                   \
    -e "s/\${dy}/${dy}/"                   \
    ${EXPDIR}/templates/namelist.input > ${RUNDIR}/namelist.base.input

sed -e "1,/ENDDEF/s|\${RUNDIR}|${RUNDIR}|"       \
    -e "1,/ENDDEF/s|\${LOGDIR}|${LOGDIR}|"       \
    -e "1,/ENDDEF/s|\${EXPDIR}|${EXPDIR}|"       \
    -e "1,/ENDDEF/s|\${PRJDIR}|${PRJDIR}|"       \
    -e "s|\${total_hours}|${total_hours}|"       \
    ${EXPDIR}/templates/REAL.cmd > ${PRJDIR}/SCRIPTS/REAL.cmd

sed -e "1,/ENDDEF/s|\${NTASKS}|${ntasks}|"       \
    -e "1,/ENDDEF/s|\${RUNDIR}|${RUNDIR}|"       \
    -e "1,/ENDDEF/s|\${LOGDIR}|${LOGDIR}|"       \
    -e "1,/ENDDEF/s|\${EXPDIR}|${EXPDIR}|"       \
    -e "1,/ENDDEF/s|\${PRJDIR}|${PRJDIR}|"       \
    ${EXPDIR}/templates/WRF.cmd > ${PRJDIR}/SCRIPTS/WRF.cmd
