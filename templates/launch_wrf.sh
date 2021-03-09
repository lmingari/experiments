#!/bin/bash

DATE=$(date +"%Y%m%d")
BASEPATH="${PRJDIR}"

for j in {1..100}
do
    X=1
    echo "Checking GFS data. Attempt: $j"
    for i in $(seq ${hinit} ${hstop})
    do 
        HOUR=$(printf %03d $i)
        CHECKFILE=$BASEPATH/GFS/$HOUR.check
        if [[ ! -f $CHECKFILE || $(<$CHECKFILE) != $DATE ]]; then
            echo "$HOUR.check should be updated"
            X=0
            break
        fi
    done

    if [ $X -eq 1 ]; then
        break
    else
        echo "Waiting for the next attempt..."
        sleep 200
    fi
done

if [ $X -eq 1 ]; then
    echo "GFS updated. Launching jobs..."
    bsub < ${BASEPATH}/SCRIPTS/WPS.cmd
    bsub < ${BASEPATH}/SCRIPTS/REAL.cmd
    bsub < ${BASEPATH}/SCRIPTS/WRF.cmd
    bsub < ${BASEPATH}/SCRIPTS/FALL3D_PRE.cmd
    bsub < ${BASEPATH}/SCRIPTS/FALL3D-GFS_PRE.cmd
else
    echo "GFS data not found. Stopping..."
fi
